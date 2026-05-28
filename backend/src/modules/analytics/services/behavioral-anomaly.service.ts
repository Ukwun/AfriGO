import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { BehavioralAnomaly } from '../entities';

/**
 * Behavioral Anomaly Service
 * Detects and tracks suspicious behaviors, fraud patterns, and anomalies
 */
@Injectable()
export class BehavioralAnomalyService {
  private readonly logger = new Logger(BehavioralAnomalyService.name);

  constructor(
    @InjectRepository(BehavioralAnomaly)
    private anomalyRepo: Repository<BehavioralAnomaly>,
  ) {}

  /**
   * Create a new behavioral anomaly
   */
  async createAnomaly(
    userId: string,
    anomalyType: string,
    severity: 'low' | 'medium' | 'high' | 'critical',
    description?: string,
    details?: Record<string, any>,
  ): Promise<BehavioralAnomaly> {
    try {
      const anomaly = this.anomalyRepo.create({
        userId,
        anomalyType,
        severity,
        description,
        details,
        isReviewed: false,
      });
      return await this.anomalyRepo.save(anomaly);
    } catch (error) {
      this.logger.error(
        `Failed to create anomaly for user ${userId}:`,
        error,
      );
      throw error;
    }
  }

  /**
   * Get user's anomalies with filters
   */
  async getUserAnomalies(
    userId: string,
    filters?: {
      severity?: 'low' | 'medium' | 'high' | 'critical';
      isReviewed?: boolean;
      daysBack?: number;
      limit?: number;
      offset?: number;
    },
  ): Promise<{ data: BehavioralAnomaly[]; total: number }> {
    try {
      let query = this.anomalyRepo
        .createQueryBuilder('anomaly')
        .where('anomaly.userId = :userId', { userId });

      if (filters?.severity) {
        query = query.andWhere('anomaly.severity = :severity', {
          severity: filters.severity,
        });
      }

      if (filters?.isReviewed !== undefined) {
        query = query.andWhere('anomaly.isReviewed = :isReviewed', {
          isReviewed: filters.isReviewed,
        });
      }

      if (filters?.daysBack) {
        const startDate = new Date();
        startDate.setDate(startDate.getDate() - filters.daysBack);
        query = query.andWhere('anomaly.detectedAt >= :startDate', {
          startDate,
        });
      }

      const limit = filters?.limit || 20;
      const offset = filters?.offset || 0;

      const [data, total] = await Promise.all([
        query
          .orderBy('anomaly.detectedAt', 'DESC')
          .take(limit)
          .skip(offset)
          .getMany(),
        query.getCount(),
      ]);

      return { data, total };
    } catch (error) {
      this.logger.error(`Failed to get anomalies for user ${userId}:`, error);
      throw error;
    }
  }

  /**
   * Mark anomaly as reviewed
   */
  async markAsReviewed(
    anomalyId: string,
    reviewerId: string,
    actionTaken: 'blocked' | 'flagged' | 'ignored' | 'verified_safe',
  ): Promise<BehavioralAnomaly> {
    try {
      const anomaly = await this.anomalyRepo.findOne({
        where: { id: anomalyId },
      });

      if (!anomaly) {
        throw new Error(`Anomaly ${anomalyId} not found`);
      }

      anomaly.isReviewed = true;
      anomaly.reviewerId = reviewerId;
      anomaly.actionTaken = actionTaken;
      anomaly.reviewedAt = new Date();

      return await this.anomalyRepo.save(anomaly);
    } catch (error) {
      this.logger.error(`Failed to mark anomaly as reviewed:`, error);
      throw error;
    }
  }

  /**
   * Get risk summary for a user
   */
  async getUserRiskSummary(userId: string): Promise<Record<string, any>> {
    try {
      const [critical, high, medium, low] = await Promise.all([
        this.anomalyRepo.count({
          where: { userId, severity: 'critical' },
        }),
        this.anomalyRepo.count({
          where: { userId, severity: 'high' },
        }),
        this.anomalyRepo.count({
          where: { userId, severity: 'medium' },
        }),
        this.anomalyRepo.count({
          where: { userId, severity: 'low' },
        }),
      ]);

      const unreviewedCount = await this.anomalyRepo.count({
        where: { userId, isReviewed: false },
      });

      const riskScore = Math.min(
        100,
        critical * 25 + high * 10 + medium * 3 + low * 1,
      );
      const riskLevel =
        riskScore >= 75
          ? 'critical'
          : riskScore >= 50
            ? 'high'
            : riskScore >= 25
              ? 'medium'
              : 'low';

      return {
        riskScore,
        riskLevel,
        anomalyCounts: {
          critical,
          high,
          medium,
          low,
        },
        unreviewedCount,
      };
    } catch (error) {
      this.logger.error(`Failed to get risk summary for user ${userId}:`, error);
      throw error;
    }
  }

  /**
   * Detect velocity-based anomalies (too many actions in short time)
   */
  async detectVelocityAnomaly(
    userId: string,
    activityType: string,
    threshold: number,
    timeWindowMinutes: number,
  ): Promise<BehavioralAnomaly | null> {
    try {
      const startTime = new Date();
      startTime.setMinutes(startTime.getMinutes() - timeWindowMinutes);

      const recentCount = await this.anomalyRepo.count({
        where: {
          userId,
          anomalyType: activityType,
          detectedAt: {
            gte: startTime,
          } as any,
        },
      });

      if (recentCount >= threshold) {
        return await this.createAnomaly(
          userId,
          'velocity_check',
          'high',
          `${recentCount} ${activityType} activities in ${timeWindowMinutes} minutes`,
          {
            activityType,
            count: recentCount,
            threshold,
            timeWindowMinutes,
          },
        );
      }

      return null;
    } catch (error) {
      this.logger.error(`Failed to detect velocity anomaly for user ${userId}:`, error);
      throw error;
    }
  }

  /**
   * Get anomaly trends
   */
  async getAnomalyTrends(
    userId: string,
    daysBack = 30,
  ): Promise<Record<string, any>> {
    try {
      const startDate = new Date();
      startDate.setDate(startDate.getDate() - daysBack);

      const anomalies = await this.anomalyRepo
        .createQueryBuilder('anomaly')
        .where('anomaly.userId = :userId', { userId })
        .andWhere('anomaly.detectedAt >= :startDate', { startDate })
        .orderBy('anomaly.detectedAt', 'ASC')
        .getMany();

      const trends: Record<string, Record<string, number>> = {};

      anomalies.forEach((anomaly) => {
        const date = anomaly.detectedAt.toISOString().split('T')[0];
        if (!trends[date]) {
          trends[date] = {};
        }
        trends[date][anomaly.severity] =
          (trends[date][anomaly.severity] || 0) + 1;
      });

      return {
        totalAnomalies: anomalies.length,
        trends,
        daysBack,
      };
    } catch (error) {
      this.logger.error(`Failed to get anomaly trends for user ${userId}:`, error);
      throw error;
    }
  }
}
