import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Recommendation } from '../entities';

/**
 * Recommendation Service
 * Generates and manages personalized recommendations
 */
@Injectable()
export class RecommendationService {
  private readonly logger = new Logger(RecommendationService.name);

  constructor(
    @InjectRepository(Recommendation)
    private recommendationRepo: Repository<Recommendation>,
  ) {}

  /**
   * Create a new recommendation
   */
  async createRecommendation(
    userId: string,
    recommendationType: string,
    title: string,
    description: string,
    options?: {
      targetId?: string;
      targetType?: string;
      potentialSavings?: number;
      priority?: 'low' | 'medium' | 'high';
      expiresAt?: Date;
      algorithmMetadata?: Record<string, any>;
    },
  ): Promise<Recommendation> {
    try {
      const recommendation = this.recommendationRepo.create({
        userId,
        recommendationType,
        title,
        description,
        targetId: options?.targetId,
        targetType: options?.targetType,
        potentialSavings: options?.potentialSavings,
        priority: options?.priority || 'medium',
        expiresAt: options?.expiresAt,
        algorithmMetadata: options?.algorithmMetadata,
        isActive: true,
        isClicked: false,
        isConverted: false,
      });

      return await this.recommendationRepo.save(recommendation);
    } catch (error) {
      this.logger.error(
        `Failed to create recommendation for user ${userId}:`,
        error,
      );
      throw error;
    }
  }

  /**
   * Get user recommendations
   */
  async getUserRecommendations(
    userId: string,
    filters?: {
      type?: string;
      active?: boolean;
      clicked?: boolean;
      converted?: boolean;
      priority?: 'low' | 'medium' | 'high';
      limit?: number;
      offset?: number;
    },
  ): Promise<{ data: Recommendation[]; total: number }> {
    try {
      let query = this.recommendationRepo
        .createQueryBuilder('rec')
        .where('rec.userId = :userId', { userId });

      if (filters?.type) {
        query = query.andWhere('rec.recommendationType = :type', {
          type: filters.type,
        });
      }

      if (filters?.active !== undefined) {
        query = query.andWhere('rec.isActive = :isActive', {
          isActive: filters.active,
        });
      }

      if (filters?.clicked !== undefined) {
        query = query.andWhere('rec.isClicked = :isClicked', {
          isClicked: filters.clicked,
        });
      }

      if (filters?.converted !== undefined) {
        query = query.andWhere('rec.isConverted = :isConverted', {
          isConverted: filters.converted,
        });
      }

      if (filters?.priority) {
        query = query.andWhere('rec.priority = :priority', {
          priority: filters.priority,
        });
      }

      const limit = filters?.limit || 20;
      const offset = filters?.offset || 0;

      const [data, total] = await Promise.all([
        query
          .orderBy('rec.priority', 'DESC')
          .addOrderBy('rec.createdAt', 'DESC')
          .take(limit)
          .skip(offset)
          .getMany(),
        query.getCount(),
      ]);

      return { data, total };
    } catch (error) {
      this.logger.error(
        `Failed to get recommendations for user ${userId}:`,
        error,
      );
      throw error;
    }
  }

  /**
   * Mark recommendation as clicked
   */
  async markAsClicked(recommendationId: string): Promise<Recommendation> {
    try {
      const rec = await this.recommendationRepo.findOne({
        where: { id: recommendationId },
      });

      if (!rec) {
        throw new Error(`Recommendation ${recommendationId} not found`);
      }

      rec.isClicked = true;
      rec.clickedAt = new Date();
      rec.displayCount += 1;

      return await this.recommendationRepo.save(rec);
    } catch (error) {
      this.logger.error(`Failed to mark recommendation as clicked:`, error);
      throw error;
    }
  }

  /**
   * Mark recommendation as converted
   */
  async markAsConverted(recommendationId: string): Promise<Recommendation> {
    try {
      const rec = await this.recommendationRepo.findOne({
        where: { id: recommendationId },
      });

      if (!rec) {
        throw new Error(`Recommendation ${recommendationId} not found`);
      }

      rec.isConverted = true;
      rec.convertedAt = new Date();

      return await this.recommendationRepo.save(rec);
    } catch (error) {
      this.logger.error(
        `Failed to mark recommendation as converted:`,
        error,
      );
      throw error;
    }
  }

  /**
   * Get recommendation performance metrics
   */
  async getPerformanceMetrics(
    userId: string,
  ): Promise<Record<string, any>> {
    try {
      const total = await this.recommendationRepo.count({
        where: { userId },
      });

      const clicked = await this.recommendationRepo.count({
        where: { userId, isClicked: true },
      });

      const converted = await this.recommendationRepo.count({
        where: { userId, isConverted: true },
      });

      const totalSavings = await this.recommendationRepo
        .createQueryBuilder('rec')
        .select('SUM(rec.potentialSavings)', 'totalSavings')
        .where('rec.userId = :userId', { userId })
        .andWhere('rec.isConverted = :isConverted', { isConverted: true })
        .getRawOne();

      const ctRate = total > 0 ? (clicked / total) * 100 : 0;
      const conversionRate = clicked > 0 ? (converted / clicked) * 100 : 0;

      return {
        total,
        clicked,
        converted,
        clickThroughRate: parseFloat(ctRate.toFixed(2)),
        conversionRate: parseFloat(conversionRate.toFixed(2)),
        totalSavingsFromConversions: totalSavings?.totalSavings || 0,
      };
    } catch (error) {
      this.logger.error(`Failed to get performance metrics for user ${userId}:`, error);
      throw error;
    }
  }

  /**
   * Deactivate expired recommendations
   */
  async deactivateExpiredRecommendations(): Promise<number> {
    try {
      const result = await this.recommendationRepo
        .createQueryBuilder()
        .update(Recommendation)
        .set({ isActive: false })
        .where('expiresAt < NOW()')
        .andWhere('isActive = :isActive', { isActive: true })
        .execute();

      this.logger.log(
        `Deactivated ${result.affected} expired recommendations`,
      );
      return result.affected || 0;
    } catch (error) {
      this.logger.error(`Failed to deactivate expired recommendations:`, error);
      throw error;
    }
  }

  /**
   * Get top recommendations by type
   */
  async getTopRecommendationsByType(
    recommendationType: string,
    limit = 10,
  ): Promise<Recommendation[]> {
    try {
      return await this.recommendationRepo
        .createQueryBuilder('rec')
        .where('rec.recommendationType = :type', {
          type: recommendationType,
        })
        .andWhere('rec.isActive = :isActive', { isActive: true })
        .orderBy('rec.priority', 'DESC')
        .addOrderBy('rec.displayCount', 'DESC')
        .take(limit)
        .getMany();
    } catch (error) {
      this.logger.error(
        `Failed to get top recommendations by type ${recommendationType}:`,
        error,
      );
      throw error;
    }
  }
}
