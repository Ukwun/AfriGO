import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from "@nestjs/common";
import { FirebaseService } from "../firebase/firebase.service";

const RESOURCES = [
  "lots",
  "rfqs",
  "offers",
  "quotes",
  "contracts",
  "orders",
  "shipments",
  "messages",
  "quality_inspections",
  "notifications",
] as const;

@Injectable()
export class ResourcesService {
  constructor(private readonly firebase: FirebaseService) {}

  collection(resource: string) {
    if (!(RESOURCES as readonly string[]).includes(resource))
      throw new NotFoundException("Resource not found");
    return this.firebase.collection(resource);
  }

  async list(resource: string, user: any, limit = 30, scope?: string) {
    const safeLimit = Math.min(Math.max(limit || 30, 1), 100);
    if (resource === "lots" && scope === "marketplace") {
      if (!["buyer", "exporter"].includes(user.role))
        throw new ForbiddenException("Marketplace access is for buyers and exporters");
      const snapshot = await this.collection(resource)
        .where("status", "==", "active")
        .limit(safeLimit)
        .get();
      return {
        data: snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() })),
      };
    }
    if (resource === "rfqs" && scope === "marketplace") {
      if (!["supplier", "exporter"].includes(user.role))
        throw new ForbiddenException("RFQ marketplace access is for suppliers and exporters");
      const snapshot = await this.collection(resource)
        .where("status", "==", "open")
        .limit(safeLimit)
        .get();
      return {
        data: snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() })),
      };
    }
    const snapshot = await this.collection(resource)
      .where("participantIds", "array-contains", user.uid)
      .orderBy("createdAt", "desc")
      .limit(safeLimit)
      .get();
    return {
      data: snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() })),
    };
  }

  async get(resource: string, id: string, user: any) {
    const snapshot = await this.collection(resource).doc(id).get();
    if (!snapshot.exists) throw new NotFoundException("Record not found");
    const record: any = { id: snapshot.id, ...snapshot.data() };
    this.assertParticipant(record, user);
    return record;
  }

  async create(resource: string, body: any, user: any) {
    this.assertCreateRole(resource, user, body);
    const participantIds = Array.from(
      new Set([
        user.uid,
        ...(Array.isArray(body.participantIds) ? body.participantIds : []),
      ]),
    );
    if (participantIds.some((id) => typeof id !== "string" || !id))
      throw new BadRequestException("Invalid participant");
    const ref = this.collection(resource).doc();
    const record = {
      ...this.clean(body),
      ownerId: user.uid,
      participantIds,
      status: body.status || "draft",
      createdAt: this.firebase.serverTimestamp(),
      updatedAt: this.firebase.serverTimestamp(),
    };
    await ref.create(record);
    await this.audit(user.uid, `${resource}.created`, resource, ref.id);
    return { id: ref.id, ...record };
  }

  async update(resource: string, id: string, body: any, user: any) {
    const ref = this.collection(resource).doc(id);
    await this.firebase.getFirestore().runTransaction(async (transaction) => {
      const snapshot = await transaction.get(ref);
      if (!snapshot.exists) throw new NotFoundException("Record not found");
      const record: any = snapshot.data();
      this.assertParticipant(record, user);
      if (record.ownerId !== user.uid)
        throw new ForbiddenException("Only the owner can modify this record");
      transaction.update(ref, {
        ...this.clean(body),
        ownerId: record.ownerId,
        participantIds: record.participantIds,
        updatedAt: this.firebase.serverTimestamp(),
      });
    });
    await this.audit(user.uid, `${resource}.updated`, resource, id);
    return this.get(resource, id, user);
  }

  private assertParticipant(record: any, user: any) {
    if (!record.participantIds?.includes(user.uid))
      throw new ForbiddenException("You cannot access this record");
  }

  private assertCreateRole(resource: string, user: any, body: any) {
    const role = user.role;
    if (user.accountStatus !== "active")
      throw new ForbiddenException("Account is not active");
    if (resource === "lots" && !["supplier", "exporter"].includes(role))
      throw new ForbiddenException(
        "Only suppliers and exporters can create lots",
      );
    if (resource === "rfqs" && !["buyer", "exporter"].includes(role))
      throw new ForbiddenException("Only buyers and exporters can create RFQs");
    if (["offers", "quotes"].includes(resource) && !["supplier", "exporter"].includes(role))
      throw new ForbiddenException("Only suppliers and exporters can submit offers");
    if (resource === "quality_inspections" && role !== "exporter")
      throw new ForbiddenException("Only exporters can record quality inspections");
    if (resource === "notifications")
      throw new ForbiddenException("Notifications are created by trusted backend workflows");
    if (
      resource === "messages" &&
      (!body?.conversationId || !body?.recipientId)
    )
      throw new BadRequestException("Messages require a conversation and recipient");
    if (
      ["contracts", "orders", "shipments"].includes(resource) &&
      user.kycStatus !== "verified"
    )
      throw new ForbiddenException("Verified KYC is required");
  }

  private clean(body: any) {
    const { id, ownerId, createdAt, updatedAt, ...safe } = body || {};
    return safe;
  }

  private audit(
    actorId: string,
    action: string,
    entityType: string,
    entityId: string,
  ) {
    return this.firebase.collection("audit_events").add({
      actorId,
      action,
      entityType,
      entityId,
      createdAt: this.firebase.serverTimestamp(),
    });
  }
}
