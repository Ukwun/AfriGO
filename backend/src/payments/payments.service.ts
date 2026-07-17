import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from "@nestjs/common";
import { createHmac, timingSafeEqual } from "crypto";
import Stripe = require("stripe");
import { FirebaseService } from "../firebase/firebase.service";

@Injectable()
export class PaymentsService {
  private readonly stripe?: any;

  constructor(private readonly firebase: FirebaseService) {
    const secret = process.env.STRIPE_SECRET_KEY;
    if (secret) this.stripe = new Stripe(secret);
  }

  publishableKey() {
    return {
      provider: process.env.FLUTTERWAVE_SECRET_KEY ? "flutterwave" : "stripe",
      publishableKey: process.env.FLUTTERWAVE_PUBLIC_KEY || process.env.STRIPE_PUBLISHABLE_KEY,
    };
  }

  async list(user: any) {
    const snapshot = await this.firebase
      .collection("payments")
      .where("participantIds", "array-contains", user.uid)
      .limit(100)
      .get();
    const data = snapshot.docs
      .map((doc) => ({ id: doc.id, ...doc.data() }))
      .sort((left: any, right: any) => {
        const leftTime = left.createdAt?.toMillis?.() ?? 0;
        const rightTime = right.createdAt?.toMillis?.() ?? 0;
        return rightTime - leftTime;
      });
    return { data };
  }

  async createIntent(user: any, orderId: string, idempotencyKey: string) {
    if (!idempotencyKey)
      throw new BadRequestException("Idempotency-Key header is required");
    const orderSnapshot = await this.firebase
      .collection("orders")
      .doc(orderId)
      .get();
    if (!orderSnapshot.exists) throw new NotFoundException("Order not found");
    const order: any = orderSnapshot.data();
    if (!order.participantIds?.includes(user.uid))
      throw new ForbiddenException("Order access denied");
    if (order.buyerId && order.buyerId !== user.uid)
      throw new ForbiddenException("Only the buyer can pay");
    if (user.kycStatus !== "verified")
      throw new ForbiddenException("Verified KYC is required");
    const amount = Number(order.totalAmount);
    const currency = String(order.currency || "USD").toUpperCase();
    if (!Number.isFinite(amount) || amount <= 0)
      throw new BadRequestException("Order amount is invalid");

    const paymentRef = this.firebase.collection("payments").doc(idempotencyKey);
    const existing = await paymentRef.get();
    if (existing.exists) return existing.data();

    if (process.env.FLUTTERWAVE_SECRET_KEY) {
      return this.createFlutterwave(user, order, orderId, paymentRef, amount, currency);
    }
    if (!this.stripe) throw new Error("No payment provider is configured");
    const intent = await this.stripe.paymentIntents.create(
      {
        amount: Math.round(amount * 100),
        currency: currency.toLowerCase(),
        capture_method: "manual",
        automatic_payment_methods: { enabled: true },
        metadata: { orderId, buyerId: user.uid, paymentId: paymentRef.id },
        description: `AfriGO order ${orderId}`,
      },
      { idempotencyKey },
    );
    const payment = {
      id: paymentRef.id,
      orderId,
      buyerId: user.uid,
      sellerId: order.sellerId || order.supplierId || "",
      participantIds: order.participantIds,
      amount,
      currency,
      provider: "stripe",
      stripePaymentIntentId: intent.id,
      clientSecret: intent.client_secret,
      status: intent.status,
      escrowStatus: "authorization_pending",
      createdAt: this.firebase.serverTimestamp(),
      updatedAt: this.firebase.serverTimestamp(),
    };
    await paymentRef.create(payment);
    await this.audit(user.uid, "payment.intent_created", paymentRef.id, {
      orderId,
      amount,
      currency,
    });
    return payment;
  }

