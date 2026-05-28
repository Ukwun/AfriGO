import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  ForeignKey,
  Index,
} from 'typeorm';
import { Contract } from './contract.entity';
import { User } from '../users/user.entity';

@Entity('contract_amendment')
@Index(['contractId', 'status'])
@Index(['submittedBy'])
export class ContractAmendment {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ForeignKey(() => Contract)
  @Column('uuid')
  contractId: string;

  @ManyToOne(() => Contract, contract => contract.amendments, {
    onDelete: 'CASCADE',
    eager: true,
  })
  contract: Contract;

  @ForeignKey(() => User)
  @Column('uuid')
  submittedBy: string;

  @ManyToOne(() => User, { eager: true })
  submittedByUser: User;

  @Column('varchar', { length: 50 })
  reason: 'price_adjustment' | 'delivery_date_change' | 'quantity_adjustment' | 'quality_change' | 'other';

  @Column('text')
  description: string; // Detailed explanation of amendment

  @Column('text', { nullable: true })
  proposedChanges?: string; // JSON object with field changes

  @Column('varchar', { length: 50 })
  status: 'pending' | 'approved' | 'rejected';

  @Column('boolean', { default: false })
  buyerApproved: boolean;

  @Column('boolean', { default: false })
  sellerApproved: boolean;

  @Column('timestamp', { nullable: true })
  approvedAt?: Date;

  @Column('varchar', { length: 255, nullable: true })
  rejectionReason?: string;

  @CreateDateColumn()
  createdAt: Date;

  @Column('jsonb', { nullable: true })
  metadata?: Record<string, any>;
}
