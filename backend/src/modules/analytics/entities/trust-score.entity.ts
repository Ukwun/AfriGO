import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { User } from '../../auth/entities/user.entity';

@Entity('trust_scores')
@Index(['userId'])
@Index(['score'])
export class TrustScore {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('uuid', { unique: true })
  userId: string;

  @OneToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column('smallint', { default: 40 })
  score: number; // 0-100

  @Column('decimal', { precision: 3, scale: 2, default: 0 })
  rating: number; // 0-5 based on reviews

  @Column('integer', { default: 0 })
  completedTrades: number;

  @Column('integer', { default: 0 })
  failedTrades: number;

  @Column('decimal', {
    precision: 15,
    scale: 2,
    default: 0,
  })
  totalTransactionValue: number;

  @Column('jsonb', { nullable: true })
  components: {
    transactionHistory?: number; // 40%
    reputation?: number; // 30%
    verification?: number; // 20%
    platformAge?: number; // 10%
  };

  @CreateDateColumn()
  calculatedAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  // Calculated fields (not persisted)
  getSuccessRate(): number {
    const total = this.completedTrades + this.failedTrades;
    if (total === 0) return 0;
    return Math.round((this.completedTrades / total) * 100);
  }

  getAverageOrderValue(): number {
    if (this.completedTrades === 0) return 0;
    return Number(this.totalTransactionValue) / this.completedTrades;
  }
}
