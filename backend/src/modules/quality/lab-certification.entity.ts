import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm';

@Entity('lab_certifications')
@Index(['labCode'], { unique: true })
@Index(['status'])
export class LabCertification {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  labName: string;

  @Column()
  labCode: string; // ISO 9001, ISO 14001, etc.

  @Column()
  country: string;

  @Column()
  certificationNumber: string; // Official certification number

  @Column('text')
  certificationUrl: string; // Download URL for certificate

  @Column('timestamp')
  issuedDate: Date;

  @Column('timestamp')
  expiryDate: Date;

  @Column()
  accreditation: string; // Accreditation body (e.g., UKAS, NABL)

  @Column('varchar', { array: true, default: () => 'ARRAY[]::varchar[]' })
  testingCertifications: string[]; // What they can test (moisture, aflatoxin, etc.)

  @Column('varchar', { default: 'active' })
  status: string; // active, expired, suspended, revoked

  @Column()
  contactEmail: string;

  @Column()
  contactPhone: string;

  @Column('decimal', { precision: 10, scale: 2, nullable: true })
  costPerTest: number;

  @Column('int', { default: 0 })
  testsCompleted: number; // Lifetime tests

  @Column('decimal', { precision: 5, scale:2, default: 0 })
  averageAccuracy: number; // 0-100, based on validation

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
