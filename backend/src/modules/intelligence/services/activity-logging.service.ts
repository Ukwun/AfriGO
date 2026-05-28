import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UserActivityLog } from '../entities/activity-log.entity';

@Injectable()
export class ActivityLoggingService {
  private readonly logger = new Logger(ActivityLoggingService.name);

  constructor(
    @InjectRepository(UserActivityLog)
    private activityLogRepository: Repository<UserActivityLog>,
  ) {}

  /**
   * Log user activity - called whenever user does something important
   * This creates immutable audit trail
   */
  async logActivity(
    userId: string,
    activityType: string,
    data: {
      ipAddress?: string;
      userAgent?: string;
      deviceInfo?: any;
      location?: any;
      actionData?: any;
    },
  ): Promise<UserActivityLog> {
    try {
      const activity = new UserActivityLog();
      activity.userId = userId;
      activity.activityType = activityType as any;
      activity.ipAddress = data.ipAddress;
      activity.userAgent = data.userAgent;
      activity.deviceInfo = data.deviceInfo || {};
      activity.location = data.location;
      activity.actionData = data.actionData || {};
      activity.timestamp = Date.now();
      activity.isAnomalous = false; // Will be calculated by anomaly detection
      activity.anomalyScore = 0;

      const saved = await this.activityLogRepository.save(activity);

      this.logger.log(
        `Activity logged: ${userId} - ${activityType} (${saved.id})`,
      );

      return saved;
    } catch (error) {
      this.logger.error(
        `Failed to log activity for user ${userId}: ${error.message}`,
      );
      throw error;
    }
  }

  /**
   * Log login activity
   */
  async logLogin(
    userId: string,
    ipAddress: string,
    userAgent: string,
    deviceInfo: any,
    location?: any,
  ): Promise<UserActivityLog> {
    return this.logActivity(userId, 'LOGIN', {
      ipAddress,
      userAgent,
      deviceInfo,
      location,
    });
  }

  /**
   * Log lot creation
   */
  async logLotCreation(
    userId: string,
    lotId: string,
    productType: string,
    quantity: number,
    ipAddress: string,
  ): Promise<UserActivityLog> {
    return this.logActivity(userId, 'CREATE_LOT', {
      ipAddress,
      actionData: {
        lotId,
        productType,
        quantity,
      },
    });
  }

  /**
   * Log trade acceptance
   */
  async logTradeAccepted(
    userId: string,
    tradeId: string,
    amount: number,
    currency: string,
    targetUserId: string,
    ipAddress: string,
  ): Promise<UserActivityLog> {
    return this.logActivity(userId, 'ACCEPT_TRADE', {
      ipAddress,
      actionData: {
        tradeId,
        amount,
        currency,
        targetUserId,
      },
    });
  }

  /**
   * Log payment initiation
   */
  async logPaymentInitiated(
    userId: string,
    tradeId: string,
    amount: number,
    currency: string,
    ipAddress: string,
  ): Promise<UserActivityLog> {
    return this.logActivity(userId, 'PAYMENT_INITIATED', {
      ipAddress,
      actionData: {
        tradeId,
        amount,
        currency,
        status: 'PENDING',
      },
    });
  }

  /**
   * Log payment confirmation
   */
  async logPaymentConfirmed(
    userId: string,
    tradeId: string,
    amount: number,
    currency: string,
    transactionId: string,
    ipAddress: string,
  ): Promise<UserActivityLog> {
    return this.logActivity(userId, 'PAYMENT_CONFIRMED', {
      ipAddress,
      actionData: {
        tradeId,
        amount,
        currency,
        transactionId,
        status: 'SUCCESS',
      },
    });
  }

  /**
   * Log shipment creation
   */
  async logShipmentCreated(
    userId: string,
    shipmentId: string,
    tradeId: string,
    ipAddress: string,
  ): Promise<UserActivityLog> {
    return this.logActivity(userId, 'SHIPMENT_CREATED', {
      ipAddress,
      actionData: {
        shipmentId,
        tradeId,
      },
    });
  }

  /**
   * Log delivery confirmation
   */
  async logDeliveryConfirmed(
    userId: string,
    shipmentId: string,
    tradeId: string,
    qualityVerified: boolean,
    ipAddress: string,
  ): Promise<UserActivityLog> {
    return this.logActivity(userId, 'DELIVERY_CONFIRMED', {
      ipAddress,
      actionData: {
        shipmentId,
        tradeId,
        qualityVerified,
      },
    });
  }

  /**
   * Get activity history for user
   */
  async getUserActivityHistory(
    userId: string,
    days: number = 30,
  ): Promise<UserActivityLog[]> {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    return await this.activityLogRepository.find({
      where: {
        userId,
        createdAt: { _type: 'gte', _value: startDate } as any,
      } as any,
      order: { createdAt: 'DESC' },
      take: 1000, // Limit to 1000 records
    });
  }

  /**
   * Get activity count by type for user
   */
  async getActivityCountByType(
    userId: string,
    days: number = 30,
  ): Promise<Record<string, number>> {
    const activities = await this.getUserActivityHistory(userId, days);

    const counts: Record<string, number> = {};

    activities.forEach((activity) => {
      counts[activity.activityType] = (counts[activity.activityType] || 0) + 1;
    });

    return counts;
  }

  /**
   * Get latest activity for user
   */
  async getLatestActivity(userId: string): Promise<UserActivityLog | null> {
    return await this.activityLogRepository.findOne({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
  }

  /**
   * Mark activity as anomalous
   */
  async markActivityAnomalous(
    activityId: string,
    anomalyType: string,
    score: number,
  ): Promise<UserActivityLog | null> {
    const activity = await this.activityLogRepository.findOne({
      where: { id: activityId },
    });

    if (!activity) {
      return null;
    }

    activity.isAnomalous = true;
    activity.anomalyType = anomalyType;
    activity.anomalyScore = score;

    return await this.activityLogRepository.save(activity);
  }

  /**
   * Get anomalous activities for user
   */
  async getAnomalousActivities(
    userId: string,
    days: number = 30,
  ): Promise<UserActivityLog[]> {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    return await this.activityLogRepository.find({
      where: {
        userId,
        isAnomalous: true,
        createdAt: { _type: 'gte', _value: startDate } as any,
      } as any,
      order: { anomalyScore: 'DESC' },
    });
  }

  /**
   * Get activities from specific time period
   */
  async getActivitiesInTimePeriod(
    userId: string,
    startTime: Date,
    endTime: Date,
  ): Promise<UserActivityLog[]> {
    return await this.activityLogRepository.find({
      where: {
        userId,
        createdAt: { _type: 'between', _value: [startTime, endTime] } as any,
      } as any,
      order: { createdAt: 'DESC' },
    });
  }

  /**
   * Count activities in time period
   */
  async countActivitiesInTimePeriod(
    userId: string,
    startTime: Date,
    endTime: Date,
    activityType?: string,
  ): Promise<number> {
    if (activityType) {
      return await this.activityLogRepository.count({
        where: {
          userId,
          activityType: activityType as any,
          createdAt: { _type: 'between', _value: [startTime, endTime] } as any,
        } as any,
      });
    }

    return await this.activityLogRepository.count({
      where: {
        userId,
        createdAt: { _type: 'between', _value: [startTime, endTime] } as any,
      } as any,
    });
  }
}
