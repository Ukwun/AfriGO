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
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Lot } from '../../lots/entities/lot.entity';
import { Order } from './order.entity';

@Entity('quotes')
@Index(['orderId'])
@Index(['fromUserId'])
@Index(['toUserId'])
@Index(['status'])
@Index(['expiresAt'])
export class Quote {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('uuid')
  orderId: string;

  @ManyToOne(() => Order, { eager: true })
  @JoinColumn({ name: 'orderId' })
  order: Order;

  @Column('uuid')
  lotId: string;

  @ManyToOne(() => Lot)
  @JoinColumn({ name: 'lotId' })
  lot: Lot;

  // Quote From (usually seller) and To (usually buyer)
  @Column('uuid')
  fromUserId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'fromUserId' })
  fromUser: User;

  @Column('uuid')
  toUserId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'toUserId' })
  toUser: User;

  // Quote Details
  @Column('varchar', { length: 50, nullable: true })
  quoteType: string; // e.g., 'seller_quote', 'buyer_counter_offer', 'negotiation'

  @Column('decimal', { precision: 10, scale: 2 })
  quotedPrice: number;

  @Column('decimal', { precision: 10, scale: 2 })
  quotedQuantity: number;

  @Column('varchar', { length: 50 })
  quantityUnit: string;

  @Column('text', { nullable: true })
  termsAndConditions?: string; // Delivery terms, payment terms, etc.

  @Column('text', { nullable: true })
  notes?: string; // Additional negotiation notes

  @Column('text', { nullable: true })
  deliveryLocation?: string;

  @Column('timestamp', { nullable: true })
  proposedDeliveryDate?: Date;

  // Status
  @Column('varchar', {
    length: 50,
    enum: ['pending', 'accepted', 'rejected', 'expired', 'countered'],
    default: 'pending',
  })
  status: 'pending' | 'accepted' | 'rejected' | 'expired' | 'countered';

  // Expiration
  @Column('timestamp')
  expiresAt: Date;

  @Column('boolean', { default: false })
  isExpired: boolean;

  // Acceptance/Rejection
  @Column('timestamp', { nullable: true })
  acceptedAt?: Date;

  @Column('timestamp', { nullable: true })
  rejectedAt?: Date;

  @Column('text', { nullable: true })
  rejectionReason?: string;

  // Counter Offer
  @Column('uuid', { nullable: true })
  counterQuoteId?: string; // Link to counter quote if this was a response

  @ManyToOne(() => Quote, { nullable: true })
  @JoinColumn({ name: 'counterQuoteId' })
  counterQuote?: Quote;

  // Audit
  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @DeleteDateColumn({ nullable: true })
  deletedAt: Date; // Soft delete
}
