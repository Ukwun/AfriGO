import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { User } from '../auth/entities/user.entity';

/**
 * UserActivity Entity - Immutable audit log for all user actions
 * 
 * Tracks:
 * - Screen views & navigation
 * - Button clicks & actions
 * - Lot searches & views
 * - Bid submissions
 * - Order creation
 * - Payment actions
 * - Contract actions
 * - Shipment tracking
 * - Disputes
 * - Error events
 * - API calls
 * - Login/logout
 * 
 * Purpose:
 * - Analytics (understand user behavior patterns)
 * - Fraud detection (identify suspicious patterns)
 * - Performance monitoring (track API latencies)
 * - User intelligence (build user profiles)
 * - Debugging (reproduce issues)
 */
@Entity('user_activities')
@Index(['userId', 'timestamp'])
@Index(['eventType', 'timestamp'])
@Index(['userId', 'eventType'])
export class UserActivity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  /**
   * User who performed the action
   */
  @Column('uuid')
  userId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;

  /**
   * Type of event (screen, action, error, etc.)
   * Examples: 'screen_view', 'lot_search', 'lot_click', 'bid_submit', 'payment_initiate', 'login', 'logout', 'error'
   */
  @Column('varchar', { length: 100 })
  eventType: string;

  /**
   * Specific event action
   * Examples: 'view_lot_details', 'search_lots', 'submit_bid', 'initiate_payment'
   */
  @Column('varchar', { length: 200 })
  action: string;

  /**
   * Contextual data (JSON)
   * Stores specific information about the event
   * 
   * Examples:
   * { "lotId": "abc123", "searchQuery": "cocoa" }
   * { "amount": 5000, "currency": "USD", "status": "success" }
   * { "screenName": "buyer_dashboard", "duration": 45000 }
   */
  @Column('simple-json', { nullable: true })
  data?: Record<string, any>;

  /**
   * For API calls: endpoint that was called
   * Example: 'POST /api/lots/search'
   */
  @Column('varchar', { length: 200, nullable: true })
  endpoint?: string;

  /**
   * Response status (200, 404, 500, etc.)
   */
  @Column('int', { nullable: true })
  statusCode?: number;

  /**
   * Response time in milliseconds
   */
  @Column('int', { nullable: true })
  responseTime?: number;

  /**
   * Device information (mobile, web)
   */
  @Column('varchar', { length: 50, nullable: true })
  deviceType?: string;

  /**
   * App version or browser version
   */
  @Column('varchar', { length: 50, nullable: true })
  appVersion?: string;

  /**
   * User's IP address
   */
  @Column('varchar', { length: 45, nullable: true })
  ipAddress?: string;

  /**
   * User's geographic location (country, city)
   */
  @Column('varchar', { length: 100, nullable: true })
  location?: string;

  /**
   * For error events: error message
   */
  @Column('text', { nullable: true })
  errorMessage?: string;

  /**
   * For error events: error stack trace
   */
  @Column('text', { nullable: true })
  errorStackTrace?: string;

  /**
   * Session ID (for grouping related activities)
   */
  @Column('varchar', { length: 100, nullable: true })
  sessionId?: string;

  /**
   * Timestamp when activity occurred (auto-set)
   */
  @CreateDateColumn()
  timestamp: Date;

  /**
   * Anomaly score (0-100) - higher = more suspicious
   * Calculated by fraud detection algorithm
   */
  @Column('int', { default: 0 })
  anomalyScore: number;

  /**
   * Is this activity flagged for review?
   */
  @Column('boolean', { default: false })
  isFlagged: boolean;

  /**
   * Reason if flagged (fraud, error, etc.)
   */
  @Column('varchar', { length: 200, nullable: true })
  flagReason?: string;
}
