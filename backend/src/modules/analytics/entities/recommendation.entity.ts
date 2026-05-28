import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { User } from '../../auth/entities/user.entity';

@Entity('recommendations')
@Index(['userId', 'recommendationType'])
@Index(['userId', 'isActive'])
@Index(['createdAt'])
export class Recommendation {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('uuid')
  userId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column('varchar', { length: 100 })
  recommendationType: string;
  // product_recommendation, savings_opportunity, loyalty_tier_upgrade,
  // seasonal_offer, personalized_deal, bundle_suggestion, etc.

  @Column('uuid', { nullable: true })
  targetId: string;
  // product_id, offer_id, etc.

  @Column('varchar', { length: 100, nullable: true })
  targetType: string;
  // product, offer, category, etc.

  @Column('text')
  title: string;

  @Column('text')
  description: string;

  @Column('decimal', { precision: 10, scale: 2, nullable: true })
  potentialSavings: number;

  @Column('varchar', { length: 50, nullable: true })
  priority: 'low' | 'medium' | 'high';

  @Column('integer', { default: 0 })
  displayCount: number;

  @Column('boolean', { default: false })
  isClicked: boolean;

  @Column('boolean', { default: false })
  isConverted: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @Column('timestamptz', { nullable: true })
  clickedAt?: Date;

  @Column('timestamptz', { nullable: true })
  convertedAt?: Date;

  @Column('timestamptz', { nullable: true })
  expiresAt?: Date;

  @Column('boolean', { default: true })
  isActive: boolean;

  @Column('jsonb', { nullable: true })
  algorithmMetadata: Record<string, any>;
  // which algorithm generated it, confidence score, features used, etc.
}
