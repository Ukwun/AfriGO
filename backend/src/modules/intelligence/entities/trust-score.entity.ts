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

@Entity('trust_scores')
@Index(['userId', 'calculatedAt'], { order: { calculatedAt: 'DESC' } })
export class TrustScore {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('uuid')
  userId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;

  // Score breakdown (0-100)
  @Column('int', { default: 40 })
  baseScore: number;

  @Column('int', { default: 0 })
  transactionPoints: number;

  @Column('int', { default: 0 })
  profilePoints: number;

  @Column('int', { default: 0 })
  behaviorBonusPoints: number;

  @Column('int', { default: 0 })
  penaltyPoints: number;

  // Final calculated score
  @Column('int')
  totalScore: number;

  // Star rating (0-5 stars)
  @Column('decimal', { precision: 3, scale: 2 })
  starRating: number;

  // Component breakdown (JSON for detailed analysis)
  @Column('jsonb', { default: {} })
  components: {
    completedTrades?: number;
    emailVerified?: boolean;
    phoneVerified?: boolean;
    kyc?: 'pending' | 'verified' | 'rejected';
    responseTime?: number; // in minutes
    disputes?: number;
    latePayments?: number;
  };

  // Trust level classification
  @Column('varchar', { length: 20, default: 'NEUTRAL' })
  trustLevel:
    | 'CRITICAL'
    | 'LOW'
    | 'NEUTRAL'
    | 'GOOD'
    | 'EXCELLENT'
    | 'SUSPENDED';

  // When was this calculated
  @CreateDateColumn()
  calculatedAt: Date;

  // Manual override (admin can set flags)
  @Column('varchar', { length: 20, nullable: true })
  manualFlag?: 'VERIFIED' | 'FLAGGED' | 'SUSPENDED' | 'APPROVED';

  @Column('text', { nullable: true })
  flagReason?: string;

  @Column('uuid', { nullable: true })
  flaggedBy?: string; // Admin who flagged

  @CreateDateColumn({ nullable: true })
  flaggedAt?: Date;
}
