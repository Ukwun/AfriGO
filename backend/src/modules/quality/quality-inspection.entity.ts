import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  ManyToOne,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
  JoinColumn,
} from 'typeorm';
// import { Lot } from '../lots/lot.entity'; // TODO: Fix import path
// import { User } from '../auth/user.entity'; // TODO: Fix import path
import { LabCertification } from './lab-certification.entity';

@Entity('quality_inspections')
@Index(['lotId', 'status'])
@Index(['inspectorId', 'createdAt'])
@Index(['labCertificationId', 'createdAt'])
export class QualityInspection {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('uuid')
  lotId: string;

  // @ManyToOne(() => Lot)
  // @JoinColumn({ name: 'lotId' })
  // lot: Lot;

  @Column('uuid', { nullable: true })
  inspectorId: string;

  // @ManyToOne(() => User, { nullable: true })
  // @JoinColumn({ name: 'inspectorId' })
  // inspector: User;

  @Column('uuid', { nullable: true })
  labCertificationId: string;

  @ManyToOne(() => LabCertification, { nullable: true })
  @JoinColumn({ name: 'labCertificationId' })
  labCertification: LabCertification;

  // Inspection Details
  @Column('varchar')
  inspectionType: string; // visual, lab, ai, manual

  @Column('varchar')
  status: string; // pending, in_progress, completed, rejected, approved

  // Visual Inspection Results
  @Column('varchar', { nullable: true })
  visualGrade: string; // A, B, C, Rejected

  @Column('int', { nullable: true })
  visualDefectPercentage: number; // 0-100

  @Column('varchar', { array: true, nullable: true })
  visualDefectsFound: string[]; // damaged, moldy, discolored, foreign_matter

  @Column('varchar', { array: true })
  inspectionPhotos: string[]; // URLs to inspection photos

  // Lab Test Results
  @Column('decimal', { precision: 5, scale: 2, nullable: true })
  moistureContent: number; // percentage

  @Column('decimal', { precision: 5, scale: 2, nullable: true })
  afflatoxinLevel: number; // ppb (parts per billion)

  @Column('decimal', { precision: 5, scale: 2, nullable: true })
  foreignMatterPercentage: number; // percentage

  @Column('decimal', { precision: 5, scale: 2, nullable: true })
  insectFragmentCount: number;

  @Column('decimal', { precision: 5, scale: 2, nullable: true })
  pH: number;

  @Column('varchar', { nullable: true })
  bacterialCount: string; // CFU/g

  @Column('json', { nullable: true })
  additionalTests: any; // protein, fat, fiber, etc.

  // AI Analysis Results
  @Column('varchar', { nullable: true })
  aiPredictedGrade: string; // A, B, C, Rejected

  @Column('decimal', { precision: 5, scale: 2, nullable: true })
  aiConfidenceScore: number; // 0-100

  @Column('json', { nullable: true })
  aiAnalysisDetails: any; // Full AI model output

  // Final Determination
  @Column('varchar', { nullable: true })
  finalGrade: string; // A, B, C, Rejected (manually overridable)

  @Column('boolean', { default: false })
  isApproved: boolean;

  @Column('varchar', { nullable: true })
  approvalNotes: string;

  @Column('uuid', { nullable: true })
  approvedBy: string;

  // @ManyToOne(() => User, { nullable: true })
  // @JoinColumn({ name: 'approvedBy' })
  // approver: User;

  @Column('timestamp', { nullable: true })
  approvedAt: Date;

  // Timestamps
  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @Column('timestamp', { nullable: true })
  completedAt: Date;
}
