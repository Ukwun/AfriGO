import {
  BadRequestException,
  Injectable,
  UnauthorizedException,
} from "@nestjs/common";
import { FirebaseService } from "../firebase/firebase.service";

export type CanonicalRole = "supplier" | "exporter" | "buyer";

@Injectable()
export class AuthService {
  constructor(private readonly firebase: FirebaseService) {}

  normalizeRole(role?: string): CanonicalRole {
    switch ((role || "").trim().toLowerCase()) {
      case "seller":
      case "supplier":
      case "farmer":
        return "supplier";
      case "buyer":
      case "wholesale_buyer":
      case "wholesale buyer":
        return "buyer";
      case "exporter":
      case "member":
        return "exporter";
      default:
        return "buyer";
    }
  }

  async createSession(idToken: string, profile: Record<string, unknown> = {}) {
    let identity;
    try {
      identity = await this.firebase.verifyIdToken(idToken);
    } catch (_) {
      throw new UnauthorizedException("Invalid or expired Firebase session");
    }

    const ref = this.firebase.users().doc(identity.uid);
    const existing = await ref.get();
    const current = existing.data() || {};
    const requestedRole = this.normalizeRole(
      String(profile.role || current.role || ""),
    );
    const role = existing.exists
      ? this.normalizeRole(String(current.role))
      : requestedRole;
    const displayParts = (identity.name || "")
      .trim()
      .split(/\s+/)
      .filter(Boolean);
    const user = {
      id: identity.uid,
      email: identity.email || "",
      firstName: String(
        profile.firstName || current.firstName || displayParts[0] || "",
      ),
      lastName: String(
        profile.lastName ||
          current.lastName ||
          displayParts.slice(1).join(" ") ||
          "",
      ),
      fullName: String(
        profile.fullName || current.fullName || identity.name || "",
      ).trim(),
      role,
      roles: [role],
      phone: String(
        profile.phone || current.phone || identity.phone_number || "",
      ),
      organization: String(profile.organization || current.organization || ""),
      countryCode: String(
        profile.countryCode || current.countryCode || "",
      ).toUpperCase(),
      emailVerified: Boolean(identity.email_verified),
      phoneVerified: Boolean(identity.phone_number),
      kycStatus: current.kycStatus || "pending",
      accountStatus: current.accountStatus || "active",
      trustScore: Number(current.trustScore || 0),
      completedTrades: Number(current.completedTrades || 0),
      updatedAt: this.firebase.serverTimestamp(),
      ...(existing.exists
        ? {}
        : { createdAt: this.firebase.serverTimestamp() }),
    };
    await ref.set(user, { merge: true });
    await this.firebase.collection("audit_events").add({
      actorId: identity.uid,
      action: existing.exists ? "session.created" : "user.created",
      entityType: "user",
      entityId: identity.uid,
      createdAt: this.firebase.serverTimestamp(),
    });
    return { success: true, user: this.publicUser(user), token: idToken };
  }

  async getUserById(userId: string) {
    const snapshot = await this.firebase.users().doc(userId).get();
    if (!snapshot.exists)
      throw new BadRequestException("User profile not found");
    return this.publicUser({ id: snapshot.id, ...snapshot.data() });
  }

  async updateProfile(userId: string, updates: Record<string, unknown>) {
    const allowed: Record<string, string> = {};
    for (const key of ["phone", "organization", "countryCode"]) {
      if (updates[key] != null)
        allowed[key] = String(updates[key]).trim().slice(0, 160);
    }
    if (allowed.countryCode)
      allowed.countryCode = allowed.countryCode.toUpperCase();
    await this.firebase
      .users()
      .doc(userId)
      .set(
        { ...allowed, updatedAt: this.firebase.serverTimestamp() },
        { merge: true },
      );
    await this.firebase.collection("audit_events").add({
      actorId: userId,
      action: "user.profile_updated",
      entityType: "user",
      entityId: userId,
      changedFields: Object.keys(allowed),
      createdAt: this.firebase.serverTimestamp(),
    });
    return this.getUserById(userId);
  }

  async verifyToken(token: string) {
    try {
      return await this.firebase.verifyIdToken(token);
    } catch (_) {
      throw new UnauthorizedException("Invalid or expired session");
    }
  }

  publicUser(user: any) {
    const { passwordHash: _passwordHash, ...result } = user;
    return result;
  }
}
