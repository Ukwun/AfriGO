import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UserSegment } from '../entities/user-segment.entity';

/**
 * Segment Service
 * Manages user segmentation for targeted marketing and personalization
 */
@Injectable()
export class SegmentService {
  private readonly logger = new Logger(SegmentService.name);

  constructor(
    @InjectRepository(UserSegment)
    private segmentRepo: Repository<UserSegment>,
  ) {}

  /**
   * Create a new user segment
   */
  async createSegment(
    name: string,
    segmentType: string,
    rules: Record<string, any>,
    options?: {
      description?: string;
      priority?: number;
      characteristicTags?: string[];
      preferredChannels?: Record<string, number>;
      autoUpdate?: boolean;
      metadata?: Record<string, any>;
    },
  ): Promise<UserSegment> {
    try {
      const segment = this.segmentRepo.create({
        name,
        segmentType,
        rules,
        description: options?.description,
        priority: options?.priority || 0,
        characteristicTags: options?.characteristicTags,
        preferredChannels: options?.preferredChannels,
        autoUpdate: options?.autoUpdate || false,
        metadata: options?.metadata,
        status: 'active',
        memberCount: 0,
      });

      return await this.segmentRepo.save(segment);
    } catch (error) {
      this.logger.error(`Failed to create segment:`, error);
      throw error;
    }
  }

  /**
   * Get segment by ID
   */
  async getSegmentById(id: string): Promise<UserSegment | null> {
    try {
      return await this.segmentRepo.findOne({
        where: { id },
        relations: ['users'],
      });
    } catch (error) {
      this.logger.error(`Failed to get segment ${id}:`, error);
      throw error;
    }
  }

  /**
   * Get all segments with filters
   */
  async getSegments(filters?: {
    status?: 'active' | 'paused' | 'archived';
    segmentType?: string;
    limit?: number;
    offset?: number;
  }): Promise<{ data: UserSegment[]; total: number }> {
    try {
      let query = this.segmentRepo.createQueryBuilder('segment');

      if (filters?.status) {
        query = query.andWhere('segment.status = :status', {
          status: filters.status,
        });
      }

      if (filters?.segmentType) {
        query = query.andWhere('segment.segmentType = :segmentType', {
          segmentType: filters.segmentType,
        });
      }

      const limit = filters?.limit || 20;
      const offset = filters?.offset || 0;

      const [data, total] = await Promise.all([
        query
          .orderBy('segment.priority', 'ASC')
          .addOrderBy('segment.createdAt', 'DESC')
          .take(limit)
          .skip(offset)
          .getMany(),
        query.getCount(),
      ]);

      return { data, total };
    } catch (error) {
      this.logger.error(`Failed to get segments:`, error);
      throw error;
    }
  }

  /**
   * Update segment
   */
  async updateSegment(
    id: string,
    updates: Partial<UserSegment>,
  ): Promise<UserSegment> {
    try {
      await this.segmentRepo.update({ id }, updates);
      return (await this.segmentRepo.findOne({ where: { id } })) as UserSegment;
    } catch (error) {
      this.logger.error(`Failed to update segment ${id}:`, error);
      throw error;
    }
  }

  /**
   * Update segment member count
   */
  async updateMemberCount(id: string, memberCount: number): Promise<void> {
    try {
      await this.segmentRepo.update(
        { id },
        {
          memberCount,
          lastEvaluatedAt: new Date(),
        },
      );
    } catch (error) {
      this.logger.error(`Failed to update member count for segment ${id}:`, error);
      throw error;
    }
  }

  /**
   * Update segment performance metrics
   */
  async updateSegmentMetrics(
    id: string,
    metrics: {
      avgValue?: number;
      totalValue?: number;
      avgLifetimeValue?: number;
      retentionRate?: number;
      churnRate?: number;
      conversionRate?: number;
      avgSessionMinutes?: number;
      monthlySessionCount?: number;
      monthlyTransactionCount?: number;
    },
  ): Promise<UserSegment> {
    try {
      const updates: any = {
        lastEvaluatedAt: new Date(),
        ...metrics,
      };

      await this.segmentRepo.update({ id }, updates);
      return (await this.segmentRepo.findOne({ where: { id } })) as UserSegment;
    } catch (error) {
      this.logger.error(`Failed to update segment metrics for ${id}:`, error);
      throw error;
    }
  }

  /**
   * Get segment performance summary
   */
  async getSegmentPerformance(id: string): Promise<Record<string, any>> {
    try {
      const segment = await this.getSegmentById(id);
      if (!segment) {
        throw new Error(`Segment ${id} not found`);
      }

      return {
        id: segment.id,
        name: segment.name,
        segmentType: segment.segmentType,
        memberCount: segment.memberCount,
        avgValue: segment.avgValue,
        totalValue: segment.totalValue,
        retentionRate: segment.retentionRate,
        churnRate: segment.churnRate,
        conversionRate: segment.conversionRate,
        avgSessionMinutes: segment.avgSessionMinutes,
        characteristicTags: segment.characteristicTags,
        preferredChannels: segment.preferredChannels,
      };
    } catch (error) {
      this.logger.error(
        `Failed to get segment performance for ${id}:`,
        error,
      );
      throw error;
    }
  }

  /**
   * Compare multiple segments
   */
  async compareSegments(
    segmentIds: string[],
  ): Promise<Record<string, any>[]> {
    try {
      const segments = await this.segmentRepo
        .createQueryBuilder('segment')
        .whereInIds(segmentIds)
        .getMany();

      return segments.map((segment) => ({
        id: segment.id,
        name: segment.name,
        segmentType: segment.segmentType,
        memberCount: segment.memberCount,
        avgValue: segment.avgValue,
        totalValue: segment.totalValue,
        avgLifetimeValue: segment.avgLifetimeValue,
        retentionRate: segment.retentionRate,
        conversionRate: segment.conversionRate,
      }));
    } catch (error) {
      this.logger.error(`Failed to compare segments:`, error);
      throw error;
    }
  }

  /**
   * Archive segment
   */
  async archiveSegment(id: string): Promise<UserSegment> {
    try {
      return await this.updateSegment(id, { status: 'archived' });
    } catch (error) {
      this.logger.error(`Failed to archive segment ${id}:`, error);
      throw error;
    }
  }

  /**
   * Pause segment
   */
  async pauseSegment(id: string): Promise<UserSegment> {
    try {
      return await this.updateSegment(id, { status: 'paused' });
    } catch (error) {
      this.logger.error(`Failed to pause segment ${id}:`, error);
      throw error;
    }
  }

  /**
   * Reactivate segment
   */
  async reactivateSegment(id: string): Promise<UserSegment> {
    try {
      return await this.updateSegment(id, { status: 'active' });
    } catch (error) {
      this.logger.error(`Failed to reactivate segment ${id}:`, error);
      throw error;
    }
  }
}
