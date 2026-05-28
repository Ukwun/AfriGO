import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UserActivity } from '../entities';

/**
 * User Activity Service
 * Manages user activity tracking and analytics
 */
@Injectable()
export class UserActivityService {
  private readonly logger = new Logger(UserActivityService.name);

  constructor(
    @InjectRepository(UserActivity)
    private activityRepo: Repository<UserActivity>,
  ) {}

  /**
   * Track a new user activity
   */
  async trackActivity(
    userId: string,
    activityType: string,
    data?: Record<string, any>,
    metadata?: Record<string, any>,
  ): Promise<UserActivity> {
    try {
      const activity = this.activityRepo.create({
        userId,
        activityType,
        data,
        metadata,
      });
      return await this.activityRepo.save(activity);
    } catch (error) {
      this.logger.error(`Failed to track activity for user ${userId}:`, error);
      throw error;
    }
  }

  /**
   * Get activity by ID
   */
  async getActivityById(id: string): Promise<UserActivity | null> {
    try {
      return await this.activityRepo.findOne({ where: { id } });
    } catch (error) {
      this.logger.error(`Failed to get activity ${id}:`, error);
      throw error;
    }
  }

  /**
   * Get user activities with filters
   */
  async getUserActivities(
    userId: string,
    filters?: {
      activityType?: string;
      startDate?: Date;
      endDate?: Date;
      limit?: number;
      offset?: number;
    },
  ): Promise<{ data: UserActivity[]; total: number }> {
    try {
      let query = this.activityRepo
        .createQueryBuilder('activity')
        .where('activity.userId = :userId', { userId });

      if (filters?.activityType) {
        query = query.andWhere('activity.activityType = :activityType', {
          activityType: filters.activityType,
        });
      }

      if (filters?.startDate) {
        query = query.andWhere('activity.createdAt >= :startDate', {
          startDate: filters.startDate,
        });
      }

      if (filters?.endDate) {
        query = query.andWhere('activity.createdAt <= :endDate', {
          endDate: filters.endDate,
        });
      }

      const limit = filters?.limit || 20;
      const offset = filters?.offset || 0;

      const [data, total] = await Promise.all([
        query
          .orderBy('activity.createdAt', 'DESC')
          .take(limit)
          .skip(offset)
          .getMany(),
        query.getCount(),
      ]);

      return { data, total };
    } catch (error) {
      this.logger.error(`Failed to get user activities for user ${userId}:`, error);
      throw error;
    }
  }

  /**
   * Get activity heatmap (hourly distribution of activities)
   */
  async getActivityHeatmap(
    userId: string,
    startDate: Date,
    endDate: Date,
  ): Promise<Record<string, Record<string, number>>> {
    try {
      const activities = await this.activityRepo
        .createQueryBuilder('activity')
        .where('activity.userId = :userId', { userId })
        .andWhere('activity.createdAt >= :startDate', { startDate })
        .andWhere('activity.createdAt <= :endDate', { endDate })
        .getMany();

      const heatmap: Record<string, Record<string, number>> = {};

      activities.forEach((activity) => {
        const hour = activity.createdAt.getHours().toString().padStart(2, '0');
        const dayOfWeek = activity.createdAt.getDay().toString();

        if (!heatmap[dayOfWeek]) {
          heatmap[dayOfWeek] = {};
        }

        heatmap[dayOfWeek][hour] = (heatmap[dayOfWeek][hour] || 0) + 1;
      });

      return heatmap;
    } catch (error) {
      this.logger.error(`Failed to get activity heatmap for user ${userId}:`, error);
      throw error;
    }
  }

  /**
   * Get activity type distribution
   */
  async getActivityTypeDistribution(
    userId: string,
    startDate: Date,
    endDate: Date,
  ): Promise<Record<string, number>> {
    try {
      const activities = await this.activityRepo
        .createQueryBuilder('activity')
        .where('activity.userId = :userId', { userId })
        .andWhere('activity.createdAt >= :startDate', { startDate })
        .andWhere('activity.createdAt <= :endDate', { endDate })
        .getMany();

      const distribution: Record<string, number> = {};

      activities.forEach((activity) => {
        distribution[activity.activityType] =
          (distribution[activity.activityType] || 0) + 1;
      });

      return distribution;
    } catch (error) {
      this.logger.error(`Failed to get activity type distribution for user ${userId}:`, error);
      throw error;
    }
  }

  /**
   * Delete old activities (for data retention/cleanup)
   */
  async deleteOldActivities(daysOld: number): Promise<void> {
    try {
      const cutoffDate = new Date();
      cutoffDate.setDate(cutoffDate.getDate() - daysOld);

      await this.activityRepo
        .createQueryBuilder()
        .delete()
        .where('createdAt < :cutoffDate', { cutoffDate })
        .execute();

      this.logger.log(`Deleted activities older than ${daysOld} days`);
    } catch (error) {
      this.logger.error(`Failed to delete old activities:`, error);
      throw error;
    }
  }
}
