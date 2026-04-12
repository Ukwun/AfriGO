import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
  DeleteDateColumn,
} from 'typeorm';
import { Order } from '../trading/entities/order.entity';
import { User } from '../auth/entities/user.entity';

@Entity('payments')
@Index(['orderId'])
@Index(['userId'])
@Index(['status'])
@Index(['createdAt'])
@Index(['stripePaymentIntentId'])
export class Payment {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('uuid')
  orderId: string;

  @ManyToOne(() => Order, { eager: false, cascade: false })
  @JoinColumn({ name: 'orderId' })
  order: Order;

  @Column('uuid')
  userId: string;

  @ManyToOne(() => User, { eager: false, cascade: false })
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column('decimal', { precision: 10, scale: 2 })
  amount: number;

  @Column({ type: 'varchar', length: 3 })
  currency: string; // 'USD', 'GBP', etc.

  // payment_intent, charge, etc.
  @Column({ type: 'varchar', length: 50 })
  paymentMethod: string;

  // pending, processing, succeeded, failed, cancelled, refunded
  @Column({ type: 'varchar', length: 50, default: 'pending' })
  status: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  stripePaymentIntentId: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  stripeChargeId: string;

  // For escrow: pending, held, released, refunded
  @Column({ type: 'varchar', length: 50, default: 'pending' })
  escrowStatus: string;

  // Card details (stored safely via Stripe)
  @Column({ type: 'jsonb', nullable: true })
  cardInfo?: {
    brand: string; // visa, mastercard, amex, etc.
    last4: string; // Last 4 digits
    expiryMonth: number;
    expiryYear: number;
  };

  // Payment description/reference
  @Column({ type: 'text', nullable: true })
  description: string;

  // Ledger/receipt information
  @Column({ type: 'varchar', length: 255, nullable: true })
  receiptUrl: string;

  // Fee paid by platform (deducted from seller payout)
  @Column('decimal', { precision: 10, scale: 2, default: 0 })
  platformFee: number;

  // Amount released to seller
  @Column('decimal', { precision: 10, scale: 2, default: 0 })
  sellerPayout: number;

  // Timestamps
  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @Column({ type: 'timestamp', nullable: true })
  paidAt: Date;

  @Column({ type: 'timestamp', nullable: true })
  refundedAt: Date;

  // Failure reason if status is failed
  @Column({ type: 'text', nullable: true })
  failureReason: string;

  @DeleteDateColumn({ nullable: true })
  deletedAt: Date;
}
