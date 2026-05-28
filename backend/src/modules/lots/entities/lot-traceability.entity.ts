import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { Lot } from './lot.entity';
import { User } from '../../users/entities/user.entity';

export enum TraceabilityEventType {
  CREATED = 'created',
  INSPECTED = 'inspected',
  TRANSPORTED = 'transported',
  STORED = 'stored',
  QUALITY_VERIFIED = 'quality_verified',
  STATUS_CHANGED = 'status_changed',
  LISTED = 'listed',
  RESERVED = 'reserved',
  SOLD = 'sold',
  DELIVERED = 'delivered',
  ARCHIVED = 'archived',
}

@Entity('lot_traceability')
@Index(['lotId', 'createdAt'])
@Index(['lotId'])
@Index(['eventType'])
@Index(['performerId'])
export class LotTraceability {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => Lot, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'lotId' })
  lot: Lot;

  @Column('uuid')
  lotId: string;

  @Column('varchar', { length: 50 })
  eventType: TraceabilityEventType;

  @Column('text', { nullable: true })
  description: string; // Human readable description of event

  @Column('varchar', { length: 255, nullable: true })
  location: string; // Where event occurred

  @Column('decimal', { precision: 10, scale: 6, nullable: true })
  latitude: number; // GPS coordinate

  @Column('decimal', { precision: 10, scale: 6, nullable: true })
  longitude: number; // GPS coordinate

  @ManyToOne(() => User)
  @JoinColumn({ name: 'performerId' })
  performer: User; // Who performed the action

  @Column('uuid')
  performerId: string;

  @Column('jsonb', { nullable: true })
  metadata: Record<string, any>; // Custom data per event type

  @Column('varchar', { length: 255, nullable: true })
  eventHash: string; // Cryptographic hash for immutability (future blockchain integration)

  @CreateDateColumn()
  timestamp: Date;

  @CreateDateColumn()
  createdAt: Date;
}
