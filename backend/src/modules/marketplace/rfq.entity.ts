import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  ManyToOne,
  OneToMany,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
  JoinColumn,
} from 'typeorm';
import { User } from '../auth/user.entity';
import { RFQBid } from './rfq-bid.entity';

@Entity('rfqs')
@Index(['buyerId', 'status'])
@Index(['status', 'expiresAt'])
@Index(['createdAt'], { where: '"status" = \'open\'' })
export class RFQ {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('uuid')
  buyerId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'buyerId' })
  buyer: User;

  @Column()
  buyerCompanyName: string;

  // Product Details
  @Column()
  productCategory: string;

  @Column()
  productDescription: string;

  @Column('varchar')
  description: string;

  @Column('decimal', { precision: 12, scale: 2 })
  quantity: number;

  @Column()
  quantityUnit: string;

  @Column('varchar', { nullable: true })
  originCountryPreference: string | null;

  @Column('varchar', { nullable: true })
  gradePreference: string | null;

  @Column('varchar', { nullable: true })
  deliveryLocation: string | null;

  @Column('timestamp')
  deliveryDeadline: Date;

  @Column()
  paymentTerms: string;

  @Column('int')
  maxBidsExpected: number;

  // RFQ Status
  @Column('varchar', { default: 'open' })
  status: string; // open, evaluating, awarded, closed

  @Column('uuid', { nullable: true })
  selectedSupplierId: string | null;

  @ManyToOne(() => User, { nullable: true })
  @JoinColumn({ name: 'selectedSupplierId' })
  selectedSupplier: User | null;

  @Column('uuid', { nullable: true })
  selectedSupplierBidId: string | null;

  // Relationships
  @OneToMany(() => RFQBid, (bid) => bid.rfq, { cascade: true })
  submittedBids: RFQBid[];

  // Timestamps
  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @Column('timestamp')
  expiresAt: Date;
}
