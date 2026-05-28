import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import {
  UserActivity,
  UserSession,
  PageView,
  UserMetric,
  Event,
  BehavioralAnomaly,
  Recommendation,
  AnalyticsSummary,
} from '../entities';

/**
 * Core Analytics Service
 * Provides comprehensive analytics functionality:
 * - User activity tracking
 * - Session management
 * - Page view analytics
 * - Event tracking
 * - Custom metrics aggregation
 * - Behavioral analysis
 * - Recommendation generation
 * - Analytics summary calculations
 */
@Injectable()
export class AnalyticsService {
  private readonly logger = new Logger(AnalyticsService.name);

  constructor(
    @InjectRepository(UserActivity)
    private userActivityRepo: Repository<UserActivity>,
    @InjectRepository(UserSession)
    private userSessionRepo: Repository<UserSession>,
    @InjectRepository(PageView)
    private pageViewRepo: Repository<PageView>,
    @InjectRepository(UserMetric)
    private userMetricRepo: Repository<UserMetric>,
    @InjectRepository(Event)
    private eventRepo: Repository<Event>,
    @InjectRepository(BehavioralAnomaly)
    private anomalyRepo: Repository<BehavioralAnomaly>,
    @InjectRepository(Recommendation)
    private recommendationRepo: Repository<Recommendation>,
    @InjectRepository(AnalyticsSummary)
    private summaryRepo: Repository<AnalyticsSummary>,
  ) {}

  /**
   * Track a user activity event
   */
  async trackActivity(
    userId: string,
    activityType: string,
    data?: Record<string, any>,
  ): Promise<UserActivity> {
    try {
      const activity = this.userActivityRepo.create({
        userId,
        activityType,
        data,
      });
      return await this.userActivityRepo.save(activity);
    } catch (error) {
      this.logger.error(`Failed to track activity for user ${userId}:`, error);
      throw error;
    }
  }

  /**
   * Get user activity statistics for a time period
   */
  async getActivityStats(
    userId: string,
    startDate: Date,
    endDate: Date,
  ): Promise<Record<string, any>> {
    try {
      const activities = await this.userActivityRepo.find({
        where: {
          userId,
          createdAt: {
            between: [startDate, endDate],
          } as any,
        },
      });

      const stats = {
        totalActivities: activities.length,
        byType: {} as Record<string, number>,
        hourlyDistribution: {} as Record<string, number>,
      };

      activities.forEach((activity) => {
        // Count by type
        stats.byType[activity.activityType] =
          (stats.byType[activity.activityType] || 0) + 1;

        // Count by hour
        const hour = activity.createdAt.getHours();
        stats.hourlyDistribution[hour.toString()] =
          (stats.hourlyDistribution[hour.toString()] || 0) + 1;
      });

      return stats;
    } catch (error) {
      this.logger.error(`Failed to get activity stats for user ${userId}:`, error);
      throw error;
    }
  }

  /**
   * Get page view analytics for a user
   */
  async getPageViewStats(
    userId: string,
    startDate: Date,
    endDate: Date,
  ): Promise<Record<string, any>> {
    try {
      const pageViews = await this.pageViewRepo.find({
        where: {
          userId,
          createdAt: {
            between: [startDate, endDate],
          } as any,
        },
      });

      const stats = {
        totalPageViews: pageViews.length,
        uniquePages: new Set(pageViews.map((p) => p.pageUrl)).size,
        topPages: {} as Record<string, number>,
        avgTimeOnPage: 0,
        bounceRate: 0,
      };

      let totalTimeOnPage = 0;
      pageViews.forEach((view) => {
        stats.topPages[view.pageUrl] = (stats.topPages[view.pageUrl] || 0) + 1;
        if (view.timeOnPage) {
          totalTimeOnPage += view.timeOnPage;
        }
      });

      if (pageViews.length > 0) {
        stats.avgTimeOnPage = totalTimeOnPage / pageViews.length;
      }

      return stats;
    } catch (error) {
      this.logger.error(`Failed to get page view stats for user ${userId}:`, error);
      throw error;
    }
  }

  /**
   * Track a custom event
   */
  async trackEvent(
    userId: string,
    eventName: string,
    eventData?: Record<string, any>,
    metadata?: Record<string, any>,
  ): Promise<Event> {
    try {
      const event = this.eventRepo.create({
        userId,
        eventName,
        eventData,
        metadata,
      });
      return await this.eventRepo.save(event);
    } catch (error) {
      this.logger.error(`Failed to track event for user ${userId}:`, error);
      throw error;
    }
  }

