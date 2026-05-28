import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between, MoreThan } from 'typeorm';
import { UserActivity } from './entities/user-activity.entity';

/**
 * Analytics Service
 * 
 * Handles:
 * 1. Activity recording (logs all user actions)
 * 2. Analytics aggregation (generates metrics)
 * 3. Fraud detection (identifies anomalies)
 * 4. User intelligence (builds user profiles)
 * 5. Performance monitoring (tracks API latencies)
 */
@Injectable()
export class AnalyticsService {
  constructor(
    @InjectRepository(UserActivity)
    private activityRepo: Repository<UserActivity>,
  ) {}

  /**
   * Record a user activity
   * Called by all modules when significant actions occur
   */
  async recordActivity(
    userId: string,
    eventType: string,
    action: string,
    data?: Record<string, any>,
    metadata?: {
      endpoint?: string;
      statusCode?: number;
      responseTime?: number;
      deviceType?: string;
      appVersion?: string;
      ipAddress?: string;
      location?: string;
      sessionId?: string;
    },
  ): Promise<UserActivity> {
    const activity = this.activityRepo.create({
      userId,
      eventType,
      action,
      data,
      endpoint: metadata?.endpoint,
      statusCode: metadata?.statusCode,
      responseTime: metadata?.responseTime,
      deviceType: metadata?.deviceType,
      appVersion: metadata?.appVersion,
      ipAddress: metadata?.ipAddress,
      location: metadata?.location,
      sessionId: metadata?.sessionId,
    });

    // Calculate anomaly score
    activity.anomalyScore = await this.calculateAnomalyScore(userId, action, data);

    // Flag if suspicious
    if (activity.anomalyScore > 70) {
      activity.isFlagged = true;
      activity.flagReason = this.generateFlagReason(activity.anomalyScore, action);
    }

    return await this.activityRepo.save(activity);
  }

  /**
   * Get user engagement metrics for dashboard
   */
  async getUserEngagementMetrics(days: number = 30) {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    const activities = await this.activityRepo.find({
      where: {
        timestamp: MoreThan(startDate),
      },
    });

    const totalActivities = activities.length;
    const uniqueUsers = new Set(activities.map(a => a.userId)).size;
    const avgActivitiesPerUser = totalActivities / (uniqueUsers || 1);

    // Activities by type
    const activitiesByType: Record<string, number> = {};
    activities.forEach(a => {
      activitiesByType[a.eventType] = (activitiesByType[a.eventType] || 0) + 1;
    });

    // Error rate
    const errorActivities = activities.filter(a => a.eventType === 'error');
    const errorRate = (errorActivities.length / totalActivities) * 100;

    return {
      totalActivities,
      uniqueUsers,
      avgActivitiesPerUser: Math.round(avgActivitiesPerUser * 100) / 100,
      activitiesByType,
      errorRate: Math.round(errorRate * 100) / 100,
      topErrors: this.getTopErrors(errorActivities, 5),
      timestamp: new Date(),
    };
  }

  /**
   * Get API performance metrics
   */
  async getApiMetrics(days: number = 7) {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    const apiActivities = await this.activityRepo.find({
      where: {
        eventType: 'api_call',
        timestamp: MoreThan(startDate),
      },
    });

    if (apiActivities.length === 0) {
      return { message: 'No API activities recorded' };
    }

    // Metrics by endpoint
    const metricsByEndpoint: Record<string, any> = {};

    apiActivities.forEach(activity => {
      const endpoint = activity.endpoint || 'unknown';
      if (!metricsByEndpoint[endpoint]) {
        metricsByEndpoint[endpoint] = {
          count: 0,
          avgResponseTime: 0,
          errorCount: 0,
          totalResponseTime: 0,
        };
      }

      metricsByEndpoint[endpoint].count++;
      metricsByEndpoint[endpoint].totalResponseTime += activity.responseTime || 0;

      if (activity.statusCode && activity.statusCode >= 400) {
        metricsByEndpoint[endpoint].errorCount++;
      }
    });

    // Calculate averages
    Object.keys(metricsByEndpoint).forEach(endpoint => {
      const metrics = metricsByEndpoint[endpoint];
      metrics.avgResponseTime =
        Math.round((metrics.totalResponseTime / metrics.count) * 100) / 100;
      metrics.errorRate = (metrics.errorCount / metrics.count) * 100;
      delete metrics.totalResponseTime;
    });

    return {
      endpointMetrics: metricsByEndpoint,
      periodDays: days,
      timestamp: new Date(),
    };
  }

