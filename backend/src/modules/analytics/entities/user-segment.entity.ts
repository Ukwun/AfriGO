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

@Entity('user_segments')
@Index(['name'])
@Index(['segmentType'])
@Index(['status'])
@Index(['createdAt'])
export class UserSegment {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('varchar', { length: 255 })
  name: string;

  @Column('text', { nullable: true })
  description: string;

  @Column('varchar', { length: 50 })
  segmentType: string;
  // demographic (age_group, location), behavioral (power_user, browser),
  // value_based (high_lifetime_value, budget_conscious),
  // lifecycle (new_user, at_risk, loyal), product_interest,
  // engagement_level, acquisition_source, device_type

  @Column('varchar', { length: 50 })
  status: 'active' | 'paused' | 'archived';

  @Column('integer', { default: 0 })
  memberCount: number;

  // Segment Definition
  @Column('jsonb')
  rules: Record<string, any>;
  // Flexible rules JSON for defining segment membership
  // e.g., { "totalSpent": { "min": 500, "max": 5000 },
  //        "accountAge": { "min": 30 },
  //        "locations": ["US", "CA"],
  //        "devices": ["mobile", "web"]
  //      }

  @Column('integer', { nullable: true })
  priority: number;
  // Priority order for assigning users to segments (in case of overlap)

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @Column('timestamptz', { nullable: true })
  lastEvaluatedAt?: Date;

  // Segment Performance
  @Column('decimal', { precision: 10, scale: 2, nullable: true })
  avgValue: number;

  @Column('decimal', { precision: 10, scale: 2, nullable: true })
  totalValue: number;

  @Column('integer', { nullable: true })
  avgLifetimeValue: number;

  @Column('decimal', { precision: 10, scale: 4, nullable: true })
  retentionRate: number;

  @Column('decimal', { precision: 10, scale: 4, nullable: true })
  churnRate: number;

  @Column('decimal', { precision: 10, scale: 4, nullable: true })
  conversionRate: number;

  // Engagement Metrics
  @Column('decimal', { precision: 10, scale: 2, nullable: true })
  avgSessionMinutes: number;

  @Column('integer', { nullable: true })
  monthlySessionCount: number;

  @Column('integer', { nullable: true })
  monthlyTransactionCount: number;

  // Associated Data
  @Column('jsonb', { nullable: true })
  characteristicTags: string[];
  // Array of descriptive tags: ['budget-conscious', 'mobile-first', 'tech-savvy']

  @Column('jsonb', { nullable: true })
  topProductCategories: Record<string, number>;
  // { 'electronics': 45, 'home': 30, 'clothing': 25 }

  @Column('jsonb', { nullable: true })
  preferredChannels: Record<string, number>;
  // { 'email': 60, 'push': 25, 'sms': 15 }

  @Column('boolean', { default: false })
  autoUpdate: boolean;
  // Whether to automatically update membership based on rules

  @Column('jsonb', { nullable: true })
  metadata: Record<string, any>;

  @ManyToMany(() => User, (user) => user.segments, { onDelete: 'CASCADE' })
  @JoinTable({
    name: 'segment_members',
    joinColumn: { name: 'segmentId', referencedColumnName: 'id' },
    inverseJoinColumn: { name: 'userId', referencedColumnName: 'id' },
  })
  users: User[];
}
