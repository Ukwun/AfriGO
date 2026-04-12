import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  DeleteDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
  OneToMany,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Lot } from '../../lots/entities/lot.entity';
import { Message } from '../messaging/entities/message.entity';

@Entity('orders')
@Index(['buyerId'])
@Index(['sellerId'])
@Index(['lotId'])
@Index(['status'])
@Index(['createdAt'])
export class Order {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('uuid')
  lotId: string;

  @ManyToOne(() => Lot)
  @JoinColumn({ name: 'lotId' })
  lot: Lot;

  @Column('uuid')
  buyerId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'buyerId' })
  buyer: User;

  @Column('uuid')
  sellerId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'sellerId' })
  seller: User;

  // Quantity Details
  @Column('decimal', { precision: 10, scale: 2 })
  quantity: number;

  @Column('varchar', { length: 50 })
  quantityUnit: string;

  // Pricing
  @Column('decimal', { precision: 10, scale: 2 })
  pricePerUnit: number;

  @Column('decimal', { precision: 10, scale: 2 })
  totalPrice: number;

  // Commission
  @Column('varchar', { length: 50, default: 'pending' })
  commissionPercentage: string; // e.g., "2.5"

  @Column('decimal', { precision: 10, scale: 2, default: 0 })
  commissionAmount: number;

  // Status
  @Column('varchar', {
    length: 50,
    enum: [
      'pending',
      'quoted',
      'negotiating',
      'confirmed',
      'paid',
      'shipped',
      'delivered',
      'completed',
      'cancelled',
      'disputed',
    ],
    default: 'pending',
  })
  status:
    | 'pending'
    | 'quoted'
    | 'negotiating'
    | 'confirmed'
    | 'paid'
    | 'shipped'
    | 'delivered'
    | 'completed'
    | 'cancelled'
    | 'disputed';

  // Payment Status
  @Column('varchar', {
    length: 50,
    enum: ['not_paid', 'escrowed', 'paid', 'refunded'],
    default: 'not_paid',
  })
  paymentStatus: 'not_paid' | 'escrowed' | 'paid' | 'refunded';

  // Escrow
  @Column('varchar', { length: 255, nullable: true })
  escrowId: string; // Payment gateway escrow ID

  @Column('boolean', { default: false })
  escrowReleased: boolean;

  // Dates
  @Column('timestamp', { nullable: true })
  confirmedAt?: Date;

  @Column('timestamp', { nullable: true })
  paidAt?: Date;

  @Column('timestamp', { nullable: true })
  shippedAt?: Date;

  @Column('timestamp', { nullable: true })
  deliveredAt?: Date;

  @Column('timestamp', { nullable: true })
  completedAt?: Date;

  // Ratings
  @Column('int', { nullable: true })
  buyerRating?: number; // 1-5 stars

  @Column('text', { nullable: true })
  buyerReview?: string;

  @Column('int', { nullable: true })
  sellerRating?: number; // 1-5 stars

  @Column('text', { nullable: true })
  sellerReview?: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @DeleteDateColumn({ nullable: true })
  deletedAt: Date; // Soft delete

  // Relationships
  @OneToMany(() => Message, (message) => message.order)
  messages: Message[];
}
