// backend/src/modules/export-documentation/dto/export-document.dto.ts

import { IsEnum, IsString, IsUUID, IsNumber, IsDate, IsOptional, IsObject, ValidateNested, ArrayMinSize } from 'class-validator';
import { Type } from 'class-transformer';

/**
 * Export Document Types
 * These are official regulatory documents required for international trade
 */
export enum DocumentTypeEnum {
  PHYTOSANITARY_CERTIFICATE = 'PHYTOSANITARY_CERTIFICATE',      // Plant health cert
  BILL_OF_LADING = 'BILL_OF_LADING',                            // Shipping document
  COMMERCIAL_INVOICE = 'COMMERCIAL_INVOICE',                    // Customs invoice
  CERTIFICATE_OF_ORIGIN = 'CERTIFICATE_OF_ORIGIN',              // Country proof
  PACKING_LIST = 'PACKING_LIST',                                // Box contents
  CERTIFICATE_OF_ANALYSIS = 'CERTIFICATE_OF_ANALYSIS',          // Lab results
  ORGANIC_CERTIFICATE = 'ORGANIC_CERTIFICATE',                  // Organic proof
  FAIR_TRADE_CERTIFICATE = 'FAIR_TRADE_CERTIFICATE',            // Fair trade proof
}

/**
 * Document Status Workflow
 */
export enum DocumentStatusEnum {
  DRAFT = 'DRAFT',                                  // Being prepared
  PENDING_SIGNATURE = 'PENDING_SIGNATURE',          // Awaiting e-signature
  SIGNED = 'SIGNED',                                // Digitally signed
  SUBMITTED = 'SUBMITTED',                          // To government
  APPROVED = 'APPROVED',                            // Official approval
  REJECTED = 'REJECTED',                            // Requires resubmission
  EXPIRED = 'EXPIRED',                              // No longer valid
  ARCHIVED = 'ARCHIVED',                            // Historical record
}

/**
 * Country Codes (ISO 3166-1 Alpha-2)
 */
export enum CountryCodeEnum {
  KE = 'KE', // Kenya
  UG = 'UG', // Uganda
  TZ = 'TZ', // Tanzania
  ET = 'ET', // Ethiopia
  GH = 'GH', // Ghana
  NG = 'NG', // Nigeria
  ZA = 'ZA', // South Africa
  RW = 'RW', // Rwanda
  BW = 'BW', // Botswana
  MW = 'MW', // Malawi
  ZM = 'ZM', // Zambia
  ZW = 'ZW', // Zimbabwe
  MZ = 'MZ', // Mozambique
  SN = 'SN', // Senegal
  CI = 'CI', // Côte d'Ivoire
}

/**
 * Create Export Document DTO
 * Used when generating a new export document
 */
export class CreateExportDocumentDto {
  @IsEnum(DocumentTypeEnum)
  documentType: DocumentTypeEnum;

  @IsUUID()
  shipmentId: string;  // Link to shipment being exported

  @IsUUID()
  contractId: string;  // Link to contract

  @IsEnum(CountryCodeEnum)
  originCountry: CountryCodeEnum;  // Where product comes from

  @IsEnum(CountryCodeEnum)
  destinationCountry: CountryCodeEnum;  // Where product goes

  @IsString()
  productDescription: string;  // "2,000 kg Grade A Cocoa Beans"

  @IsNumber()
  totalValue: number;  // Total USD value of shipment

  @IsString()
  currency: string;  // USD, KES, etc.

  @IsOptional()
  @IsDate()
  @Type(() => Date)
  expiryDate?: Date;  // When cert expires (if applicable)

  @IsOptional()
  @IsObject()
  metadata?: {
    labReportId?: string;
    qualityGrade?: string;
    harvestDate?: Date;
    batchNumber?: string;
    [key: string]: any;
  };
}

/**
 * Update Document Status DTO
 * Used when document moves through workflow
 */
export class UpdateDocumentStatusDto {
  @IsEnum(DocumentStatusEnum)
  status: DocumentStatusEnum;

  @IsOptional()
  @IsString()
  notes?: string;  // Admin notes about status change

  @IsOptional()
  @IsString()
  governmentReferenceId?: string;  // Ref from govt system
}

/**
 * Sign Document DTO
 * When exporter/shipper digitally signs document
 */
export class SignDocumentDto {
  @IsString()
  signatureData: string;  // Base64 encoded signature

  @IsString()
  signerEmail: string;

  @IsOptional()
  @IsString()
  signingReason?: string;  // Why signing (e.g., "Authorization to export")
}

/**
 * Generate Compliance Report DTO
 * Check what docs are required
 */
export class GenerateComplianceReportDto {
  @IsEnum(CountryCodeEnum)
  destinationCountry: CountryCodeEnum;

  @IsString()
  productType: string;  // "cocoa", "coffee", "cashew"

  @IsNumber()
  quantity: number;

  @IsString()
  quantityUnit: string;  // "kg", "tons", "bags"

  @IsOptional()
  @IsString()
  certification?: string;  // "organic", "fair-trade", "conventional"
}

/**
 * Export Document Response DTO
 * What the API returns
 */
export class ExportDocumentResponseDto {
  @IsUUID()
  id: string;

  @IsEnum(DocumentTypeEnum)
  documentType: DocumentTypeEnum;

  @IsEnum(DocumentStatusEnum)
  status: DocumentStatusEnum;

  @IsEnum(CountryCodeEnum)
  originCountry: CountryCodeEnum;

  @IsEnum(CountryCodeEnum)
  destinationCountry: CountryCodeEnum;

  @IsString()
  documentNumber: string;  // Unique identifier like "DOC-2026-001234"

  @IsString()
  documentUrl: string;  // URL to download PDF

  @IsOptional()
  @IsDate()
  @Type(() => Date)
  generatedAt?: Date;

  @IsOptional()
  @IsDate()
  @Type(() => Date)
  signedAt?: Date;

  @IsOptional()
  @IsDate()
  @Type(() => Date)
  submittedAt?: Date;

  @IsOptional()
  @IsDate()
  @Type(() => Date)
  approvedAt?: Date;

  @IsOptional()
  @IsDate()
  @Type(() => Date)
  expiryDate?: Date;

  @IsObject()
  metadata?: any;

  @IsDate()
  @Type(() => Date)
  createdAt: Date;

  @IsDate()
  @Type(() => Date)
  updatedAt: Date;
}

/**
 * Compliance Matrix Response
 * What compliance docs are needed for destination
 */
export class ComplianceMatrixDto {
  @IsEnum(CountryCodeEnum)
  destinationCountry: CountryCodeEnum;

  @IsString()
  countryName: string;

  requiredDocuments: {
    documentType: DocumentTypeEnum;
    isRequired: boolean;
    description: string;
    processingDays: number;
    cost: number;  // Processing fee
    notes: string;
  }[];

  restrictions: {
    productType: string;
    isAllowed: boolean;
    reason?: string;
    alternativeDestinations?: string[];
  }[];

  regulations: {
    title: string;
    description: string;
    source: string;  // Link to official regulation
    effectiveDate: Date;
  }[];

  estimatedCost: number;  // Total compliance cost
  estimatedTime: number;  // Days to complete all docs
}

/**
 * Document List Response
 */
export class DocumentListResponseDto {
  documents: ExportDocumentResponseDto[];
  total: number;
  page: number;
  pageSize: number;
  totalPages: number;
}

/**
 * Document Signature Verification DTO
 */
export class DocumentSignatureVerificationDto {
  isValid: boolean;
  signerEmail: string;
  signedAt: Date;
  certificateFingerprintSHA256: string;  // For blockchain verification (future)
}
