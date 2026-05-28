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

@Entity('behavioral_anomalies')
@Index(['userId', 'severity'])
@Index(['detectedAt'])
@Index(['isReviewed'])
export class BehavioralAnomaly {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('uuid')
  userId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column('varchar', { length: 100 })
  anomalyType: string;
  // unusual_location, spike_activity, large_transaction, velocity_check,
  // chargeback_pattern, duplicate_accounts, document_tampering, etc.

  @Column('varchar', { length: 20 })
  severity: 'low' | 'medium' | 'high' | 'critical';

  @CreateDateColumn()
  detectedAt: Date;

  @Column('text', { nullable: true })
  description: string;

  @Column('jsonb', { nullable: true })
  details: Record<string, any>;

  @Column('boolean', { default: false })
  isReviewed: boolean;

  @Column('uuid', { nullable: true })
  reviewerId: string;

  @ManyToOne(() => User, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'reviewerId' })
  reviewer?: User;

  @Column('varchar', { length: 100, nullable: true })
  actionTaken: 'blocked' | 'flagged' | 'ignored' | 'verified_safe' | null;

  @Column('timestamptz', { nullable: true })
  reviewedAt?: Date;
}
