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

@Entity('user_activity_logs')
@Index(['userId', 'timestamp'])
@Index(['activityType', 'timestamp'])
@Index(['timestamp'])
export class UserActivityLog {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('uuid')
  userId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column('varchar', { length: 50 })
  activityType: string;
  // login, logout, create_lot, update_lot, delete_lot, submit_bid, accept_bid,
  // place_order, cancel_order, submit_payment, complete_payment, send_message,
  // submit_review, create_dispute, resolve_dispute, etc.

  @CreateDateColumn()
  timestamp: Date;

  @Column('varchar', { length: 45, nullable: true })
  ipAddress: string;

  @Column('text', { nullable: true })
  userAgent: string;

  @Column('jsonb', { nullable: true })
  deviceInfo: {
    os?: string;
    browser?: string;
    browserVersion?: string;
    deviceType?: string; // mobile, tablet, desktop
    appVersion?: string;
  };

  @Column('jsonb', { nullable: true })
  location: {
    latitude?: number;
    longitude?: number;
    country?: string;
    city?: string;
  };

  @Column('jsonb', { nullable: true })
  actionData: Record<string, any>;
  // lot_id, amount, bid_id, order_id, message_id, etc.

  @Column('jsonb', { nullable: true })
  metadata: Record<string, any>;
}
