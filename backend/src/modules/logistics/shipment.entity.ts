import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, OneToMany, CreateDateColumn, UpdateDateColumn, Index, JoinColumn } from 'typeorm';
import { Contract } from '../contracts/contract.entity';
import { User } from '../users/user.entity';
import { ShipmentTracking } from './shipment-tracking.entity';
import { DeliveryProof } from './delivery-proof.entity';

export enum ShipmentStatus {
  PENDING = 'PENDING',
  SCHEDULED = 'SCHEDULED',
  IN_TRANSIT = 'IN_TRANSIT',
  ARRIVED_DESTINATION = 'ARRIVED_DESTINATION',
  DELIVERED = 'DELIVERED',
  FAILED_DELIVERY = 'FAILED_DELIVERY',
  CANCELLED = 'CANCELLED',
}

export enum TransportMode {
  TRUCK = 'TRUCK',
  SHIP = 'SHIP',
  AIR = 'AIR',
  RAIL = 'RAIL',
  MULTI_MODAL = 'MULTI_MODAL',
}

@Entity('shipment')
@Index(['status', 'contractId'])
@Index(['driverId', 'status'])
@Index(['pickupDate'])
@Index(['expectedDeliveryDate'])
@Index(['contractId'])
export class Shipment {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  // References
  @ManyToOne(() => Contract, (contract) => contract.shipments, { onDelete: 'CASCADE', eager: true })
  @JoinColumn({ name: 'contractId' })
  contract: Contract;

  @Column('uuid')
  contractId: string;

  @ManyToOne(() => User, { eager: true })
  @JoinColumn({ name: 'driverId' })
  driver?: User;

  @Column('uuid', { nullable: true })
  driverId?: string;

  // Shipment Details
  @Column('varchar', { length: 100 })
  shipmentReference: string; // SHP-2026-001001

  @Column('enum', { enum: ShipmentStatus, default: ShipmentStatus.PENDING })
  status: ShipmentStatus;

  @Column('enum', { enum: TransportMode })
  transportMode: TransportMode;

  @Column('text', { nullable: true })
  description: string;

  // Logistics Details
  @Column('varchar', { length: 255, nullable: true })
  vehicleRegistration?: string; // License plate

  @Column('varchar', { length: 100, nullable: true })
  vehicleType?: string; // Truck, Refrigerated container, etc.

  @Column('varchar', { length: 100, nullable: true })
  driverLicenseNumber?: string;

  @Column('decimal', { precision: 10, scale: 2, nullable: true })
  totalWeight?: number; // in kg

  @Column('decimal', { precision: 10, scale: 2, nullable: true })
  totalVolume?: number; // in cubic meters

  // Location & Dates
  @Column('varchar', { length: 255 })
  pickupLocationName: string; // Warehouse, Farm, etc.

  @Column('varchar', { length: 100, nullable: true })
  pickupLatitude?: string; // GPS coordinates

  @Column('varchar', { length: 100, nullable: true })
  pickupLongitude?: string;

  @Column('datetime')
  pickupDate: Date;

  @Column('varchar', { length: 255 })
  deliveryLocationName: string;

  @Column('varchar', { length: 100, nullable: true })
  deliveryLatitude?: string;

  @Column('varchar', { length: 100, nullable: true })
  deliveryLongitude?: string;

  @Column('datetime')
  expectedDeliveryDate: Date;

  @Column('datetime', { nullable: true })
  actualDeliveryDate?: Date;

  // tracking & Insurance
  @Column('varchar', { length: 100, nullable: true })
  trackingUrl?: string; // Link to tracking service

  @Column('boolean', { default: false })
  insured: boolean;

  @Column('varchar', { length: 100, nullable: true })
  insuranceProvider?: string;

  @Column('varchar', { length: 100, nullable: true })
  policyNumber?: string;

  @Column('decimal', { precision: 12, scale: 2, nullable: true })
  declaredValue?: number; // For insurance purposes

  // Delivery Handling
  @Column('varchar', { length: 255, nullable: true })
  recipientName?: string;

  @Column('varchar', { length: 100, nullable: true })
  recipientPhone?: string;

  @Column('varchar', { length: 100, nullable: true })
  recipientEmail?: string;

  @Column('text', { nullable: true })
  specialHandlingInstructions?: string; // "Keep refrigerated", "Fragile", etc.

  @Column('boolean', { default: true })
  requiresSignature: boolean;

  @Column('boolean', { default: false })
  requiresPhotographicEvidence: boolean;

  // Delivery Status Tracking
  @Column('datetime', { nullable: true })
  departureTime?: Date;

  @Column('datetime', { nullable: true })
  arrivedDestinationTime?: Date;

  @Column('varchar', { length: 1000, nullable: true })
  deliveryFailureReason?: string; // If status = FAILED_DELIVERY

  @Column('varchar', { length: 100, nullable: true })
  deliveryAttemptCount: number; // 0, 1, 2, 3

  // Additional Metadata
  @Column('simple-json', { nullable: true })
  additionalNotes?: {
    internalNotes?: string;
    customerNotes?: string;
    specialRequests?: string[];
  };

  // Relations
  @OneToMany(() => ShipmentTracking, (tracking) => tracking.shipment, { cascade: true })
  trackingHistory: ShipmentTracking[];

  @OneToMany(() => DeliveryProof, (proof) => proof.shipment, { cascade: true })
  deliveryProofs: DeliveryProof[];

  // Timestamps
  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  // Helper method to calculate days in transit
  getDaysInTransit(): number {
    if (!this.departureTime) return 0;
    const now = this.actualDeliveryDate || new Date();
    return Math.floor((now.getTime() - this.departureTime.getTime()) / (1000 * 60 * 60 * 24));
  }

  // Helper method to check if delayed
  isDelayed(): boolean {
    if (this.status === ShipmentStatus.DELIVERED) return false;
    return new Date() > this.expectedDeliveryDate;
  }
}
