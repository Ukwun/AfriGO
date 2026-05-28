import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Cohort } from '../entities/cohort.entity';

/**
 * Cohort Service
 * Manages cohort creation, analysis, and member management
 */
@Injectable()
export class CohortService {
  private readonly logger = new Logger(CohortService.name);

  constructor(
    @InjectRepository(Cohort)
    private cohortRepo: Repository<Cohort>,
  ) {}

  /**
   * Create a new cohort
   */
  async createCohort(
    name: string,
    cohortType: string,
    startDate: Date,
    options?: {
      description?: string;
      endDate?: Date;
      criteria?: Record<string, any>;
      metadata?: Record<string, any>;
    },
  ): Promise<Cohort> {
    try {
      const cohort = this.cohortRepo.create({
        name,
        cohortType,
        startDate,
        endDate: options?.endDate,
        description: options?.description,
        criteria: options?.criteria,
        metadata: options?.metadata,
        status: 'active',
        memberCount: 0,
      });

      return await this.cohortRepo.save(cohort);
    } catch (error) {
      this.logger.error(`Failed to create cohort:`, error);
      throw error;
    }
  }

  /**
   * Get cohort by ID
   */
  async getCohortById(id: string): Promise<Cohort | null> {
    try {
      return await this.cohortRepo.findOne({
        where: { id },
        relations: ['users'],
      });
    } catch (error) {
      this.logger.error(`Failed to get cohort ${id}:`, error);
      throw error;
    }
  }

  /**
   * Get all cohorts with filters
   */
  async getCohorts(filters?: {
    status?: 'active' | 'paused' | 'archived';
    cohortType?: string;
    limit?: number;
    offset?: number;
  }): Promise<{ data: Cohort[]; total: number }> {
    try {
      let query = this.cohortRepo.createQueryBuilder('cohort');

      if (filters?.status) {
        query = query.andWhere('cohort.status = :status', {
          status: filters.status,
        });
      }

      if (filters?.cohortType) {
        query = query.andWhere('cohort.cohortType = :cohortType', {
          cohortType: filters.cohortType,
        });
      }

      const limit = filters?.limit || 20;
      const offset = filters?.offset || 0;

      const [data, total] = await Promise.all([
        query
          .orderBy('cohort.createdAt', 'DESC')
          .take(limit)
          .skip(offset)
          .getMany(),
        query.getCount(),
      ]);

      return { data, total };
    } catch (error) {
      this.logger.error(`Failed to get cohorts:`, error);
      throw error;
    }
  }

  /**
   * Update cohort
   */
  async updateCohort(
    id: string,
    updates: Partial<Cohort>,
  ): Promise<Cohort> {
    try {
      await this.cohortRepo.update({ id }, updates);
      return (await this.cohortRepo.findOne({ where: { id } })) as Cohort;
    } catch (error) {
      this.logger.error(`Failed to update cohort ${id}:`, error);
      throw error;
    }
  }

  /**
   * Update cohort member count
   */
  async updateMemberCount(id: string, memberCount: number): Promise<void> {
    try {
      await this.cohortRepo.update({ id }, { memberCount });
    } catch (error) {
      this.logger.error(`Failed to update member count for cohort ${id}:`, error);
      throw error;
    }
  }

  /**
   * Update cohort metrics
   */
  async updateCohortMetrics(
    id: string,
    metrics: {
      avgSpending?: number;
      avgSessionMinutes?: number;
      retentionRate?: number;
      churnRate?: number;
      conversionRate?: number;
      totalTransactions?: number;
      cohortRevenue?: number;
    },
  ): Promise<Cohort> {
    try {
      const updates: any = {
        lastCalculatedAt: new Date(),
        ...metrics,
      };

      await this.cohortRepo.update({ id }, updates);
      return (await this.cohortRepo.findOne({ where: { id } })) as Cohort;
    } catch (error) {
      this.logger.error(`Failed to update cohort metrics for ${id}:`, error);
      throw error;
    }
  }

  /**
   * Get cohort performance comparison
   */
  async compareCohortPerformance(
    cohortIds: string[],
  ): Promise<Record<string, any>[]> {
    try {
      const cohorts = await this.cohortRepo
        .createQueryBuilder('cohort')
        .whereInIds(cohortIds)
        .getMany();

      return cohorts.map((cohort) => ({
        id: cohort.id,
        name: cohort.name,
        memberCount: cohort.memberCount,
        avgSpending: cohort.avgSpending,
        avgSessionMinutes: cohort.avgSessionMinutes,
        retentionRate: cohort.retentionRate,
        conversionRate: cohort.conversionRate,
        cohortRevenue: cohort.cohortRevenue,
      }));
    } catch (error) {
      this.logger.error(`Failed to compare cohort performance:`, error);
      throw error;
    }
  }

  /**
   * Archive cohort
   */
  async archiveCohort(id: string): Promise<Cohort> {
    try {
      return await this.updateCohort(id, { status: 'archived' });
    } catch (error) {
      this.logger.error(`Failed to archive cohort ${id}:`, error);
      throw error;
    }
  }

  /**
   * Get cohort retention curve
   */
  async getCohortRetentionCurve(
    cohortId: string,
  ): Promise<Record<string, number>> {
    try {
      const cohort = await this.getCohortById(cohortId);
      if (!cohort) {
        throw new Error(`Cohort ${cohortId} not found`);
      }

      // This would typically involve analyzing user activity over time
      // For now, returning structure with sample data
      return {
        day0: cohort.memberCount,
        day7: Math.floor(cohort.memberCount * 0.85),
        day14: Math.floor(cohort.memberCount * 0.75),
        day30: Math.floor(cohort.memberCount * 0.65),
        retentionRate: cohort.retentionRate || 0,
      };
    } catch (error) {
      this.logger.error(
        `Failed to get cohort retention curve for ${cohortId}:`,
        error,
      );
      throw error;
    }
  }
}
