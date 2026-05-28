import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { User } from '../../auth/entities/user.entity';

@Entity('analytics_summaries')
@Index(['userId', 'period'])
@Index(['period'])
export class AnalyticsSummary {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('uuid')
  userId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column('varchar', { length: 20 })
  period: 'daily' | 'weekly' | 'monthly' | 'yearly';

  @Column('date')
  periodStartDate: Date;

  @Column('date')
  periodEndDate: Date;

  // User Engagement Metrics
  @Column('integer', { default: 0 })
  sessionCount: number;

  @Column('integer', { default: 0 })
  totalSessionMinutes: number;

  @Column('decimal', { precision: 10, scale: 2, default: 0 })
  avgSessionMinutes: number;

  @Column('integer', { default: 0 })
  pageViewCount: number;

  @Column('integer', { default: 0 })
  uniquePageCount: number;

  // Transaction Metrics
  @Column('integer', { default: 0 })
  transactionCount: number;

  @Column('decimal', { precision: 15, scale: 2, default: 0 })
  totalSpent: number;

  @Column('decimal', { precision: 15, scale: 2, default: 0 })
  totalSavings: number;

  @Column('decimal', { precision: 15, scale: 2, default: 0 })
  avgTransactionValue: number;

  // Product Interaction
  @Column('integer', { default: 0 })
  productViewCount: number;

  @Column('integer', { default: 0 })
  uniqueProductsViewed: number;

  @Column('integer', { default: 0 })
  cartAdditionCount: number;

  @Column('integer', { default: 0 })
  conversionCount: number;

  @Column('decimal', { precision: 10, scale: 4, default: 0 })
  conversionRate: number;

  // Customer Satisfaction
  @Column('decimal', { precision: 3, scale: 2, nullable: true })
  avgRating: number;

  @Column('integer', { default: 0 })
  reviewCount: number;

  // Behavior Scores
  @Column('integer', { default: 0 })
  loyaltyScore: number;

  @Column('integer', { default: 0 })
  engagementScore: number;

  @Column('integer', { default: 0 })
  trustScore: number;

  @Column('integer', { default: 0 })
  healthScore: number;

  // Device & Traffic Info
  @Column('jsonb', { default: {} })
  deviceBreakdown: Record<string, number>;
  // { 'mobile': 45, 'desktop': 55, 'tablet': 0 }

  @Column('jsonb', { default: {} })
  trafficSourceBreakdown: Record<string, number>;
  // { 'organic': 60, 'direct': 25, 'referral': 10, 'paid': 5 }

  @Column('jsonb', { default: {} })
  topCategories: Record<string, number>;
  // { 'electronics': 150, 'clothing': 120, 'home': 80 }

  // Anomalies & Alerts
  @Column('integer', { default: 0 })
  anomalyCount: number;

  @Column('integer', { default: 0 })
  highSeverityAnomalyCount: number;

  // Recommendations
  @Column('integer', { default: 0 })
  recommendationsShown: number;

  @Column('integer', { default: 0 })
  recommendationsClicked: number;

  @Column('integer', { default: 0 })
  recommendationsConverted: number;

  @Column('decimal', { precision: 10, scale: 4, default: 0 })
  recommendationConversionRate: number;

  // Cohort & Segment Info
  @Column('uuid', { nullable: true })
  cohortId: string;

  @Column('varchar', { length: 100, nullable: true })
  primarySegment: string;

  @Column('varchar', { length: 1000 })
  tags: string;
  // Comma-separated tags for quick filtering

  @CreateDateColumn()
  createdAt: Date;

  @Column('timestamptz')
  calculatedAt: Date;

  @Column('jsonb', { nullable: true })
  metadata: Record<string, any>;
}
