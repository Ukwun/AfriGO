import { Injectable, Logger } from '@nestjs/common';
import { EventsGateway } from '../gateways/events.gateway';

/**
 * Notification Service
 * Orchestrates all types of notifications:
 * - Push notifications (Firebase)
 * - SMS notifications (Africast/Twilio)
 * - Email notifications (SendGrid)
 * - In-app notifications (via WebSocket)
 */
@Injectable()
export class NotificationService {
  private readonly logger = new Logger(NotificationService.name);

  constructor(private eventsGateway: EventsGateway) {}

  /**
   * Send notification when trade is accepted
   * This gets called immediately when buyer taps "Accept" button
   */
  async notifyTradeAccepted(
    buyerId: string,
    sellerId: string,
    tradeId: string,
    productType: string,
    quantity: number,
  ) {
    const data = {
      tradeId,
      buyerName: 'Buyer', // In production, fetch actual name
      productType,
      quantity,
      nextAction: 'Start shipping',
      actionUrl: `/trades/${tradeId}`,
    };

    // Send via WebSocket (instant - real-time)
    this.eventsGateway.broadcastTradeAccepted(buyerId, sellerId, tradeId, data);

    // TODO: Send push notification
    // await this.pushNotificationService.send(sellerId, {
    //   title: 'Trade Accepted! 🎉',
    //   body: `Your offer for ${quantity} kg of ${productType} was accepted`,
    //   data,
    // });

    // TODO: Send SMS
    // await this.smsService.send(sellerPhoneNumber, {
    //   message: `AfriGo: Your trade was accepted! Start shipping now.`,
    // });

    this.logger.log(`Trade accepted notification sent: ${tradeId}`);
  }

  /**
   * Send notification when payment is confirmed
   * Seller gets notified that money is on the way
   */
  async notifyPaymentConfirmed(
    buyerId: string,
    sellerId: string,
    tradeId: string,
    amount: number,
    currency: string,
  ) {
    const data = {
      tradeId,
      amount,
      currency,
      message: `Payment confirmed! Money will arrive within 60 seconds.`,
      nextAction: 'Track payment status',
    };

    // Send via WebSocket (instant)
    this.eventsGateway.broadcastPaymentConfirmed(
      buyerId,
      sellerId,
      tradeId,
      amount,
      data,
    );

    // TODO: Push notification
    // TODO: SMS notification
    // TODO: Email receipt

    this.logger.log(`Payment confirmed notification sent: ${tradeId}`);
  }

  /**
   * Send notification when shipment status changes
   * Buyer sees real-time GPS tracking
   */
  async notifyShipmentStatusChanged(
    buyerId: string,
    shipmentId: string,
    oldStatus: string,
    newStatus: string,
    eta?: Date,
  ) {
    const statusMessages = {
      CREATED: '📦 Shipment created',
      IN_TRANSIT: '🚚 Package is on its way',
      OUT_FOR_DELIVERY: '🚪 Out for delivery today',
      DELIVERED: '✅ Delivered successfully',
    };

    const message = statusMessages[newStatus] || `Status: ${newStatus}`;

    const data = {
      shipmentId,
      oldStatus,
      newStatus,
      message,
      eta,
      trackingUrl: `/track/${shipmentId}`,
    };

    // Send via WebSocket (instant)
    this.eventsGateway.broadcastLotStatusChanged(
      shipmentId,
      oldStatus,
      newStatus,
      buyerId,
      data,
    );

    // TODO: Push notification
    // TODO: SMS notification

    this.logger.log(`Shipment status notification sent: ${shipmentId}`);
  }

  /**
   * Send notification for quality verification alert
   * If AI detected issues with delivered product
   */
  async notifyQualityAlert(
    buyerId: string,
    shipmentId: string,
    qualityScore: number,
    issues: string[],
    severity: 'WARNING' | 'CRITICAL',
  ) {
    const data = {
      shipmentId,
      qualityScore,
      issues,
      severity,
      message:
        severity === 'CRITICAL'
          ? 'Quality issues detected. A refund has been initiated.'
          : 'Quality issues detected. Please verify and confirm.',
      actionUrl: `/quality/${shipmentId}`,
    };

    // Send via WebSocket (instant)
    this.eventsGateway.notifyUser(buyerId, 'QUALITY_ALERT', data);

    // TODO: Push notification (urgent)
    // TODO: SMS notification (urgent)
    // TODO: Email with photos

    this.logger.log(`Quality alert sent: ${shipmentId}`);
  }

