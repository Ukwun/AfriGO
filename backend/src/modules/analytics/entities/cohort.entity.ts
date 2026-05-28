import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
  ManyToMany,
  JoinTable,
} from 'typeorm';
import { User } from '../../auth/entities/user.entity';

@Entity('cohorts')
@Index(['name'])
@Index(['status'])
@Index(['createdAt'])
export class Cohort {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('varchar', { length: 255 })
  name: string;

  @Column('text', { nullable: true })
  description: string;

  @Column('varchar', { length: 50 })
  status: 'active' | 'paused' | 'archived';

  @Column('varchar', { length: 100 })
  cohortType: string;
  // signup_period (users who joined in Q1 2024),
  // behavior_based (high-spending power users),
  // loyalty_tier (platinum members),
  // geographic (US east coast),
  // product_affinity (electronics buyers),
  // acquisition_source (organic search),
  // engagement_level (highly engaged),
  // lifecycle_stage (churning users)

  @Column('date')
  startDate: Date;

  @Column('date', { nullable: true })
  endDate?: Date;

  @Column('integer', { default: 0 })
  memberCount: number;

  // Cohort Definition Criteria
  @Column('jsonb', { nullable: true })
  criteria: Record<string, any>;
  // Flexible criteria storage for various cohort types
  // e.g., { "joinDate": { "start": "2024-01-01", "end": "2024-03-31" },
  //        "totalSpent": { "min": 1000 } }

  // Performance Metrics
  @Column('decimal', { precision: 10, scale: 2, nullable: true })
  avgSpending: number;

  @Column('decimal', { precision: 10, scale: 2, nullable: true })
  avgSessionMinutes: number;

  @Column('decimal', { precision: 10, scale: 4, nullable: true })
  retentionRate: number;

  @Column('decimal', { precision: 10, scale: 4, nullable: true })
  churnRate: number;

  @Column('decimal', { precision: 10, scale: 4, nullable: true })
  conversionRate: number;

  @Column('integer', { default: 0 })
  totalTransactions: number;

  @Column('decimal', { precision: 15, scale: 2, default: 0 })
  cohortRevenue: number;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @Column('timestamptz', { nullable: true })
  lastCalculatedAt?: Date;

  @Column('jsonb', { nullable: true })
  metadata: Record<string, any>;

  @ManyToMany(() => User, (user) => user.cohorts, { onDelete: 'CASCADE' })
  @JoinTable({
    name: 'cohort_members',
    joinColumn: { name: 'cohortId', referencedColumnName: 'id' },
    inverseJoinColumn: { name: 'userId', referencedColumnName: 'id' },
  })
  users: User[];
}
