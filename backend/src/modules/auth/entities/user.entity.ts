import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  DeleteDateColumn,
  Index,
  ManyToMany,
  JoinTable,
  OneToMany,
} from 'typeorm';
import { UserRole } from './user-role.entity';
import { VerificationToken } from './verification-token.entity';
// import {
//   UserActivity,
//   UserSession,
//   PageView,
//   UserMetric,
//   Event,
//   BehavioralAnomaly,
//   Recommendation,
//   AnalyticsSummary,
// } from '../../analytics/entities';
// import { Cohort } from '../../analytics/entities/cohort.entity';
// import { UserSegment } from '../../analytics/entities/user-segment.entity';

/**
 * User Entity - Represents all users in the AfriGo platform
 * Supports multiple roles (supplier, buyer, exporter, etc)
 * Immutable audit trail via soft delete + timestamps
 */
@Entity('users')
@Index(['email'], { unique: true })
@Index(['phone'], { unique: true })
@Index(['firebaseUid'], { unique: true })
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'varchar', length: 255 })
  email: string;

  @Column({ type: 'varchar', length: 20, nullable: true })
  phone: string;

  @Column({ type: 'varchar', length: 255 })
  firstName: string;

  @Column({ type: 'varchar', length: 255 })
  lastName: string;

  @Column({ type: 'varchar', length: 500, nullable: true })
  profileImageUrl: string;

  /**
   * Hashed password using bcrypt
   * NEVER store plain text passwords
   */
  @Column({ type: 'varchar', length: 255, nullable: true })
  passwordHash: string;

  /**
   * Firebase UID for authentication
   * Links to Firebase Auth system
   */
  @Column({ type: 'varchar', length: 255, nullable: true })
  firebaseUid: string;

  /**
   * KYC/KYB Status
   * Values: pending, verified, rejected, expired
   */
  @Column({
    type: 'varchar',
    length: 20,
    default: 'pending',
  })
  kycStatus: string;

  /**
   * User account status
   * Values: active, suspended, banned
   */
  @Column({
    type: 'varchar',
    length: 20,
    default: 'active',
  })
  accountStatus: string;

  /**
   * Email verification status
   */
  @Column({ type: 'boolean', default: false })
  emailVerified: boolean;

  /**
   * Phone verification status
   */
  @Column({ type: 'boolean', default: false })
  phoneVerified: boolean;

  /**
   * Trust score (0-100): Updated based on transaction history
   * Calculated by: (successful_trades / total_trades) * 100
   * Used for: matching, recommendations, trust assessment
   */
  @Column({ type: 'int', default: 0 })
  trustScore: number;

  /**
   * Engagement score (0-100): Measures user platform engagement
   * Factors: session frequency, page views, interactions
   */
  @Column({ type: 'int', default: 0 })
  engagementScore: number;

  /**
   * Loyalty score (0-100): Measures customer loyalty
   * Factors: repeat purchases, retention, brand affinity
   */
  @Column({ type: 'int', default: 0 })
  loyaltyScore: number;

  /**
   * Total amount spent by user
   * Cumulative across all transactions
   */
  @Column({ type: 'decimal', precision: 15, scale: 2, default: 0 })
  totalSpent: number;

  /**
   * Total savings achieved by user
   * Sum of discounts, rewards, and savings
   */
  @Column({ type: 'decimal', precision: 15, scale: 2, default: 0 })
  totalSavings: number;

  /**
   * Total transaction count
   * Number of completed transactions
   */
  @Column({ type: 'int', default: 0 })
  transactionCount: number;

  /**
   * Number of completed trades
   * Incremented on every successful transaction
   */
  @Column({ type: 'int', default: 0 })
  completedTrades: number;

  /**
   * Number of disputes
   * Flag account if too many disputes
   */
  @Column({ type: 'int', default: 0 })
  disputeCount: number;

  /**
   * Behavioral anomaly count
   * Number of suspicious behaviors detected
   */
  @Column({ type: 'int', default: 0 })
  anomalyCount: number;

  /**
   * Fraud suspicion flag
   * True if user has been flagged as potentially fraudulent
   */
  @Column({ type: 'boolean', default: false })
  isFraudSuspicious: boolean;

  /**
   * Last activity timestamp
   * Updated on any user activity
   */
  @Column({ type: 'datetime', nullable: true })
  lastActivityAt: Date;

  /**
   * User organization/company name
   */
  @Column({ type: 'varchar', length: 500, nullable: true })
  organizationName: string;

  /**
   * Country of origin (ISO 3166-1 alpha-2 code, e.g., 'GH', 'NG', 'KE')
   */
  @Column({ type: 'varchar', length: 2, nullable: true })
  countryCode: string;

  /**
   * User location (city/region)
   */
  @Column({ type: 'varchar', length: 255, nullable: true })
  location: string;

  /**
   * Latitude for mapping
   */
  @Column({ type: 'decimal', precision: 10, scale: 8, nullable: true })
  latitude: number;

  /**
   * Longitude for mapping
   */
  @Column({ type: 'decimal', precision: 11, scale: 8, nullable: true })
  longitude: number;

  /**
   * Preferred language (ISO 639-1 code, e.g., 'en', 'fr', 'yo')
   */
  @Column({ type: 'varchar', length: 5, default: 'en' })
  language: string;

  /**
   * Last login timestamp
   * Used for activity tracking and fraud detection
   */
  @Column({ type: 'datetime', nullable: true })
  lastLoginAt: Date;

  /**
   * IP address of last login
   * Used for security and fraud detection
   */
  @Column({ type: 'varchar', length: 45, nullable: true })
  lastLoginIp: string;

  /**
   * Device/User agent of last login
   * Helps detect compromised accounts
   */
  @Column({ type: 'text', nullable: true })
  lastLoginUserAgent: string;

  /**
   * Many-to-Many: User can have multiple roles
   * Roles determined by kyc_type or manual assignment
   * Examples: supplier, buyer, exporter, logistics, admin
   */
  @ManyToMany(() => UserRole, (role) => role.users, { eager: true })
  @JoinTable({ name: 'user_roles_junction' })
  roles: UserRole[];

  /**
   * One-to-Many: User has many verification tokens
   * Used for email/phone verification, password reset
   */
  @OneToMany(
    () => VerificationToken,
    (token) => token.user,
    { cascade: true },
  )
  verificationTokens: VerificationToken[];

  // =========================================================================
  // ANALYTICS RELATIONSHIPS
  // =========================================================================
  // NOTE: Analytics entity relationships temporarily disabled until entities are created
  
  /**
   * One-to-Many: User's activity tracking
   * Stores detailed activity logs and user interactions
   */
  // @OneToMany(() => UserActivity, (activity: UserActivity) => activity.user, {
  //   cascade: true,
  //   onDelete: 'CASCADE',
  // })
  // activities: UserActivity[];

  /**
   * One-to-Many: User's sessions
   * Tracks user login sessions and durations
   */
  // @OneToMany(() => UserSession, (session: UserSession) => session.user, {
  //   cascade: true,
  //   onDelete: 'CASCADE',
  // })
  // sessions: UserSession[];

  /**
   * One-to-Many: User's page views
   * Tracks which pages the user visits
   */
  // @OneToMany(() => PageView, (pageView: PageView) => pageView.user, {
  //   cascade: true,
  //   onDelete: 'CASCADE',
  // })
  // pageViews: PageView[];

  /**
   * One-to-Many: User's metrics
   * Aggregated metric snapshots for performance tracking
   */
  // @OneToMany(() => UserMetric, (metric: UserMetric) => metric.user, {
  //   cascade: true,
  //   onDelete: 'CASCADE',
  // })
  // metrics: UserMetric[];

  /**
   * One-to-Many: User's events
   * Granular event tracking for analytics
   */
  // @OneToMany(() => Event, (event: Event) => event.user, {
  //   cascade: true,
  //   onDelete: 'CASCADE',
  // })

  /**
   * One-to-Many: User's behavioral anomalies
   * Fraud detection and unusual behavior tracking
   * TEMPORARILY DISABLED for SQLite compatibility - remap to postgres for production
   */
  // @OneToMany(() => BehavioralAnomaly, (anomaly) => anomaly.user, {
  //   cascade: true,
  //   onDelete: 'CASCADE',
  // })
  // anomalies: BehavioralAnomaly[];

  /**
   * One-to-Many: User's recommendations
   * Personalized product and offer recommendations
   * TEMPORARILY DISABLED for SQLite compatibility
   */
  // @OneToMany(() => Recommendation, (rec) => rec.user, {
  //   cascade: true,
  //   onDelete: 'CASCADE',
  // })
  // recommendations: Recommendation[];

  /**
   * One-to-Many: User's analytics summaries
   * Aggregated analytics by time period
   * TEMPORARILY DISABLED for SQLite compatibility
   */
  // @OneToMany(() => AnalyticsSummary, (summary) => summary.user, {
  //   cascade: true,
  //   onDelete: 'CASCADE',
  // })
  // analyticsSummaries: AnalyticsSummary[];

  /**
   * Many-to-Many: User can belong to multiple cohorts
   * For cohort analysis and behavioral studies
   * TEMPORARILY DISABLED for SQLite compatibility
   */
  // @ManyToMany(() => Cohort, (cohort) => cohort.users, { onDelete: 'CASCADE' })
  // cohorts: Cohort[];

  /**
   * Many-to-Many: User can be assigned to multiple segments
   * For customer segmentation and targeting
   * TEMPORARILY DISABLED for SQLite compatibility
   */
  // @ManyToMany(() => UserSegment, (segment) => segment.users, {
  //   onDelete: 'CASCADE',
  // })
  // segments: UserSegment[];

  /**
   * Created timestamp (immutable)
   */
  @CreateDateColumn({ type: 'datetime' })
  createdAt: Date;

  /**
   * Updated timestamp (changes on every update)
   */
  @UpdateDateColumn({ type: 'datetime' })
  updatedAt: Date;

  /**
   * Soft Delete timestamp
   * Enables audit trail without losing data
   * NULL = active, has timestamp = deleted
   */
  @DeleteDateColumn({ type: 'datetime', nullable: true })
  deletedAt: Date;

  // =========================================================================
  // COMPUTED PROPERTIES (not stored in DB, calculated on read)
  // =========================================================================

  /**
   * Full name helper
   */
  get fullName(): string {
    return `${this.firstName} ${this.lastName}`.trim();
  }

  /**
   * Score out of 5 stars (for UI display)
   * Calculated from trustScore (0-100): (trustScore / 100) * 5
   */
  get rating(): number {
    return (this.trustScore / 100) * 5;
  }

  /**
   * Check if user is verified (KYC passed)
   */
  get isVerified(): boolean {
    return this.kycStatus === 'verified';
  }

  /**
   * Check if user is active (not suspended or banned)
   */
  get isActive(): boolean {
    return this.accountStatus === 'active' && !this.deletedAt;
  }
}
