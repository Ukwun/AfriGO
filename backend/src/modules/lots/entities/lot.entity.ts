import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  DeleteDateColumn,
  ManyToOne,
  JoinColumn,
  OneToMany,
  Index,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';

export enum GradeLevel {
  A = 'A',
  B = 'B',
  C = 'C',
  REJECTED = 'rejected',
}

@Entity('lots')
@Index(['sellerId'])
@Index(['status'])
@Index(['verifyStatus'])
@Index(['createdAt'])
@Index(['productName'])
@Index(['qrCode'], { unique: true })
@Index(['batchNumber'], { unique: true })
@Index(['sellerId', 'status'])
export class Lot {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  // Seller info
  @Column('uuid')
  sellerId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'sellerId' })
  seller: User;

  // Product basics
  @Column('varchar', { length: 255 })
  productName: string; // Cocoa, Coffee, Cashew, etc.

  @Column('varchar', { length: 100, nullable: true })
  category: string; // Product category for filtering

  // Quantity management
  @Column('decimal', { precision: 12, scale: 2 })
  quantity: number; // Total quantity available

  @Column('decimal', { precision: 12, scale: 2, default: 0 })
  quantityReserved: number; // Quantity in active orders

  @Column('decimal', { precision: 12, scale: 2, default: 0 })
  quantitySold: number; // Quantity sold/archived

  @Column('varchar', { length: 50 })
  quantityUnit: string; // kg, tonnes, bags, crates

  // Pricing
  @Column('decimal', { precision: 10, scale: 2 })
  pricePerUnit: number; // Price per unit (currency in defaults)

  @Column('decimal', { precision: 15, scale: 2 })
  totalValue: number; // quantity * pricePerUnit (cached for performance)

  // Batch & Traceability
  @Column('varchar', { length: 100, unique: true })
  batchNumber: string; // Unique batch identifier for traceability

  @Column('varchar', { length: 255, unique: true })
  qrCode: string; // Unique QR code for verification

  @Column('text', { nullable: true })
  qrCodeUrl: string; // URL to QR code image

  @Column('varchar', { length: 255, nullable: true })
  serialNumber: string; // Additional serial tracking

  // Location & Origin
  @Column('varchar', { length: 100 })
  originCountry: string; // Where product originated

  @Column('varchar', { length: 100, nullable: true })
  originRegion: string; // Region within country

  @Column('varchar', { length: 255, nullable: true })
  originLocation: string; // Specific farm/location name

  @Column('varchar', { length: 255 })
  pickupLocation: string; // Current storage/pickup location

  @Column('decimal', { precision: 10, scale: 6 })
  latitude: number; // GPS coordinate of origin

  @Column('decimal', { precision: 10, scale: 6 })
  longitude: number; // GPS coordinate of origin

  @Column('varchar', { length: 255, nullable: true })
  storageLocation: string; // Physical storage address

  @Column('varchar', { length: 50, nullable: true })
  storageType: string; // warehouse, cold-chain, open-air

  // Dates
  @Column('date', { nullable: true })
  harvestDate: Date; // When product was harvested

  @Column('date', { nullable: true })
  productionDate: Date; // When product was processed

  @Column('date', { nullable: true })
  expiryDate: Date; // Expiration date

  @Column('timestamp', { nullable: true })
  listingDate: Date; // When lot was published

  @Column('timestamp', { nullable: true })
  expiresAt: Date; // When lot listing expires

  // Quality Information
  @Column('varchar', { length: 20, default: GradeLevel.B })
  gradeLevel: GradeLevel; // A (Premium), B (Standard), C (Fair), Rejected

  @Column('decimal', { precision: 5, scale: 2, nullable: true })
  moistureContent: number; // Percentage (%)

  @Column('decimal', { precision: 5, scale: 2, nullable: true })
  afflatoxinLevel: number; // PPM (parts per million)

  @Column('decimal', { precision: 5, scale: 2, nullable: true })
  foreignMatterPercentage: number; // Percentage (%)

  @Column('jsonb', { nullable: true })
  qualityMetrics: Record<string, any>; // Custom quality specs per product type

  // Certifications & Compliance
  @Column('text', { array: true, default: () => 'ARRAY[]::text[]' })
  certifications: string[]; // Organic, Fair Trade, Rainforest Alliance

  @Column('boolean', { default: false })
  certifiedOrganic: boolean;

  @Column('boolean', { default: false })
  fairTradeCertified: boolean;

  // Description & Content
  @Column('text')
  description: string; // Product details, quality info

  @Column('text', { array: true, default: () => 'ARRAY[]::text[]' })
  images: string[]; // URLs to product images (3-5 images)

  // Status & Verification
  @Column('varchar', {
    length: 50,
    enum: ['draft', 'active', 'reserved', 'sold', 'expired', 'archived'],
    default: 'draft',
  })
  status: 'draft' | 'active' | 'reserved' | 'sold' | 'expired' | 'archived';

  @Column('varchar', {
    length: 50,
    enum: ['pending', 'verified', 'rejected'],
    default: 'pending',
  })
  verifyStatus: 'pending' | 'verified' | 'rejected';

  // Engagement & Ratings
  @Column('int', { default: 0 })
  viewCount: number; // Track popularity

  @Column('decimal', { precision: 3, scale: 2, default: 0 })
  averageRating: number; // Product rating (1-5)

  @Column('int', { default: 0 })
  ratingCount: number; // Number of ratings

  // Audit
  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @DeleteDateColumn({ nullable: true })
  deletedAt: Date; // Soft delete for GDPR compliance
}
