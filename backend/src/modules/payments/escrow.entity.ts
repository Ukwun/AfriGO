import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, CreateDateColumn, UpdateDateColumn, Index, JoinColumn } from 'typeorm';
import { Payment } from './payment.entity';
import { User } from '../users/user.entity';

export enum EscrowStatus {
  CREATED = 'CREATED',
  FUNDED = 'FUNDED',
  HELD = 'HELD',
  RELEASED_TO_SELLER = 'RELEASED_TO_SELLER',
  REFUNDED_TO_BUYER = 'REFUNDED_TO_BUYER',
  DISPUTED = 'DISPUTED',
  RESOLVED = 'RESOLVED',
}

export enum EscrowReleaseReason {
  DELIVERY_CONFIRMED = 'DELIVERY_CONFIRMED',
  QUALITY_VERIFIED = 'QUALITY_VERIFIED',
  DISPUTE_RESOLVED = 'DISPUTE_RESOLVED',
  TIME_ELAPSED = 'TIME_ELAPSED',
  MANUAL_RELEASE = 'MANUAL_RELEASE',
}

@Entity('escrow')
@Index(['paymentId', 'status'])
@Index(['buyerId', 'status'])
@Index(['sellerId', 'status'])
@Index(['releaseDate'])
export class Escrow {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  // Reference to payment
  @ManyToOne(() => Payment, (payment) => payment.escrows, { onDelete: 'CASCADE', eager: true })
  @JoinColumn({ name: 'paymentId' })
  payment: Payment;

  @Column('uuid')
  paymentId: string;

  // Parties
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

  // Escrow Details
  @Column('varchar', { length: 100 })
  escrowReference: string; // ESC-2026-001001

  @Column('enum', { enum: EscrowStatus, default: EscrowStatus.CREATED })
  status: EscrowStatus;

  @Column('varchar', { length: 50 })
  currency: string; // KES, USD, etc.

  @Column('decimal', { precision: 12, scale: 2 })
  amount: number; // Amount held in escrow

  @Column('text', { nullable: true })
  description: string; // "Holding funds for order #12345"

  // Timeline
  @Column('datetime')
  createdAt: Date;

  @Column('datetime', { nullable: true })
  fundedDate?: Date; // When payment received

  @Column('datetime')
  releaseDate: Date; // When funds should/will be released

  @Column('datetime', { nullable: true })
  actualReleaseDate?: Date;

  // Release Details
  @Column('enum', { enum: EscrowReleaseReason, nullable: true })
  releaseReason?: EscrowReleaseReason;

  @Column('text', { nullable: true })
  releaseNotes?: string; // Why released (e.g., "Delivery confirmed via GPS")

  @Column('boolean', { default: false })
  requiresBuyerApproval: boolean; // Does buyer need to approve release?

  @Column('boolean', { default: false })
  buyerApproved: boolean;

  @Column('datetime', { nullable: true })
  buyerApprovedAt?: Date;

  @Column('text', { nullable: true })
  buyerApprovalNotes?: string;

  // Dispute Handling
  @Column('boolean', { default: false })
  isDisputed: boolean;

  @Column('text', { nullable: true })
  disputeReason?: string;

  @Column('uuid', { nullable: true })
  resolvedBy?: string; // Admin who resolved

  @Column('datetime', { nullable: true })
  resolvedAt?: Date;

  // Holds & Charges
  @Column('decimal', { precision: 12, scale: 2, default: 0 })
  holdingFeeAmount: number; // Amarao charged to seller if held too long

  @Column('boolean', { default: false })
  holdingFeesApplied: boolean;

  // Verification Requirements
  @Column('simple-json', { nullable: true })
  releaseConditions?: {
    requireDeliveryProof?: boolean;
    requireQualityApproval?: boolean;
    requireBuyerSignoff?: boolean;
    autoReleaseAfterDays?: number;
  };

  @Column('simple-json', { nullable: true })
  conditionsMetData?: {
    deliveryProofMet?: boolean;
    deliveryProofMetAt?: Date;
    qualityApprovalMet?: boolean;
    qualityApprovalMetAt?: Date;
    buyerSignoffMet?: boolean;
    buyerSignoffMetAt?: Date;
  };

  // Financial Settlement
  @Column('decimal', { precision: 12, scale: 2, default: 0 })
  releasedAmount: number; // Amount actually released (might differ if fees applied)

  @Column('datetime', { nullable: true })
  settledAt?: Date; // When seller received funds

  // Metadata
  @Column('json', { nullable: true })
  additionalNotes?: {
    internalNotes?: string;
    externalNotes?: string;
  };

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  // Helpers
  getDaysHeld(): number {
    const now = new Date();
    return Math.floor((now.getTime() - this.fundedDate!.getTime()) / (1000 * 60 * 60 * 24));
  }

  getRemainingDaysBeforeAutoRelease(): number {
    if (!this.releaseConditions?.autoReleaseAfterDays) return 0;
    const daysHeld = this.getDaysHeld();
    return Math.max(0, this.releaseConditions.autoReleaseAfterDays - daysHeld);
  }

  getAllConditionsMet(): boolean {
    const conditions = this.conditionsMetData;
    if (!conditions) return true;

    if (this.releaseConditions?.requireDeliveryProof && !conditions.deliveryProofMet) return false;
    if (this.releaseConditions?.requireQualityApproval && !conditions.qualityApprovalMet) return false;
    if (this.releaseConditions?.requireBuyerSignoff && !conditions.buyerSignoffMet) return false;

    return true;
  }
}