  private async createFlutterwave(
    user: any,
    order: any,
    orderId: string,
    paymentRef: any,
    amount: number,
    currency: string,
  ) {
    const secret = process.env.FLUTTERWAVE_SECRET_KEY!;
    const redirectUrl = process.env.FLUTTERWAVE_REDIRECT_URL;
    if (!redirectUrl) throw new Error("FLUTTERWAVE_REDIRECT_URL is required");
    const response = await fetch("https://api.flutterwave.com/v3/payments", {
      method: "POST",
      headers: { Authorization: `Bearer ${secret}`, "Content-Type": "application/json" },
      body: JSON.stringify({
        tx_ref: paymentRef.id,
        amount: amount.toFixed(2),
        currency,
        redirect_url: redirectUrl,
        customer: {
          email: user.email,
          name: user.displayName || user.fullName || "Afrigo buyer",
          phonenumber: user.phoneNumber,
        },
        meta: { paymentId: paymentRef.id, orderId, buyerId: user.uid },
        customizations: { title: "Afrigo secure trade payment", description: `Order ${orderId}` },
      }),
    });
    const result: any = await response.json();
    if (!response.ok || result.status !== "success" || !result.data?.link) {
      throw new BadRequestException(result.message || "Flutterwave payment initialization failed");
    }
    const payment = {
      id: paymentRef.id, orderId, buyerId: user.uid,
      sellerId: order.sellerId || order.supplierId || "",
      participantIds: order.participantIds, amount, currency,
      provider: "flutterwave", flutterwavePaymentUrl: result.data.link,
      status: "pending", escrowStatus: "payment_pending",
      createdAt: this.firebase.serverTimestamp(), updatedAt: this.firebase.serverTimestamp(),
    };
    await paymentRef.create(payment);
    await this.audit(user.uid, "payment.flutterwave_initialized", paymentRef.id, { orderId, amount, currency });
    return payment;
  }

  async get(user: any, paymentId: string) {
    const snapshot = await this.firebase
      .collection("payments")
      .doc(paymentId)
      .get();
    if (!snapshot.exists) throw new NotFoundException("Payment not found");
    const payment: any = snapshot.data();
    if (!payment.participantIds?.includes(user.uid))
      throw new ForbiddenException("Payment access denied");
    return payment;
  }

  async capture(user: any, paymentId: string, idempotencyKey: string) {
    if (!idempotencyKey)
      throw new BadRequestException("Idempotency-Key header is required");
    const payment: any = await this.get(user, paymentId);
    if (payment.buyerId !== user.uid)
      throw new ForbiddenException("Only the buyer can release payment");
    if (payment.provider === "flutterwave") {
      if (payment.status !== "successful")
        throw new BadRequestException("Payment has not been verified by Flutterwave");
      if (payment.escrowStatus === "released") return payment;
      await this.firebase.collection("payments").doc(paymentId).update({
        escrowStatus: "released",
        releasedAt: this.firebase.serverTimestamp(),
        updatedAt: this.firebase.serverTimestamp(),
      });
      await this.audit(user.uid, "payment.release_authorized", paymentId, { provider: "flutterwave" });
      return this.get(user, paymentId);
    }
    if (!this.stripe) throw new Error("Stripe fallback is not configured");
    const intent = await this.stripe.paymentIntents.capture(
      payment.stripePaymentIntentId,
      {},
      { idempotencyKey },
    );
    await this.firebase
      .collection("payments")
      .doc(paymentId)
      .update({
        status: intent.status,
        escrowStatus:
          intent.status === "succeeded" ? "released" : "capture_processing",
        updatedAt: this.firebase.serverTimestamp(),
      });
    await this.audit(user.uid, "payment.captured", paymentId, {
      stripeStatus: intent.status,
    });
    return this.get(user, paymentId);
  }

