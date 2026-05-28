import {
  IsString,
  IsNumber,
  IsEnum,
  IsOptional,
  IsPositive,
  IsUUID,
  IsObject,
  IsBoolean,
  Min,
  Max,
} from 'class-validator';

/**
 * Escrow Status Enum - 7 possible escrow states
 */
export enum EscrowStatusEnum {
  CREATED = 'CREATED',
  FUNDED = 'FUNDED',
  HELD = 'HELD',
  RELEASED = 'RELEASED',
  REFUNDED = 'REFUNDED',
  DISPUTED = 'DISPUTED',
  RESOLVED = 'RESOLVED',
}

/**
 * Escrow Release Condition Enum - Conditions that trigger fund release
 */
export enum ReleaseConditionEnum {
  DELIVERY_PROOF = 'DELIVERY_PROOF',
  QUALITY_APPROVAL = 'QUALITY_APPROVAL',
  BUYER_SIGNOFF = 'BUYER_SIGNOFF',
}

/**
 * Currency Enum - Supported currencies for escrow
 */
export enum CurrencyEnum {
  KES = 'KES',
  USD = 'USD',
  EUR = 'EUR',
  ZAR = 'ZAR',
  UGX = 'UGX',
  TZS = 'TZS',
}

/**
 * DTO 1: CreateEscrowDto
 * Used to create a new escrow fund hold when payment is completed
 * Escrow holds funds until all release conditions are met
 *
 * @example
 * {
 *   "contractId": "uuid",
 *   "amount": 5000.00,
 *   "currency": "KES",
 *   "holdingPeriodDays": 7,
 *   "releaseConditions": ["DELIVERY_PROOF", "QUALITY_APPROVAL", "BUYER_SIGNOFF"],
 *   "holdingFeePercentage": 0.5
 * }
 */
export class CreateEscrowDto {
  @IsUUID('4', { message: 'Contract ID must be a valid UUID' })
  contractId: string;

  @IsNumber({ maxDecimalPlaces: 2 }, { message: 'Amount must be a valid number with max 2 decimal places' })
  @IsPositive({ message: 'Amount must be greater than 0' })
  amount: number;

  @IsEnum(CurrencyEnum, {
    message: `Currency must be one of: ${Object.values(CurrencyEnum).join(', ')}`,
  })
  currency: CurrencyEnum;

  @IsNumber({ allowInfinity: false, allowNaN: false })
  @Min(1, { message: 'Holding period must be at least 1 day' })
  @Max(90, { message: 'Holding period must not exceed 90 days' })
  holdingPeriodDays: number;

  @IsOptional()
  @IsEnum(ReleaseConditionEnum, {
    each: true,
    message: `Each release condition must be one of: ${Object.values(ReleaseConditionEnum).join(', ')}`,
  })
  releaseConditions?: ReleaseConditionEnum[]; // Default: all 3 conditions

  @IsOptional()
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0, { message: 'Holding fee percentage must be at least 0' })
  @Max(5, { message: 'Holding fee percentage must not exceed 5' })
  holdingFeePercentage?: number; // 0-5% for fund holding charges
}

/**
 * DTO 2: UpdateEscrowStatusDto
 * Used to update escrow status (funding, holding, disputes, etc.)
 *
 * @example
 * {
 *   "status": "HELD",
 *   "metadata": { "fundedAt": "2026-04-12T10:00:00Z", "disbursementGateway": "flutterwave" }
 * }
 */
export class UpdateEscrowStatusDto {
  @IsEnum(EscrowStatusEnum, {
    message: `Status must be one of: ${Object.values(EscrowStatusEnum).join(', ')}`,
  })
  status: EscrowStatusEnum;

  @IsOptional()
  @IsObject({ message: 'Metadata must be a JSON object' })
  metadata?: Record<string, any>; // Flexible for additional status info
}

/**
 * DTO 3: ReleaseEscrowDto
 * Used to mark a release condition as met and check for full release eligibility
 * When all conditions are met, funds are automatically released to seller
 *
 * @example
 * {
 *   "condition": "DELIVERY_PROOF",
 *   "proofUrl": "https://s3.amazonaws.com/delivery-proof-123.jpg",
 *   "metadata": { "proofType": "photo", "timestamp": "2026-04-15T10:00:00Z" }
 * }
 */
export class ReleaseEscrowDto {
  @IsEnum(ReleaseConditionEnum, {
    message: `Condition must be one of: ${Object.values(ReleaseConditionEnum).join(', ')}`,
  })
  condition: ReleaseConditionEnum;

