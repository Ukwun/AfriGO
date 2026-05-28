import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm';
import { DocumentStatusEnum, DocumentTypeEnum, CountryCodeEnum } from '../dto/export-document.dto';

/**
 * Export Document Entity
 * Represents official regulatory documents for international trade
 * Includes compliance requirements, signatures, and cloud storage references
 */
@Entity('export_documents')
@Index(['shipmentId'])
@Index(['contractId'])
@Index(['documentType'])
@Index(['status'])
@Index(['originCountry'])
@Index(['destinationCountry'])
@Index(['createdAt'])
@Index(['documentNumber'], { unique: true })
export class ExportDocument {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  /**
   * Unique document reference number
   * Format: PHYSTO-2026-000001, BOL-2026-000001, etc.
   */
  @Column('varchar', { length: 50, unique: true })
  documentNumber: string;

  /**
   * Type of document (Phytosanitary, BOL, Invoice, etc.)
   */
  @Column({
    type: 'enum',
    enum: DocumentTypeEnum,
  })
  documentType: DocumentTypeEnum;

  /**
   * Status in workflow (DRAFT → SIGNED → SUBMITTED → APPROVED)
   */
  @Column({
    type: 'enum',
    enum: DocumentStatusEnum,
    default: DocumentStatusEnum.DRAFT,
  })
  status: DocumentStatusEnum;

  /**
   * Reference to the shipment being exported
   */
  @Column('uuid')
  shipmentId: string;

  /**
   * Reference to the contract
   */
  @Column('uuid')
  contractId: string;

  /**
   * Country of origin (ISO 3166-1 Alpha-2)
   */
  @Column({
    type: 'enum',
    enum: CountryCodeEnum,
  })
  originCountry: CountryCodeEnum;

  /**
   * Destination country (ISO 3166-1 Alpha-2)
   */
  @Column({
    type: 'enum',
    enum: CountryCodeEnum,
  })
  destinationCountry: CountryCodeEnum;

  /**
   * Description of product being exported
   * Example: "2,000 kg Grade A Organic Cocoa Beans"
   */
  @Column('text')
  productDescription: string;

  /**
   * Total value of shipment in specified currency
   */
  @Column('decimal', { precision: 15, scale: 2 })
  totalValue: number;

  /**
   * Currency code (USD, KES, GBP, etc.)
   */
  @Column('varchar', { length: 3 })
  currency: string;

  /**
   * Date when document expires (if applicable)
   * Some certificates have validity periods
   */
  @Column('timestamp', { nullable: true })
  expiryDate: Date | null;

  /**
   * URL to PDF stored in Google Cloud Storage
   * Format: gs://bucket-name/path/to/document.pdf or HTTPS URL
   */
  @Column('text', { nullable: true })
  cloudUrl: string | null;

  /**
   * Digital signatures (multiple signers possible)
   * Stores: [{ email, timestamp, signatureData, certificationUrl }]
   */
  @Column('jsonb', { nullable: true })
  signatures: Array<{
    email: string;
    timestamp: Date;
    signatureData: string;
    certificationUrl?: string;
  }> | null;

  /**
   * Country-specific metadata
   * Stores: { certification, restrictions, approvals, rejectionReason, notes }
   */
  @Column('jsonb', { nullable: true })
  metadata: {
    labReportId?: string;
    qualityGrade?: string;
    harvestDate?: Date;
    batchNumber?: string;
    certification?: string;
    restrictions?: string[];
    approvals?: Array<{ approver: string; timestamp: Date; notes: string }>;
    rejectionReason?: string;
    complianceChecks?: {
      deforestationCheck?: boolean;
      pesticideResidueCheck?: boolean;
      pathogenCheck?: boolean;
      aflatoxinCheck?: boolean;
    };
    [key: string]: any;
  } | null;

  /**
   * User ID who created this document
   */
  @Column('uuid')
  createdBy: string;

  /**
   * Timestamp when created
   */
  @CreateDateColumn()
  createdAt: Date;

  /**
   * Timestamp when last updated
   */
  @UpdateDateColumn()
  updatedAt: Date;

  /**
   * Version of the document (for tracking revisions)
   */
  @Column('int', { default: 1 })
  version: number;
}