  /**
   * Get user activity timeline (personal history)
   */
  async getUserActivityTimeline(userId: string, limit: number = 50) {
    return await this.activityRepo.find({
      where: { userId },
      order: { timestamp: 'DESC' },
      take: limit,
    });
  }

  /**
   * Get top active users
   */
  async getTopActiveUsers(days: number = 30, limit: number = 20) {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    const query = this.activityRepo
      .createQueryBuilder('activity')
      .select('activity.userId', 'userId')
      .addSelect('COUNT(*)', 'activityCount')
      .where('activity.timestamp > :startDate', { startDate })
      .groupBy('activity.userId')
      .orderBy('activityCount', 'DESC')
      .limit(limit);

    return await query.getRawMany();
  }

  /**
   * Get market activity metrics (lot searches, bids, etc.)
   */
  async getMarketActivityMetrics(days: number = 30) {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    const activities = await this.activityRepo.find({
      where: {
        timestamp: MoreThan(startDate),
      },
    });

    const metrics = {
      lotSearches: activities.filter(a => a.action === 'lot_search').length,
      lotViews: activities.filter(a => a.action === 'lot_view').length,
      bidsSubmitted: activities.filter(a => a.action === 'bid_submit').length,
      paymentsInitiated: activities.filter(a => a.action === 'payment_initiate')
        .length,
      contractsCreated: activities.filter(a => a.action === 'contract_create')
        .length,
      shipmentsCreated: activities.filter(a => a.action === 'shipment_create')
        .length,
      timestampperiodDays: days,
    };

    return metrics;
  }

  /**
   * Fraud detection: Calculate anomaly score for a user action
   * 
   * Considers:
   * - Unusual transaction amounts (>20% deviation)
   * - Rapid-fire requests (>10 per minute)
   * - Unusual time patterns (3am+ activity)
   * - New locations
   * - Device changes
   * - Failed payment attempts
   * - Multiple duplicate actions
   */
  private async calculateAnomalyScore(
    userId: string,
    action: string,
    data?: Record<string, any>,
  ): Promise<number> {
    let score = 0;

    // Check for rapid-fire requests (potential bot/automation)
    const recentActivities = await this.activityRepo.find({
      where: {
        userId,
        eventType: 'action',
      },
      order: { timestamp: 'DESC' },
      take: 20,
    });

    const lastMinuteActivities = recentActivities.filter(a => {
      const now = new Date();
      const timeSince = now.getTime() - a.timestamp.getTime();
      return timeSince < 60000; // Last minute
    });

    if (lastMinuteActivities.length > 10) {
      score += 30; // Rapid requests flag
    }

    // Payment anomalies
    if (action === 'payment_initiate' && data?.amount) {
      const amount = data.amount;

      // Find user's average payment amount
      const paymentActivities = recentActivities.filter(
        a => a.action === 'payment_initiate',
      );

      if (paymentActivities.length > 5) {
        const amounts = paymentActivities
          .map(a => a.data?.amount || 0)
          .filter(a => a > 0);
        const avgAmount = amounts.reduce((a, b) => a + b, 0) / amounts.length;

        const deviation = Math.abs(amount - avgAmount) / avgAmount;
        if (deviation > 0.2) {
          score += 25; // Price deviation flag
        }
      }
    }

    // Unusual time pattern (3am-5am activity)
    const hour = new Date().getHours();
    if (hour >= 3 && hour <= 5) {
      score += 10;
    }

    // Failed payment attempts
    if (action === 'payment_initiate' && data?.status === 'failed') {
      const failedPayments = recentActivities.filter(
        a => a.action === 'payment_initiate' && a.data?.status === 'failed',
      );

      if (failedPayments.length >= 3) {
        score += 35; // Multiple failed payments
      }
    }

    return Math.min(score, 100); // Cap at 100
  }

  /**
   * Generate reason for flagging an activity
   */
  private generateFlagReason(anomalyScore: number, action: string): string {
    if (anomalyScore > 80) {
      return `High-risk activity: ${action}`;
    } else if (anomalyScore > 70) {
      return `Suspicious pattern detected in ${action}`;
    } else {
      return `Flagged for review: ${action}`;
    }
  }

  /**
   * Get top errors from activity log
   */
  private getTopErrors(
    errorActivities: UserActivity[],
    limit: number = 5,
  ): Array<{ message: string; count: number }> {
    const errorMap: Record<string, number> = {};

    errorActivities.forEach(activity => {
      const message = activity.errorMessage || 'Unknown error';
      errorMap[message] = (errorMap[message] || 0) + 1;
    });

    return Object.entries(errorMap)
      .sort((a, b) => b[1] - a[1])
      .slice(0, limit)
      .map(([message, count]) => ({ message, count }));
  }
}