  @IsOptional()
  @IsString({ message: 'Proof URL must be a string' })
  proofUrl?: string; // URL to evidence (photo, document, signature, etc.)

  @IsOptional()
  @IsObject({ message: 'Metadata must be a JSON object' })
  metadata?: Record<string, any>; // Proof metadata (timestamp, type, verificationHash, etc.)
}

/**
 * DTO 4: DisputeEscrowDto
 * Used when either party disputes the escrow or fund release
 * Disputes require admin/mediator resolution
 *
 * @example
 * {
 *   "reason": "Seller claims product quality issue, buyer disagrees",
 *   "evidence": "https://s3.amazonaws.com/dispute-evidence.jpg",
 *   "metadata": { "disputeType": "quality", "desiredOutcome": "partial_refund" }
 * }
 */
export class DisputeEscrowDto {
  @IsString({ message: 'Reason must be a string' })
  reason: string;

  @IsOptional()
  @IsString({ message: 'Evidence URL must be a string' })
  evidence?: string; // URL to supporting documents/photos

  @IsOptional()
  @IsObject({ message: 'Metadata must be a JSON object' })
  metadata?: Record<string, any>; // Additional dispute context
}

/**
 * DTO 5: EscrowStatisticsQueryDto
 * Used to query escrow statistics for analytics and reporting
 *
 * @example
 * {
 *   "startDate": "2026-04-01T00:00:00Z",
 *   "endDate": "2026-04-30T23:59:59Z",
 *   "status": "RELEASED",
 *   "conditionStatus": { "DELIVERY_PROOF": true, "QUALITY_APPROVAL": false }
 * }
 */
export class EscrowStatisticsQueryDto {
  @IsOptional()
  @IsString({ message: 'Start date must be a valid ISO date string' })
  startDate?: string;

  @IsOptional()
  @IsString({ message: 'End date must be a valid ISO date string' })
  endDate?: string;

  @IsOptional()
  @IsEnum(EscrowStatusEnum)
  status?: EscrowStatusEnum;

  @IsOptional()
  @IsObject()
  conditionStatus?: {
    [key in ReleaseConditionEnum]?: boolean;
  };
}

// ============================================================================
// RESPONSE DTOs
// ============================================================================

/**
 * Response DTO for escrow creation/retrieval
 */
export class EscrowResponseDto {
  id: string;
  paymentId: string;
  amount: number;
  currency: CurrencyEnum;
  status: EscrowStatusEnum;
  holdingPeriodDays: number;
  holdingFeePercentage: number;
  conditionsMet: {
    [key in ReleaseConditionEnum]?: {
      met: boolean;
      metAt?: Date;
      proofUrl?: string;
    };
  };
  autoReleaseDate?: Date;
  releasedAt?: Date;
  refundedAt?: Date;
  createdAt: Date;
  updatedAt: Date;
}

/**
 * Response DTO for escrow conditions status
 * Used to show conditions tracking in mobile UI
 */
export class EscrowConditionsStatusDto {
  escrowId: string;
  allConditionsMet: boolean;
  conditions: {
    condition: ReleaseConditionEnum;
    met: boolean;
    metAt?: Date;
    requiredFor: 'FULL_PAYMENT' | 'PARTIAL_PAYMENT' | 'DISPUTE_RESOLUTION';
  }[];
  estimatedReleaseDate?: Date;
  daysUntilAutoRelease?: number;
}

/**
 * Response DTO for escrow statistics
 * Summary data for admin dashboards
 */
export class EscrowStatisticsResponseDto {
  totalEscrows: number;
  totalAmountHeld: number;
  averageAmountHeld: number;
  byStatus: {
    status: EscrowStatusEnum;
    count: number;
    totalAmount: number;
  }[];
  conditionsMostCommon: {
    condition: ReleaseConditionEnum;
    frequency: number;
    percentOfTotal: number;
  }[];
  averageHoldingPeriodDays: number;
  averageTimeToRelease: number; // in days
}

/**
 * Response DTO for dispute resolution history
 * Shows all disputes and their resolutions
 */
export class EscrowDisputeHistoryDto {
  escrowId: string;
  disputes: {
    id: string;
    reason: string;
    evidence?: string;
    status: 'OPEN' | 'UNDER_REVIEW' | 'RESOLVED';
    filedBy: 'BUYER' | 'SELLER' | 'ADMIN';
    filedAt: Date;
    resolvedAt?: Date;
    resolution?: {
      outcome: 'BUYER_WINS' | 'SELLER_WINS' | 'SPLIT';
      notes: string;
      disbursementPlan: {
        buyerAmount: number;
        sellerAmount: number;
      };
    };
  }[];
}
