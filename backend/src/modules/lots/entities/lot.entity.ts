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

@Entity('lots')
@Index(['sellerId'])
@Index(['status'])
@Index(['verifyStatus'])
@Index(['createdAt'])
@Index(['productName']) // For search
export class Lot {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('uuid')
  sellerId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'sellerId' })
  seller: User;

  @Column('varchar', { length: 255 })
  productName: string; // Maize, Rice, Cassava, etc.

  @Column('decimal', { precision: 10, scale: 2 })
  quantity: number; // 1000 (units depend on quantityUnit)

  @Column('varchar', { length: 50 })
  quantityUnit: string; // kg, bag, ton, etc.

  @Column('decimal', { precision: 10, scale: 2 })
  pricePerUnit: number; // $0.50 per unit

  @Column('text')
  description: string; // Product details, quality info

  @Column('text', { array: true, default: () => 'ARRAY[]::text[]' })
  images: string[]; // URLs to product images (3-5 images)

  @Column('varchar', { length: 255 })
  pickupLocation: string; // Market name, address

  @Column('decimal', { precision: 9, scale: 6 })
  latitude: number; // GPS coordinate

  @Column('decimal', { precision: 9, scale: 6 })
  longitude: number; // GPS coordinate

  @Column('varchar', { length: 255, nullable: true })
  qrCode: string; // Unique QR code for verification (block hash)

  @Column('varchar', {
    length: 50,
    enum: ['draft', 'active', 'sold', 'expired'],
    default: 'draft',
  })
  status: 'draft' | 'active' | 'sold' | 'expired';

  @Column('varchar', {
    length: 50,
    enum: ['pending', 'verified', 'rejected'],
    default: 'pending',
  })
  verifyStatus: 'pending' | 'verified' | 'rejected'; // Admin verification

  @Column('text', { array: true, default: () => 'ARRAY[]::text[]' })
  certifications: string[]; // Organic, Fair Trade, Rainforest Alliance, etc.

  @Column('varchar', { length: 50, nullable: true })
  category: string; // Grains, Vegetables, Fruits, etc.

  @Column('int', { default: 0 })
  viewCount: number; // Track popularity

  @Column('decimal', { precision: 3, scale: 2, default: 0 })
  averageRating: number; // Product rating (1-5)

  @Column('int', { default: 0 })
  ratingCount: number; // Number of ratings

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @DeleteDateColumn({ nullable: true })
  deletedAt: Date; // Soft delete for GDPR compliance
}
