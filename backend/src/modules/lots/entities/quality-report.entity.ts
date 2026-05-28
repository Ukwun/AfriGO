import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { Lot } from './lot.entity';
import { User } from '../../users/entities/user.entity';

export enum QualityReportStatus {
  PENDING = 'pending',
  APPROVED = 'approved',
  REJECTED = 'rejected',
  NEEDS_REVIEW = 'needs_review',
}

@Entity('quality_reports')
@Index(['lotId'])
@Index(['verifiedBy'])
@Index(['status'])
@Index(['createdAt'])
export class QualityReport {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => Lot, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'lotId' })
  lot: Lot;

  @Column('uuid')
  lotId: string;

  // Lab information
  @Column('varchar', { length: 255 })
  labName: string; // Name of testing lab/facility

  @Column('varchar', { length: 255, nullable: true })
  labCertificationNumber: string; // Lab's certification ID

  @Column('varchar', { length: 255, nullable: true })
  labContact: string; // Lab contact info

  // Test results
  @Column('varchar', { length: 50, nullable: true })
  predictedGrade: string; // A, B, C based on tests (AI predicted)

  @Column('decimal', { precision: 5, scale: 2, nullable: true })
  moistureContent: number; // %

  @Column('decimal', { precision: 5, scale: 2, nullable: true })
  afflatoxinLevel: number; // PPM

  @Column('decimal', { precision: 5, scale: 2, nullable: true })
  foreignMatterPercentage: number; // %

  // Product specific metrics
  @Column('jsonb', { nullable: true })
  testMetrics: Record<string, any>; // Custom metrics per product type

  // Evidence
  @Column('text', { array: true, default: () => 'ARRAY[]::text[]' })
  evidenceImages: string[]; // URLs to test photos/evidence

  @Column('text', { nullable: true })
  reportUrl: string; // URL to full lab report PDF

  @Column('text', { nullable: true })
  notes: string; // Additional notes from testing

  // Verification
  @Column('varchar', { length: 50, default: QualityReportStatus.PENDING })
  status: QualityReportStatus;

  @ManyToOne(() => User, { nullable: true })
  @JoinColumn({ name: 'verifiedBy' })
  verifiedBy: User; // Who verified the report

  @Column('uuid', { nullable: true })
  verifiedByUserId: string;

  @Column('timestamp', { nullable: true })
  verifiedAt: Date;

  @Column('text', { nullable: true })
  verificationNotes: string;

  // AI Analysis
  @Column('decimal', { precision: 3, scale: 2, default: 0 })
  aiConfidenceScore: number; // 0-1 confidence in AI prediction

  @Column('text', { nullable: true })
  aiAnalysisJson: string; // Raw AI analysis results

  // Audit
  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
