import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, OneToMany, CreateDateColumn, UpdateDateColumn, Index, JoinColumn } from 'typeorm';
import { Contract } from '../contracts/entities/contract.entity';
import { User } from '../auth/entities/user.entity';
import { Escrow } from './escrow.entity';

export enum PaymentStatus {
  PENDING = 'PENDING',
  INITIATED = 'INITIATED',
  PROCESSING = 'PROCESSING',
  COMPLETED = 'COMPLETED',
  FAILED = 'FAILED',
  REFUNDED = 'REFUNDED',
  DISPUTED = 'DISPUTED',
}

export enum PaymentMethod {
  FULL_UPFRONT = 'FULL_UPFRONT',
  PARTIAL_DEPOSIT = 'PARTIAL_DEPOSIT',
  ON_DELIVERY = 'ON_DELIVERY',
  INSTALLMENT = 'INSTALLMENT',
  ESCROW = 'ESCROW',
}

export enum Currency {
  KES = 'KES',
  USD = 'USD',
  EUR = 'EUR',
  ZAR = 'ZAR',
  UGX = 'UGX',
  TZS = 'TZS',
}

@Entity('payment')
@Index(['contractId', 'status'])
@Index(['buyerId', 'createdAt'])
@Index(['paymentStatus'])
@Index(['dueDate'])
export class Payment {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  // References
  @ManyToOne(() => Contract, { eager: true, onDelete: 'CASCADE' })
  @JoinColumn({ name: 'contractId' })
  contract: Contract;

  @Column('uuid')
  contractId: string;

  @ManyToOne(() => User, { eager: true })
  @JoinColumn({ name: 'buyerId' })
  buyer: User;

  @Column('uuid')
  buyerId: string;

  @ManyToOne(() => User, { eager: true })
  @JoinColumn({ name: 'sellerId' })
  seller: User;

  @Column('uuid')
  sellerId: string;

  // Payment Basic Details
  @Column('varchar', { length: 100 })
  invoiceNumber: string; // INV-2026-001001

  @Column('enum', { enum: PaymentStatus, default: PaymentStatus.PENDING })
  paymentStatus: PaymentStatus;

  @Column('enum', { enum: PaymentMethod })
  paymentMethod: PaymentMethod;

  @Column('enum', { enum: Currency })
  currency: Currency;

  // Amounts
  @Column('decimal', { precision: 12, scale: 2 })
  totalAmount: number; // Total contract value

  @Column('decimal', { precision: 12, scale: 2 })
  amountDue: number; // This payment's amount

  @Column('decimal', { precision: 12, scale: 2, default: 0 })
  amountPaid: number;

  @Column('decimal', { precision: 12, scale: 2, default: 0 })
  amountRefunded: number;

  @Column('decimal', { precision: 5, scale: 2, nullable: true })
  platformFeePercentage?: number; // 2-5% depending on payment method

  @Column('decimal', { precision: 12, scale: 2, nullable: true })
  platformFeeAmount?: number;

  @Column('decimal', { precision: 12, scale: 2, nullable: true })
  taxes?: number; // VAT or other taxes

  // Timeline
  @Column('datetime')
  dueDate: Date;

  @Column('datetime', { nullable: true })
  paidDate?: Date;

  @Column('datetime', { nullable: true })
  dueReminderSentAt?: Date;

  @Column('datetime', { nullable: true })
  overdueLateFeesAppliedAt?: Date;

  // Late Fees
  @Column('decimal', { precision: 5, scale: 2, default: 2 })
  lateFeesPercentage: number; // 2% per 10 days late

  @Column('decimal', { precision: 12, scale: 2, default: 0 })
  lateFees: number;

  @Column('boolean', { default: false })
  isOverdue: boolean;

  // Payment Details
  @Column('varchar', { length: 100, nullable: true })
  transactionReference?: string; // Flutterwave transaction ID

  @Column('text', { nullable: true })
  paymentNotes?: string;

  @Column('json', { nullable: true })
  flutterwaveResponse?: any; // Response from Flutterwave API

  // Installment Configuration (if INSTALLMENT method)
  @Column('integer', { nullable: true })
  installmentNumber?: number; // 1/3, 2/3, 3/3

  @Column('integer', { nullable: true })
  totalInstallments?: number;

  @Column('datetime', { nullable: true })
  nextInstallmentDueDate?: Date;

  // Escrow Details (if ESCROW method)
  @OneToMany(() => Escrow, (escrow) => escrow.payment, { cascade: true })
  escrows: Escrow[];

  @Column('uuid', { nullable: true })
  activeEscrowId?: string;

  // Proof of Payment
  @Column('varchar', { length: 255, nullable: true })
  receiptUrl?: string; // S3 URL to receipt

  @Column('text', { nullable: true })
  bankTransferProof?: string; // For bank transfers

  // Metadata
  @Column('simple-json', { nullable: true })
  additionalDetails?: {
    bankName?: string;
    bankCode?: string;
    accountNumber?: string;
    mpesaPhoneNumber?: string;
    paypalEmail?: string;
  };

  @Column('boolean', { default: false })
  isDisputed: boolean;

  @Column('text', { nullable: true })
  disputeReason?: string;

  // Timestamps
  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  // Helpers
  getStatusBadge(): string {
    switch (this.paymentStatus) {
      case PaymentStatus.COMPLETED:
        return '✓ Paid';
      case PaymentStatus.PENDING:
        return '⏳ Awaiting Payment';
      case PaymentStatus.PROCESSING:
        return '⌛ Processing';
      case PaymentStatus.FAILED:
        return '✗ Failed';
      case PaymentStatus.REFUNDED:
        return '↶ Refunded';
      default:
        return this.paymentStatus;
    }
  }

  getRemainingBalance(): number {
    return this.amountDue - this.amountPaid;
  }

  getIsFullyPaid(): boolean {
    return this.amountPaid >= this.amountDue;
  }

  getDaysOverdue(): number {
    if (!this.isOverdue) return 0;
    return Math.floor((new Date().getTime() - this.dueDate.getTime()) / (1000 * 60 * 60 * 24));
  }
}
