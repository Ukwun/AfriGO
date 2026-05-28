import {
  IsString,
  IsNumber,
  IsUUID,
  IsEnum,
  IsBoolean,
  IsOptional,
  IsDateString,
  Min,
  Max,
  ValidateNested,
  IsArray,
} from 'class-validator';
import { Type } from 'class-transformer';

// Enums for validation
enum ContractType {
  STANDARD = 'standard',
  BULK = 'bulk',
  PREMIUM = 'premium',
  CUSTOM = 'custom',
}

enum ContractStatus {
  DRAFT = 'draft',
  ACTIVE = 'active',
  SIGNED = 'signed',
  EXECUTED = 'executed',
  TERMINATED = 'terminated',
  DISPUTED = 'disputed',
}

enum PaymentMethod {
  FULL_UPFRONT = 'full_upfront',
  PARTIAL_DEPOSIT = 'partial_deposit',
  ON_DELIVERY = 'on_delivery',
  INSTALLMENT = 'installment',
  ESCROW = 'escrow',
}

enum AmendmentReason {
  PRICE_ADJUSTMENT = 'price_adjustment',
  DELIVERY_DATE_CHANGE = 'delivery_date_change',
  QUANTITY_ADJUSTMENT = 'quantity_adjustment',
  QUALITY_CHANGE = 'quality_change',
  OTHER = 'other',
}

// ============================================
// CREATE CONTRACT DTO
// ============================================

export class CreateContractDTO {
  @IsUUID()
  rfqId: string; // From RFQ award

  @IsUUID()
  lotId: string;

  @IsUUID()
  buyerId: string;

  @IsUUID()
  sellerId: string;

  @IsEnum(ContractType)
  contractType: ContractType;

  @IsString()
  templateName: string; // Template selection

  @IsNumber()
  @Min(0)
  totalValue: number;

  @IsNumber()
  @Min(0)
  totalQuantity: number;

  @IsString()
  unit: string; // 'MT', 'kg', etc.

  @IsString()
  currency: string; // 'USD', 'GHS', etc.

  @IsNumber()
  @Min(0)
  pricePerUnit: number;

  @IsString()
  requiredGrade: string; // Min acceptable grade

  @IsOptional()
  @IsString()
  qualitySpecifications?: string;

  @IsOptional()
  @IsString()
  deliveryTerms?: string; // Incoterms

  @IsEnum(PaymentMethod)
  paymentMethod: PaymentMethod;

  @IsNumber()
  @Min(0)
  @Max(100)
  depositPercentage: number;

  @IsOptional()
  @IsNumber()
  installmentCount?: number;

  @IsOptional()
  @IsNumber()
  paymentDuesDays?: number;

  @IsDateString()
  signatureDeadline: string;

  @IsDateString()
  deliveryStartDate: string;

  @IsDateString()
  deliveryEndDate: string;

  @IsDateString()
  expiryDate: string;

  @IsOptional()
  @IsBoolean()
  insuranceRequired?: boolean;

  @IsOptional()
  @IsString()
  insuranceProvider?: string;

  @IsOptional()
  @IsBoolean()
  phytosanitaryCertificateRequired?: boolean;

  @IsOptional()
  @IsString()
  additionalTerms?: string;
}

// ============================================
// SIGN CONTRACT DTO
// ============================================

export class SignContractDTO {
  @IsUUID()
  contractId: string;

  @IsString()
  signature: string; // Base64 or image URL

  @IsBoolean()
  agreeToTerms: boolean;

  @IsOptional()
  @IsString()
  ipAddress?: string; // For audit trail

  @IsOptional()
  @IsString()
  deviceInfo?: string; // Device identification
}

// ============================================
// AMEND CONTRACT DTO
// ============================================

export class AmendContractDTO {
  @IsUUID()
  contractId: string;

  @IsEnum(AmendmentReason)
  reason: AmendmentReason;

  @IsString()
  description: string;

  @IsOptional()
  @IsString()
  proposedChanges?: string; // JSON object

  @IsOptional()
  @IsNumber()
  newPrice?: number;

  @IsOptional()
  @IsNumber()
  newQuantity?: number;

  @IsOptional()
  @IsDateString()
  newDeliveryDate?: string;

  @IsOptional()
  @IsString()
  newQuality?: string;
}

// ============================================
// APPROVE AMENDMENT DTO
// ============================================

export class ApproveAmendmentDTO {
  @IsUUID()
  amendmentId: string;

  @IsBoolean()
  approved: boolean;

  @IsOptional()
  @IsString()
  rejectionReason?: string;
}

// ============================================
// INITIATE DISPUTE DTO
// ============================================

export class InitiateDisputeDTO {
  @IsUUID()
  contractId: string;

  @IsString()
  disputeReason: string;

  @IsString()
  evidence: string; // Description/URL of evidence

  @IsOptional()
  @IsUUID()
  preferredMediatorId?: string;
}

// ============================================
// RESPONSE DTOs
// ============================================

export class ContractResponseDTO {
  id: string;
  lotId: string;
  rfqId?: string;
  buyerId: string;
  buyerName: string;
  sellerId: string;
  sellerName: string;
  contractType: string;
  status: string;
  templateName: string;
  totalValue: number;
  totalQuantity: number;
  unit: string;
  currency: string;
  pricePerUnit: number;
  requiredGrade: string;
  paymentMethod: string;
  depositPercentage: number;
  signatureDeadline: Date;
  deliveryStartDate: Date;
  deliveryEndDate: Date;
  expiryDate: Date;
  buyerSigned: boolean;
  buyerSignedAt?: Date;
  sellerSigned: boolean;
  sellerSignedAt?: Date;
  isDisputed: boolean;
  disputeReason?: string;
  amendmentCount: number;
  insuranceRequired: boolean;
  insurancePolicyNumber?: string;
  phytosanitaryCertificateRequired: boolean;
  createdAt: Date;
  updatedAt: Date;
  executedAt?: Date;
}

export class ContractListResponseDTO {
  id: string;
  contractType: string;
  status: string;
  totalValue: number;
  buyerName: string;
  sellerName: string;
  signatureDeadline: Date;
  deliveryEndDate: Date;
  buyerSigned: boolean;
  sellerSigned: boolean;
  isDisputed: boolean;
  createdAt: Date;
}

export class AmendmentResponseDTO {
  id: string;
  contractId: string;
  reason: string;
  description: string;
  status: string;
  buyerApproved: boolean;
  sellerApproved: boolean;
  submittedBy: string;
  rejectionReason?: string;
  createdAt: Date;
}