  /**
   * Get user session information
   */
  async getUserSessions(
    userId: string,
    limit = 10,
  ): Promise<UserSession[]> {
    try {
      return await this.userSessionRepo.find({
        where: { userId },
        order: { startTime: 'DESC' },
        take: limit,
      });
    } catch (error) {
      this.logger.error(`Failed to get sessions for user ${userId}:`, error);
      throw error;
    }
  }

  /**
   * Get user behavioral anomalies
   */
  async getUserAnomalies(
    userId: string,
    severity?: 'low' | 'medium' | 'high' | 'critical',
  ): Promise<BehavioralAnomaly[]> {
    try {
      const query = this.anomalyRepo.createQueryBuilder('anomaly').where('anomaly.userId = :userId', { userId });

      if (severity) {
        query.andWhere('anomaly.severity = :severity', { severity });
      }

      return await query.orderBy('anomaly.detectedAt', 'DESC').getMany();
    } catch (error) {
      this.logger.error(`Failed to get anomalies for user ${userId}:`, error);
      throw error;
    }
  }

  /**
   * Get user recommendations
   */
  async getUserRecommendations(
    userId: string,
    limit = 10,
    active = true,
  ): Promise<Recommendation[]> {
    try {
      const query = this.recommendationRepo
        .createQueryBuilder('rec')
        .where('rec.userId = :userId', { userId });

      if (active) {
        query.andWhere('rec.isActive = :isActive', { isActive: true });
      }

      return await query
        .orderBy('rec.priority', 'DESC')
        .take(limit)
        .getMany();
    } catch (error) {
      this.logger.error(`Failed to get recommendations for user ${userId}:`, error);
      throw error;
    }
  }

  /**
   * Mark a recommendation as clicked
   */
  async markRecommationClicked(recommendationId: string): Promise<void> {
    try {
      const recommendation = await this.recommendationRepo.findOne({
        where: { id: recommendationId },
      });

      if (recommendation) {
        recommendation.isClicked = true;
        recommendation.clickedAt = new Date();
        recommendation.displayCount += 1;
        await this.recommendationRepo.save(recommendation);
      }
    } catch (error) {
      this.logger.error(`Failed to mark recommendation as clicked:`, error);
      throw error;
    }
  }

  /**
   * Mark a recommendation as converted
   */
  async markRecommendationConverted(recommendationId: string): Promise<void> {
    try {
      const recommendation = await this.recommendationRepo.findOne({
        where: { id: recommendationId },
      });

      if (recommendation) {
        recommendation.isConverted = true;
        recommendation.convertedAt = new Date();
        await this.recommendationRepo.save(recommendation);
      }
    } catch (error) {
      this.logger.error(`Failed to mark recommendation as converted:`, error);
      throw error;
    }
  }

  /**
   * Calculate user metrics summary
   */
  async calculateUserMetrics(userId: string, period = 30): Promise<UserMetric> {
    try {
      const startDate = new Date();
      startDate.setDate(startDate.getDate() - period);

      const activityStats = await this.getActivityStats(userId, startDate, new Date());
      const pageViewStats = await this.getPageViewStats(userId, startDate, new Date());

      const metric = this.userMetricRepo.create({
        userId,
        metricName: `user_summary_${period}d`,
        metricValue: {
          totalActivities: activityStats.totalActivities,
          totalPageViews: pageViewStats.totalPageViews,
          avgTimeOnPage: pageViewStats.avgTimeOnPage,
        },
        period,
      });

      return await this.userMetricRepo.save(metric);
    } catch (error) {
      this.logger.error(`Failed to calculate metrics for user ${userId}:`, error);
      throw error;
    }
  }

  /**
   * Get dashboard data for a user
   */
  async getDashboardData(userId: string): Promise<Record<string, any>> {
    try {
      const sessions = await this.getUserSessions(userId, 5);
      const anomalies = await this.getUserAnomalies(userId);
      const recommendations = await this.getUserRecommendations(userId, 5);
      const metrics = await this.userMetricRepo.find({
        where: { userId },
        order: { createdAt: 'DESC' },
        take: 1,
      });

      return {
        recentSessions: sessions,
        pendingAnomalies: anomalies.filter((a) => !a.isReviewed),
        topRecommendations: recommendations,
        latestMetrics: metrics[0] || null,
      };
    } catch (error) {
      this.logger.error(`Failed to get dashboard data for user ${userId}:`, error);
      throw error;
    }
  }
}
