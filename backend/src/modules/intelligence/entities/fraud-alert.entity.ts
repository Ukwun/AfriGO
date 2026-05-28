import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../../database/entities/user.entity';

@Entity('fraud_alerts')
@Index(['userId', 'createdAt'], { order: { createdAt: 'DESC' } })
@Index(['severity', 'isResolved'])
export class FraudAlert {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('uuid')
  userId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;

  // What kind of fraud flag
  @Column('varchar', { length: 50 })
  fraudType:
    | 'UNUSUAL_LOCATION'
    | 'SPIKE_ACTIVITY'
    | 'LARGE_TRANSACTION'
    | 'PAYMENT_REVERSAL'
    | 'RAPID_TRADES'
    | 'DISPUTE_ABUSE'
    | 'ACCOUNT_TAKEOVER'
    | 'KYC_MISMATCH'
    | 'MANUAL_FLAG';

  // How serious is it
  @Column('varchar', { length: 20 })
  severity: 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';

  // Machine learning fraud score (0-100)
  @Column('decimal', { precision: 5, scale: 2 })
  fraudScore: number;

  // What evidence triggered this
  @Column('jsonb')
  evidence: {
    flag1?: string;
    flag2?: string;
    flag3?: string;
    details?: Record<string, any>;
  };

  // What happened (for context)
  @Column('jsonb', { nullable: true })
  context?: {
    previousLocation?: string;
    currentLocation?: string;
    previousTradeAmount?: number;
    currentTradeAmount?: number;
    tradesInLastHour?: number;
    averageMonthlyTrades?: number;
    recentPaymentReversals?: number;
  };

  // Status
  @Column('varchar', { length: 20 }, { default: 'PENDING' })
  status: 'PENDING' | 'REVIEWING' | 'RESOLVED' | 'DISMISSED';

  @Column('boolean', { default: false })
  isResolved: boolean;

  // Admin review
  @Column('uuid', { nullable: true })
  reviewedBy?: string; // Admin who reviewed

  @Column('text', { nullable: true })
  adminNotes?: string;

  @Column('varchar', { length: 50, nullable: true })
  action?: 'NONE' | 'WARNING' | 'MANUAL_REVIEW' | 'TRANSACTION_BLOCK' | 'ACCOUNT_SUSPEND';

  // Timestamps
  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @Column('timestamp', { nullable: true })
  resolvedAt?: Date;

  // Related transaction (if any)
  @Column('uuid', { nullable: true })
  relatedTransactionId?: string;

  @Column('uuid', { nullable: true })
  relatedTradeId?: string;

  // Should this be escalated to manual review
  @Column('boolean', { default: false })
  requiresManualReview: boolean;
}
