import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
  OnGatewayInit,
  MessageBody,
  ConnectedSocket,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { Logger, UseGuards } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';

/**
 * Real-Time Events Gateway
 * This handles all real-time updates via WebSocket
 * When something happens (trade accepted, payment confirmed, etc),
 * the backend broadcasts to all affected users in real-time
 */
@WebSocketGateway({
  cors: {
    origin: ['http://localhost:3000', 'http://localhost:3001', 'app://afrigo'],
    credentials: true,
  },
  namespace: '/events',
})
export class EventsGateway
  implements OnGatewayInit, OnGatewayConnection, OnGatewayDisconnect
{
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger(EventsGateway.name);

  // Track connected users: userId -> [socketIds]
  private connectedUsers: Map<string, string[]> = new Map();

  constructor(private jwtService: JwtService) {}

  afterInit(server: Server) {
    this.logger.log('WebSocket Gateway initialized');
  }

  /**
   * Handle user connection to WebSocket
   * User must provide JWT token in auth headers
   */
  async handleConnection(client: Socket) {
    try {
      // Extract JWT token from handshake
      const token = client.handshake.auth.token;

      if (!token) {
        this.logger.warn(`Connection attempt without token from ${client.id}`);
        client.disconnect();
        return;
      }

      // Verify JWT token
      const payload = await this.jwtService.verifyAsync(token);
      const userId = payload.sub || payload.id;

      if (!userId) {
        this.logger.warn(`Invalid token from ${client.id}`);
        client.disconnect();
        return;
      }

      // Store connection
      if (!this.connectedUsers.has(userId)) {
        this.connectedUsers.set(userId, []);
      }
      this.connectedUsers.get(userId).push(client.id);

      // Join user-specific room
      client.join(`user:${userId}`);

      // Join general updates room (for things like market prices)
      client.join('market:updates');

      this.logger.log(`User ${userId} connected (${client.id})`);

      // Notify user they're connected
      client.emit('CONNECTED', {
        userId,
        timestamp: new Date(),
        message: 'Connected to real-time events',
      });
    } catch (error) {
      this.logger.error(`Connection error: ${error.message}`);
      client.disconnect();
    }
  }

  /**
   * Handle user disconnection
   */
  handleDisconnect(client: Socket) {
    // Find and remove user
    for (const [userId, socketIds] of this.connectedUsers.entries()) {
      const index = socketIds.indexOf(client.id);
      if (index > -1) {
        socketIds.splice(index, 1);

        if (socketIds.length === 0) {
          this.connectedUsers.delete(userId);
          this.logger.log(`User ${userId} fully disconnected`);
        } else {
          this.logger.log(`User ${userId} lost socket connection (${socketIds.length} remaining)`);
        }
        break;
      }
    }
  }

  /**
   * BROADCAST METHODS - Called by other services to notify users
   */

  /**
   * Notify specific user of an event
   */
  notifyUser(
    userId: string,
    eventType: string,
    data: any,
  ) {
    this.logger.log(`Notifying user ${userId}: ${eventType}`);
    this.server.to(`user:${userId}`).emit(eventType, {
      type: eventType,
      data,
      timestamp: new Date(),
    });
  }

  /**
   * Notify both parties in a trade
   */
  notifyTradePair(
    buyerId: string,
    sellerId: string,
    eventType: string,
    data: any,
  ) {
    this.logger.log(`Notifying trade pair: ${buyerId} <-> ${sellerId} | ${eventType}`);
    
    this.server.to(`user:${buyerId}`).emit(eventType, {
      type: eventType,
      data,
      timestamp: new Date(),
    });

    this.server.to(`user:${sellerId}`).emit(eventType, {
      type: eventType,
      data,
      timestamp: new Date(),
    });
  }

  /**
   * Notify admin dashboard
   */
  notifyAdmins(eventType: string, data: any) {
    this.logger.log(`Notifying admins: ${eventType}`);
    this.server.to('admin:dashboard').emit(eventType, {
      type: eventType,
      data,
      timestamp: new Date(),
    });
  }

  /**
   * Broadcast to all connected users (market-wide events)
   */
  broadcastToAll(eventType: string, data: any) {
    this.logger.log(`Broadcasting to all users: ${eventType}`);
    this.server.emit(eventType, {
      type: eventType,
      data,
      timestamp: new Date(),
    });
  }

  /**
   * Broadcast market updates to all interested users
   */
  broadcastMarketUpdate(data: any) {
    this.logger.log('Broadcasting market update');
    this.server.to('market:updates').emit('MARKET_UPDATE', {
      type: 'MARKET_UPDATE',
      data,
      timestamp: new Date(),
    });
  }

  /**
   * EVENT-SPECIFIC BROADCAST METHODS
   */

  /**
   * Trade was created - notify potential sellers
   */
  broadcastTradeCreated(rfqId: string, data: any) {
    this.server.emit('TRADE_CREATED', {
      type: 'TRADE_CREATED',
      rfqId,
      data,
      timestamp: new Date(),
    });

    this.logger.log(`Trade created broadcast: ${rfqId}`);
  }

  /**
   * Offer received - notify buyer in real-time
   */
  broadcastOfferReceived(
    buyerId: string,
    sellerId: string,
    bidId: string,
    data: any,
  ) {
    this.notifyUser(buyerId, 'TRADE_OFFER_RECEIVED', {
      bidId,
      sellerId,
      ...data,
    });

    this.logger.log(`Offer received notification: ${buyerId} from ${sellerId}`);
  }

  /**
   * Trade accepted - notify both parties
   */
  broadcastTradeAccepted(
    buyerId: string,
    sellerId: string,
    tradeId: string,
    data: any,
  ) {
    this.notifyTradePair(buyerId, sellerId, 'TRADE_ACCEPTED', {
      tradeId,
      ...data,
    });

    this.notifyAdmins('TRADE_ACCEPTED', { tradeId, buyerId, sellerId });

    this.logger.log(`Trade accepted broadcast: ${tradeId}`);
  }

  /**
   * Payment initiated - notify seller
   */
  broadcastPaymentInitiated(
    sellerId: string,
    tradeId: string,
    amount: number,
    data: any,
  ) {
    this.notifyUser(sellerId, 'PAYMENT_INITIATED', {
      tradeId,
      amount,
      ...data,
    });

    this.notifyAdmins('PAYMENT_INITIATED', { tradeId, sellerId, amount });

    this.logger.log(`Payment initiated broadcast: ${tradeId}`);
  }

  /**
   * Payment confirmed - notify both parties
   */
  broadcastPaymentConfirmed(
    buyerId: string,
    sellerId: string,
    tradeId: string,
    amount: number,
    data: any,
  ) {
    this.notifyTradePair(buyerId, sellerId, 'PAYMENT_CONFIRMED', {
      tradeId,
      amount,
      status: 'CONFIRMED',
      ...data,
    });

    this.notifyAdmins('PAYMENT_CONFIRMED', { tradeId, buyerId, sellerId, amount });

    this.logger.log(`Payment confirmed broadcast: ${tradeId}`);
  }

  /**
   * Lot status changed - notify all interested parties
   */
  broadcastLotStatusChanged(
    lotId: string,
    oldStatus: string,
    newStatus: string,
    ownerId: string,
    data: any,
  ) {
    // Notify lot owner
    this.notifyUser(ownerId, 'LOT_STATUS_CHANGED', {
      lotId,
      oldStatus,
      newStatus,
      ...data,
    });

    // Notify any buyers who have interest
    this.server.to(`lot:${lotId}`).emit('LOT_STATUS_CHANGED', {
      type: 'LOT_STATUS_CHANGED',
      lotId,
      oldStatus,
      newStatus,
      timestamp: new Date(),
    });

    this.logger.log(`Lot status changed: ${lotId} ${oldStatus} -> ${newStatus}`);
  }

  /**
   * Shipment location update - notify buyer (real-time GPS tracking)
   */
  broadcastShipmentLocationUpdate(
    buyerId: string,
    shipmentId: string,
    location: { latitude: number; longitude: number; country: string },
    data: any,
  ) {
    this.notifyUser(buyerId, 'SHIPMENT_LOCATION_UPDATE', {
      shipmentId,
      location,
      ...data,
    });

    this.logger.log(`Shipment location update: ${shipmentId}`);
  }

  /**
   * Temperature alert - notify buyer if cold chain broken
   */
  broadcastTemperatureAlert(
    buyerId: string,
    shipmentId: string,
    temperature: number,
    threshold: number,
    severity: 'WARNING' | 'CRITICAL',
  ) {
    this.notifyUser(buyerId, 'SHIPMENT_TEMPERATURE_ALERT', {
      shipmentId,
      temperature,
      threshold,
      severity,
      message:
        severity === 'CRITICAL'
          ? 'Cold chain broken! Product quality at risk.'
          : 'Temperature warning. Monitor closely.',
    });

    this.notifyAdmins('TEMPERATURE_ALERT', {
      shipmentId,
      temperature,
      severity,
    });

    this.logger.log(
      `Temperature alert ${severity}: ${shipmentId} (${temperature}°C)`,
    );
  }

  /**
   * Delivery confirmed - notify seller (payment will be released)
   */
  broadcastDeliveryConfirmed(
    buyerId: string,
    sellerId: string,
    shipmentId: string,
    tradeId: string,
    data: any,
  ) {
    this.notifyTradePair(buyerId, sellerId, 'DELIVERY_CONFIRMED', {
      shipmentId,
      tradeId,
      message: 'Delivery verified. Payment released to seller.',
      ...data,
    });

    this.notifyAdmins('DELIVERY_CONFIRMED', { tradeId, buyerId, sellerId });

    this.logger.log(`Delivery confirmed broadcast: ${shipmentId}`);
  }

  /**
   * Dispute filed - notify both parties and admins
   */
  broadcastDisputeFiled(
    buyerId: string,
    sellerId: string,
    tradeId: string,
    reason: string,
    data: any,
  ) {
    this.notifyTradePair(buyerId, sellerId, 'DISPUTE_FILED', {
      tradeId,
      reason,
      ...data,
    });

    this.notifyAdmins('DISPUTE_FILED', {
      tradeId,
      buyerId,
      sellerId,
      reason,
    });

    this.logger.log(`Dispute filed broadcast: ${tradeId}`);
  }

  /**
   * Fraud alert - notify admins immediately
   */
  broadcastFraudAlert(userId: string, severity: string, details: any) {
    this.notifyAdmins('FRAUD_ALERT', {
      userId,
      severity,
      details,
      requiresImmediate: severity === 'CRITICAL',
    });

    // Notify user (warning)
    if (severity === 'CRITICAL') {
      this.notifyUser(userId, 'ACCOUNT_SECURITY_ALERT', {
        message: 'Unusual activity detected. Your account has been temporarily restricted.',
        severity,
      });
    }

    this.logger.log(`Fraud alert: ${userId} (${severity})`);
  }

  /**
   * User came online/offline
   */
  broadcastUserStatusChange(userId: string, status: 'ONLINE' | 'OFFLINE') {
    // Notify contacts/recent traders
    this.server.emit('USER_STATUS_CHANGE', {
      type: 'USER_STATUS_CHANGE',
      userId,
      status,
      timestamp: new Date(),
    });

    this.logger.log(`User ${userId} status: ${status}`);
  }

  /**
   * Client-side subscription to specific lot updates
   */
  @SubscribeMessage('SUBSCRIBE_LOT')
  handleLotSubscription(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { lotId: string },
  ) {
    client.join(`lot:${data.lotId}`);
    this.logger.log(`Client subscribed to lot: ${data.lotId}`);

    client.emit('SUBSCRIBED', {
      type: 'SUBSCRIBED',
      lotId: data.lotId,
      message: `Now receiving updates for lot ${data.lotId}`,
    });
  }

  /**
   * Client-side unsubscription from lot updates
   */
  @SubscribeMessage('UNSUBSCRIBE_LOT')
  handleLotUnsubscription(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { lotId: string },
  ) {
    client.leave(`lot:${data.lotId}`);
    this.logger.log(`Client unsubscribed from lot: ${data.lotId}`);

    client.emit('UNSUBSCRIBED', {
      type: 'UNSUBSCRIBED',
      lotId: data.lotId,
    });
  }

  /**
   * Admin joins dashboard
   */
  @SubscribeMessage('JOIN_ADMIN_DASHBOARD')
  handleAdminJoin(@ConnectedSocket() client: Socket) {
    client.join('admin:dashboard');
    this.logger.log(`Admin joined dashboard: ${client.id}`);

    client.emit('ADMIN_CONNECTED', {
      type: 'ADMIN_CONNECTED',
      message: 'Admin dashboard connected',
    });
  }

  /**
   * Get current connection stats
   */
  getConnectionStats() {
    return {
      totalConnectedUsers: this.connectedUsers.size,
      totalSockets: this.server.engine.clientsCount,
      connectedUsersList: Array.from(this.connectedUsers.keys()),
    };
  }
}
