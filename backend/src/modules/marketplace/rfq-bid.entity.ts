import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  ManyToOne,
  CreateDateColumn,
  JoinColumn,
  Index,
} from 'typeorm';
import { User } from '../auth/user.entity';
import { RFQ } from './rfq.entity';

@Entity('rfq_bids')
@Index(['rfqId', 'status'])
@Index(['supplierId', 'status'])
@Index(['rfqId', 'submittedAt'])
export class RFQBid {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('uuid')
  rfqId: string;

  @ManyToOne(() => RFQ, (rfq) => rfq.submittedBids)
  @JoinColumn({ name: 'rfqId' })
  rfq: RFQ;

  @Column('uuid')
  supplierId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'supplierId' })
  supplier: User;

  @Column()
  supplierCompanyName: string;

  // Bid Details
  @Column('decimal', { precision: 12, scale: 2 })
  pricePerUnit: number;

  @Column('decimal', { precision: 15, scale: 2 })
  totalPrice: number;

  @Column('varchar', { nullable: true })
  originCountry: string | null;

  @Column('varchar', { nullable: true })
  gradeLevel: string | null;

  @Column('timestamp')
  estimatedDelivery: Date;

  @Column()
  paymentMethod: string;

  @Column('varchar', { nullable: true })
  specialTerms: string | null;

  // Certifications/Documents
  @Column('simple-array', { nullable: true })
  certificationsIncluded: string[] | null;

  @Column('int', { default: 0 })
  documentCount: number;

  // Status - pending (new), accepted (confirmed), rejected (not selected), awarded (selected)
  @Column('varchar', { default: 'pending' })
  status: string;

  // Timestamps
  @CreateDateColumn()
  submittedAt: Date;
}
