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

/**
 * User Entity - Represents all users in the AfriGo platform
 * Supports multiple roles (supplier, buyer, exporter, etc)
 * Immutable audit trail via soft delete + timestamps
 */
@Entity('users')
@Index(['email'], { unique: true })
@Index(['phone'], { unique: true, where: 'phone IS NOT NULL' })
@Index(['firebaseUid'], { unique: true, where: 'firebaseUid IS NOT NULL' })
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
    type: 'enum',
    enum: ['pending', 'verified', 'rejected', 'expired'],
    default: 'pending',
  })
  kycStatus: string;

  /**
   * User account status
   * Values: active, suspended, banned
   */
  @Column({
    type: 'enum',
    enum: ['active', 'suspended', 'banned'],
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
  @Column({ type: 'timestamptz', nullable: true })
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

  /**
   * Created timestamp (immutable)
   */
  @CreateDateColumn({ type: 'timestamptz' })
  createdAt: Date;

  /**
   * Updated timestamp (changes on every update)
   */
  @UpdateDateColumn({ type: 'timestamptz' })
  updatedAt: Date;

  /**
   * Soft Delete timestamp
   * Enables audit trail without losing data
   * NULL = active, has timestamp = deleted
   */
  @DeleteDateColumn({ type: 'timestamptz', nullable: true })
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