  async handleFlutterwaveWebhook(signature: string, rawBody: Buffer, payload: any) {
    const secretHash = process.env.FLUTTERWAVE_WEBHOOK_SECRET;
    if (!secretHash) throw new Error("FLUTTERWAVE_WEBHOOK_SECRET is required");
    const expected = createHmac("sha256", secretHash).update(rawBody).digest("base64");
    const supplied = Buffer.from(signature || "");
    const valid = supplied.length === Buffer.byteLength(expected) &&
      timingSafeEqual(supplied, Buffer.from(expected));
    if (!valid) throw new ForbiddenException("Invalid Flutterwave webhook signature");
    const eventId = String(payload.id || payload.data?.id || "");
    if (!eventId) throw new BadRequestException("Webhook event ID is required");
    const eventRef = this.firebase.collection("flutterwave_events").doc(eventId);
    if ((await eventRef.get()).exists) return { received: true, duplicate: true };
    const transactionId = payload.data?.id;
    const verification = await this.verifyFlutterwave(transactionId);
    const paymentId = String(verification.tx_ref || verification.reference || "");
    const paymentRef = this.firebase.collection("payments").doc(paymentId);
    await this.firebase.getFirestore().runTransaction(async (transaction) => {
      const [eventSnapshot, paymentSnapshot] = await Promise.all([
        transaction.get(eventRef), transaction.get(paymentRef),
      ]);
      if (eventSnapshot.exists) return;
      if (!paymentSnapshot.exists) throw new NotFoundException("Payment reference not found");
      const payment: any = paymentSnapshot.data();
      const verified = verification.status === "successful" &&
        Number(verification.amount) >= Number(payment.amount) &&
        String(verification.currency).toUpperCase() === String(payment.currency).toUpperCase();
      transaction.create(eventRef, { paymentId, type: payload.type || payload.event,
        verified, createdAt: this.firebase.serverTimestamp() });
      transaction.update(paymentRef, {
        status: verified ? "successful" : "verification_failed",
        escrowStatus: verified ? "held" : "failed",
        flutterwaveTransactionId: String(transactionId),
        updatedAt: this.firebase.serverTimestamp(),
      });
    });
    return { received: true };
  }

  private async verifyFlutterwave(transactionId: string) {
    if (!transactionId) throw new BadRequestException("Transaction ID is required");
    const response = await fetch(`https://api.flutterwave.com/v3/transactions/${encodeURIComponent(transactionId)}/verify`, {
      headers: { Authorization: `Bearer ${process.env.FLUTTERWAVE_SECRET_KEY}` },
    });
    const result: any = await response.json();
    if (!response.ok || result.status !== "success")
      throw new BadRequestException("Flutterwave transaction verification failed");
    return result.data;
  }

  async handleWebhook(signature: string, rawBody: Buffer) {
    if (!this.stripe) throw new Error("Stripe fallback is not configured");
    const secret = process.env.STRIPE_WEBHOOK_SECRET;
    if (!secret) throw new Error("STRIPE_WEBHOOK_SECRET is required");
    const event = this.stripe.webhooks.constructEvent(
      rawBody,
      signature,
      secret,
    );
    const eventRef = this.firebase.collection("stripe_events").doc(event.id);
    if ((await eventRef.get()).exists)
      return { received: true, duplicate: true };
    await this.firebase.getFirestore().runTransaction(async (transaction) => {
      const eventSnapshot = await transaction.get(eventRef);
      if (eventSnapshot.exists) return;
      const object: any = event.data.object;
      const paymentId = object.metadata?.paymentId;
      transaction.create(eventRef, {
        type: event.type,
        createdAt: this.firebase.serverTimestamp(),
      });
      if (paymentId)
        transaction.set(
          this.firebase.collection("payments").doc(paymentId),
          {
            status: object.status || event.type,
            escrowStatus: this.escrowStatus(event.type),
            updatedAt: this.firebase.serverTimestamp(),
          },
          { merge: true },
        );
    });
    return { received: true };
  }

  private escrowStatus(type: string) {
    if (type === "payment_intent.amount_capturable_updated")
      return "authorized";
    if (type === "payment_intent.succeeded") return "released";
    if (
      type === "payment_intent.payment_failed" ||
      type === "payment_intent.canceled"
    )
      return "failed";
    return "processing";
  }

  private audit(
    actorId: string,
    action: string,
    entityId: string,
    metadata: any,
  ) {
    return this.firebase
      .collection("audit_events")
      .add({
        actorId,
        action,
        entityType: "payment",
        entityId,
        metadata,
        createdAt: this.firebase.serverTimestamp(),
      });
  }
}
