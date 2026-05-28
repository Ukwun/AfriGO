import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  Index,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../../database/entities/user.entity';

@Entity('user_activity_logs')
@Index(['userId', 'createdAt'], { order: { createdAt: 'DESC' } })
@Index(['activityType', 'createdAt'])
export class UserActivityLog {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('uuid')
  userId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;

  // Activity type for categorization
  @Column('varchar', { length: 50 })
  activityType:
    | 'LOGIN'
    | 'LOGOUT'
    | 'CREATE_LOT'
    | 'LIST_LOT'
    | 'CREATE_RFQ'
    | 'SUBMIT_BID'
    | 'ACCEPT_TRADE'
    | 'PAYMENT_INITIATED'
    | 'PAYMENT_CONFIRMED'
    | 'SHIPMENT_CREATED'
    | 'DELIVERY_CONFIRMED'
    | 'DISPUTE_FILED'
    | 'PROFILE_UPDATED'
    | 'KYC_SUBMITTED'
    | 'MESSAGE_SENT';

  // HTTP metadata
  @Column('varchar', { length: 45, nullable: true })
  ipAddress?: string;

  @Column('text', { nullable: true })
  userAgent?: string;

  // Device info (parsed from user agent)
  @Column('jsonb', { default: {} })
  deviceInfo: {
    os?: string;
    browser?: string;
    deviceType?: string;
  };

  // Geographic location (if available via GeoIP)
  @Column('jsonb', { nullable: true })
  location?: {
    country?: string;
    city?: string;
    latitude?: number;
    longitude?: number;
    timezone?: string;
  };

  // What data was affected by this action
  @Column('jsonb', { default: {} })
  actionData: {
    lotId?: string;
    tradeId?: string;
    amount?: number;
    currency?: string;
    status?: string;
    targetUserId?: string;
    notes?: string;
  };

  // For anomaly detection
  @Column('boolean', { default: false })
  isAnomalous: boolean;

  @Column('varchar', { length: 100, nullable: true })
  anomalyType?: string; // 'unusual_location', 'spike_activity', 'large_transaction', etc

  @Column('decimal', { precision: 5, scale: 2, default: 0 })
  anomalyScore: number; // 0-100, how anomalous is this activity

  // Timestamp
  @CreateDateColumn()
  createdAt: Date;

  @Column('bigint')
  timestamp: number; // Unix timestamp for sorting
}