  /**
   * Send notification for dispute filed
   * Notify all parties and admins
   */
  async notifyDisputeFiled(
    buyerId: string,
    sellerId: string,
    tradeId: string,
    reason: string,
    evidence: any,
  ) {
    const data = {
      tradeId,
      reason,
      message: 'A dispute has been filed. Our support team will review.',
      actionUrl: `/disputes/${tradeId}`,
    };

    // Send via WebSocket (instant)
    this.eventsGateway.broadcastDisputeFiled(buyerId, sellerId, tradeId, reason, data);

    // TODO: Push notification to both
    // TODO: SMS notification
    // TODO: Email with details

    this.logger.log(`Dispute notification sent: ${tradeId}`);
  }

  /**
   * Send fraud alert
   * Notify admins immediately
   */
  async notifyFraudAlert(
    userId: string,
    fraudType: string,
    fraudScore: number,
    flags: string[],
  ) {
    const severity = fraudScore > 80 ? 'CRITICAL' : 'HIGH';

    const data = {
      userId,
      fraudType,
      fraudScore,
      flags,
      severity,
    };

    // Send via WebSocket to admins (immediate)
    this.eventsGateway.broadcastFraudAlert(userId, severity, data);

    // If critical, also notify user
    if (severity === 'CRITICAL') {
      this.eventsGateway.notifyUser(userId, 'ACCOUNT_SECURITY_ALERT', {
        message: 'Unusual activity detected. Your account has been restricted.',
      });
    }

    this.logger.log(`Fraud alert sent: ${userId} (score: ${fraudScore})`);
  }

  /**
   * Send message notification
   * User received a message from trade partner
   */
  async notifyMessageReceived(
    recipientId: string,
    senderId: string,
    senderName: string,
    messagePreview: string,
    tradeId: string,
  ) {
    const data = {
      senderId,
      senderName,
      messagePreview,
      tradeId,
      actionUrl: `/messages/${tradeId}`,
    };

    // Send via WebSocket (instant)
    this.eventsGateway.notifyUser(recipientId, 'MESSAGE_RECEIVED', data);

    // TODO: Push notification
    // TODO: SMS if important

    this.logger.log(`Message notification sent: ${recipientId}`);
  }

  /**
   * Send trust score update
   * User's trust score changed (after trade)
   */
  async notifyTrustScoreUpdate(
    userId: string,
    oldScore: number,
    newScore: number,
    change: number,
    reason: string,
  ) {
    const data = {
      oldScore,
      newScore,
      change,
      changePercentage: ((change / oldScore) * 100).toFixed(1),
      reason,
      message: change > 0 ? '📈 Your trust score improved!' : '📉 Your trust score decreased',
      actionUrl: '/profile/trust',
    };

    // Send via WebSocket
    this.eventsGateway.notifyUser(userId, 'TRUST_SCORE_UPDATED', data);

    // TODO: Push notification (if significant change)

    this.logger.log(`Trust score notification sent: ${userId}`);
  }

  /**
   * Send recommendation notification
   * System recommends next action to user
   */
  async notifyRecommendation(
    userId: string,
    recommendationType: string,
    recommendation: string,
    benefit: string,
  ) {
    const data = {
      type: recommendationType,
      recommendation,
      benefit,
      actionUrl: recommendation.split(' ')[0] === 'Premium' ? '/premium' : '/dashboard',
    };

    // Send via WebSocket
    this.eventsGateway.notifyUser(userId, 'RECOMMENDATION', data);

    // TODO: Push notification (non-intrusive)

    this.logger.log(`Recommendation sent: ${userId}`);
  }

  /**
   * Send price alert
   * Price of product user cares about changed significantly
   */
  async notifyPriceAlert(
    userId: string,
    productType: string,
    oldPrice: number,
    newPrice: number,
    change: number,
  ) {
    const percentageChange = ((change / oldPrice) * 100).toFixed(1);

    const data = {
      productType,
      oldPrice,
      newPrice,
      change,
      percentageChange,
      message: change > 0 ? '📈 Price increased' : '📉 Price decreased',
      actionUrl: `/marketplace?product=${productType}`,
    };

    // Send via WebSocket
    this.eventsGateway.broadcastMarketUpdate(data);

    // Send to specific user only
    this.eventsGateway.notifyUser(userId, 'PRICE_ALERT', data);

    this.logger.log(`Price alert sent: ${userId} - ${productType}`);
  }

  /**
   * Send batch notification (for admin broadcasts)
   */
  async broadcastSystemMessage(message: string, severity: 'INFO' | 'WARNING' | 'CRITICAL') {
    const data = {
      message,
      severity,
      timestamp: new Date(),
    };

    // Broadcast to all users
    this.eventsGateway.broadcastToAll('SYSTEM_MESSAGE', data);

    this.logger.log(`System message broadcast: ${severity} - ${message}`);
  }
}
