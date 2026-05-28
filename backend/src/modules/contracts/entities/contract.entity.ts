import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  ForeignKey,
  OneToMany,
  Index,
  Check,
} from 'typeorm';
import { Lot } from '../lots/lot.entity';
import { User } from '../users/user.entity';
import { RFQ } from '../rfq/rfq.entity';
import { ContractAmendment } from './contract-amendment.entity';

@Entity('contract')
@Index(['status', 'buyerId'])
@Index(['sellerId', 'status'])
@Index(['expiryDate'])
@Index(['lotId'])
@Check(`status IN ('draft', 'active', 'signed', 'executed', 'terminated', 'disputed')`)
export class Contract {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  // References
  @ForeignKey(() => Lot)
  @Column('uuid')
  lotId: string;

  @ManyToOne(() => Lot, { onDelete: 'CASCADE', eager: true })
  lot: Lot;

  @ForeignKey(() => RFQ)
  @Column('uuid', { nullable: true })
  rfqId?: string;

  @ManyToOne(() => RFQ, { onDelete: 'SET NULL', eager: true })
  rfq?: RFQ;

  @ForeignKey(() => User)
  @Column('uuid')
  buyerId: string;

  @ManyToOne(() => User, { eager: true })
  buyer: User;

  @ForeignKey(() => User)
  @Column('uuid')
  sellerId: string;

  @ManyToOne(() => User, { eager: true })
  seller: User;

  // Contract Metadata
  @Column('varchar', { length: 100 })
  contractType: 'standard' | 'bulk' | 'premium' | 'custom';

  @Column('varchar', { length: 50 })
  status: 'draft' | 'active' | 'signed' | 'executed' | 'terminated' | 'disputed';

  @Column('varchar', { length: 100 })
  templateName: string; // e.g., "Cocoa_StandardTerms_Ghana_2024"

  @Column('numeric', { precision: 12, scale: 2 })
  totalValue: number; // Contract value in USD

  @Column('numeric', { precision: 12, scale: 2 })
  totalQuantity: number; // Quantity in metric tons

  @Column('varchar', { length: 50 })
  unit: string; // 'MT' (metric tons), 'kg', etc.

  @Column('varchar', { length: 50 })
  currency: string; // 'USD', 'GHS', etc.

  @Column('numeric', { precision: 8, scale: 2 })
  pricePerUnit: number;

  // Quality Requirements
  @Column('varchar', { length: 10 })
  requiredGrade: string; // 'A', 'B', 'C', minimum acceptable

  @Column('text', { nullable: true })
  qualitySpecifications?: string; // JSON stringified specs

  @Column('text', { nullable: true })
  deliveryTerms?: string; // Incoterms: FOB, CIF, DDP, etc.

  // Payment Terms
  @Column('varchar', { length: 50 })
  paymentMethod: 'full_upfront' | 'partial_deposit' | 'on_delivery' | 'installment' | 'escrow';

  @Column('numeric', { precision: 5, scale: 2 })
  depositPercentage: number; // 0-100, percentage due upfront

  @Column('integer', { nullable: true })
  installmentCount?: number; // Number of payments if installment

  @Column('integer', { nullable: true })
  paymentDuesDays?: number; // Days after delivery before full payment due

  // Timeline
  @Column('timestamp')
  signatureDeadline: Date;

  @Column('timestamp')
  deliveryStartDate: Date;

  @Column('timestamp')
  deliveryEndDate: Date;

  @Column('timestamp')
  expiryDate: Date;

  // Signature & Approval
  @Column('boolean', { default: false })
  buyerSigned: boolean;

  @Column('timestamp', { nullable: true })
  buyerSignedAt?: Date;

  @Column('varchar', { length: 255, nullable: true })
  buyerSignature?: string; // URL or base64 image

  @Column('boolean', { default: false })
  sellerSigned: boolean;

  @Column('timestamp', { nullable: true })
  sellerSignedAt?: Date;

  @Column('varchar', { length: 255, nullable: true })
  sellerSignature?: string; // URL or base64 image

  // Dispute & Amendment
  @Column('boolean', { default: false })
  isDisputed: boolean;

  @Column('text', { nullable: true })
  disputeReason?: string;

  @Column('varchar', { length: 255, nullable: true })
  mediatorId?: string; // User ID of assigned mediator

  @Column('integer', { default: 0 })
  amendmentCount: number; // Number of amendments applied

  @OneToMany(() => ContractAmendment, amendment => amendment.contract)
  amendments: ContractAmendment[];

  // Insurance & Compliance
  @Column('boolean', { default: false })
  insuranceRequired: boolean;

  @Column('varchar', { length: 255, nullable: true })
  insuranceProvider?: string;

  @Column('varchar', { length: 100, nullable: true })
  insurancePolicyNumber?: string;

  @Column('boolean', { default: false })
  phytosanitaryCertificateRequired: boolean;

  @Column('text', { nullable: true })
  additionalTerms?: string; // Custom clauses in JSON

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @Column('timestamp', { nullable: true })
  executedAt?: Date; // When contract was fully executed/delivered

  @Column('jsonb', { nullable: true })
  metadata?: Record<string, any>;
}
