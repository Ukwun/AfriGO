import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  Index,
} from 'typeorm';
import { User } from './user.entity';

/**
 * VerificationToken Entity
 * Used for: Email verification, phone verification, password reset
 *
 * Flow:
 * 1. User registers with email → create token
 * 2. Send token to user (via email or SMS)
 * 3. User verifies token
 * 4. Mark user as verified, delete token
 */
@Entity('verification_tokens')
@Index(['token'], { unique: true })
@Index(['userId', 'type'])
export class VerificationToken {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  /**
   * Foreign key to user
   */
  @Column({ type: 'uuid' })
  userId: string;

  /**
   * The actual token value
   * Generated as random 6-8 digit code (for SMS) or 32-char token (for email links)
   * Example: '123456' (email) or 'abc123def456ghi789jkl012mno345p' (email link)
   */
  @Column({ type: 'varchar', length: 255 })
  token: string;

  /**
   * Token type
   * Values: email_verification, phone_verification, password_reset, new_device_verification
   */
  @Column({
    type: 'varchar',
    length: 50,
  })
  type: string;

  /**
   * Email or phone that this token is for
   * Allows verification of new email/phone before updating user record
   */
  @Column({ type: 'varchar', length: 255, nullable: true })
  contactValue: string;

  /**
   * Number of attempts to verify this token
   * Lock account after 5 failed attempts
   */
  @Column({ type: 'int', default: 0 })
  attemptCount: number;

  /**
   * Is this token verified/used?
   */
  @Column({ type: 'boolean', default: false })
  isVerified: boolean;

  /**
   * When does this token expire?
   * Calculated as: createdAt + TTL (15 min for email, 10 min for SMS, 24h for password reset)
   */
  @Column({ type: 'datetime' })
  expiresAt: Date;

  /**
   * When was this token verified/used?
   */
  @Column({ type: 'datetime', nullable: true })
  verifiedAt: Date;

  /**
   * IP address that created this token
   * For security: detect if token created from different location
   */
  @Column({ type: 'varchar', length: 45, nullable: true })
  createdFromIp: string;

  /**
   * User agent that created this token
   * For security: detect if verified from different device
   */
  @Column({ type: 'text', nullable: true })
  createdFromUserAgent: string;

  /**
   * Many-to-One: Token belongs to one user
   */
  @ManyToOne(() => User, (user) => user.verificationTokens, {
    onDelete: 'CASCADE',
  })
  user: User;

  /**
   * Created timestamp
   */
  @CreateDateColumn({ type: 'datetime' })
  createdAt: Date;

  /**
   * Check if token is expired
   */
  isExpired(): boolean {
    return new Date() > this.expiresAt;
  }

  /**
   * Check if token is still valid (not expired, not verified)
   */
  isValid(): boolean {
    return !this.isExpired() && !this.isVerified && this.attemptCount < 5;
  }
}
