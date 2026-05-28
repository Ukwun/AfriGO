import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, CreateDateColumn, Index, JoinColumn } from 'typeorm';
import { Shipment } from './shipment.entity';

export enum TrackingEventType {
  CREATED = 'CREATED',
  ASSIGNED_DRIVER = 'ASSIGNED_DRIVER',
  DEPARTED_PICKUP = 'DEPARTED_PICKUP',
  IN_ROUTE = 'IN_ROUTE',
  NEAR_DELIVERY = 'NEAR_DELIVERY',
  ARRIVED_DESTINATION = 'ARRIVED_DESTINATION',
  DELIVERY_ATTEMPTED = 'DELIVERY_ATTEMPTED',
  DELIVERED = 'DELIVERED',
  DELIVERY_FAILED = 'DELIVERY_FAILED',
  RESCHEDULED = 'RESCHEDULED',
  CANCELLED = 'CANCELLED',
  EXCEPTION = 'EXCEPTION',
}

@Entity('shipment_tracking')
@Index(['shipmentId', 'createdAt'])
@Index(['eventType'])
@Index(['latitude', 'longitude']) // For geographic queries
export class ShipmentTracking {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  // Reference to shipment
  @ManyToOne(() => Shipment, (shipment) => shipment.trackingHistory, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'shipmentId' })
  shipment: Shipment;

  @Column('uuid')
  shipmentId: string;

  // Event Details
  @Column('enum', { enum: TrackingEventType })
  eventType: TrackingEventType;

  @Column('varchar', { length: 500 })
  message: string; // "Shipment departed warehouse", "Driver arrived at destination", etc.

  // Location Data (Real-Time GPS)
  @Column('varchar', { length: 100, nullable: true })
  latitude?: string; // GPS latitude

  @Column('varchar', { length: 100, nullable: true })
  longitude?: string; // GPS longitude

  @Column('varchar', { length: 255, nullable: true })
  locationName?: string; // "Nairobi Distribution Center", "Mombasa Port", etc.

  @Column('varchar', { length: 100, nullable: true })
  address?: string;

  // Additional Metadata
  @Column('simple-json', { nullable: true })
  metadata?: {
    temperature?: number; // For cold chain tracking
    humidity?: number;
    batteryLevel?: number; // GPS device battery %
    signalStrength?: number; // Network signal quality
    speed?: number; // Current speed (km/h)
    heading?: number; // Direction (0-360 degrees)
    altitude?: number; // Elevation
    accuracy?: number; // GPS accuracy in meters
    source?: string; // "GPS", "CELL_TOWER", "WIFI", "MANUAL"
  };

  @Column('text', { nullable: true })
  notes?: string; // Additional context about the event

  // Timestamps
  @CreateDateColumn()
  createdAt: Date;

  @Column('datetime', { nullable: true })
  eventTime?: Date; // When the event actually occurred (might differ from createdAt due to sync delays)
}
