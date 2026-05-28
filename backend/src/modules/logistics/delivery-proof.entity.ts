import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, CreateDateColumn, Index, JoinColumn } from 'typeorm';
import { Shipment } from './shipment.entity';
import { User } from '../users/user.entity';

export enum ProofType {
  SIGNATURE = 'SIGNATURE',
  PHOTOGRAPH = 'PHOTOGRAPH',
  VIDEO = 'VIDEO',
  BARCODE_SCAN = 'BARCODE_SCAN',
  GPS_LOCATION = 'GPS_LOCATION',
  TEMP_LOG = 'TEMP_LOG',
  ID_CARD = 'ID_CARD',
}

@Entity('delivery_proof')
@Index(['shipmentId', 'proofType'])
@Index(['capturedBy'])
@Index(['createdAt'])
export class DeliveryProof {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  // Reference to shipment
  @ManyToOne(() => Shipment, (shipment) => shipment.deliveryProofs, { onDelete: 'CASCADE', eager: true })
  @JoinColumn({ name: 'shipmentId' })
  shipment: Shipment;

  @Column('uuid')
  shipmentId: string;

  // Who captured this proof
  @ManyToOne(() => User, { eager: true })
  @JoinColumn({ name: 'capturedBy' })
  capturedBy: User;

  @Column('uuid')
  capturedById: string;

  // Proof Details
  @Column('enum', { enum: ProofType })
  proofType: ProofType;

  @Column('varchar', { length: 500 })
  description: string; // "Signature on delivery", "Photo of package at destination", etc.

  // Content Storage
  @Column('text', { nullable: true })
  dataBlobUrl?: string; // S3 URL or data:image/...

  @Column('json', { nullable: true })
  signatureCanvas?: {
    base64: string;
    imageFormat: string;
    width: number;
    height: number;
  };

  @Column('varchar', { length: 255, nullable: true })
  photoPath?: string; // S3 path

  @Column('varchar', { length: 255, nullable: true })
  videoPath?: string; // S3 path

  // Recipient Information
  @Column('varchar', { length: 255, nullable: true })
  recipientName?: string;

  @Column('varchar', { length: 100, nullable: true })
  recipientIdType?: string; // "ID_CARD", "PASSPORT", "DRIVER_LICENSE"

  @Column('varchar', { length: 100, nullable: true })
  recipientIdNumber?: string;

  @Column('varchar', { length: 100, nullable: true })
  recipientPhone?: string;

  // Condition Assessment (for photo/video proofs)
  @Column('simple-json', { nullable: true })
  conditionAssessment?: {
    packageCondition?: string; // "GOOD", "DAMAGED", "PARTIALLY_DAMAGED"
    damageDescription?: string;
    productCondition?: string; // "FRESH", "ACCEPTABLE", "COMPROMISED"
    temperatureAtDelivery?: number;
    storageConditionsNote?: string;
  };

  // Temperature/Environmental Data (for cold chain)
  @Column('simple-json', { nullable: true })
  environmentalData?: {
    temperature?: number;
    humidity?: number;
    pressure?: number;
    timestamp?: Date;
  };

  // Location Data
  @Column('varchar', { length: 100, nullable: true })
  latitude?: string;

  @Column('varchar', { length: 100, nullable: true })
  longitude?: string;

  // Additional Metadata
  @Column('text', { nullable: true })
  notes?: string;

  @Column('boolean', { default: true })
  isVerified: boolean; // Admin verified this proof

  @Column('varchar', { length: 255, nullable: true })
  verifiedBy?: string; // Admin who verified

  @Column('datetime', { nullable: true })
  verifiedAt?: Date;

  // Timestamps
  @CreateDateColumn()
  createdAt: Date;
}
