import {
  IsString,
  IsNumber,
  IsEnum,
  IsOptional,
  IsPositive,
  IsDateString,
  IsUUID,
  IsObject,
  Min,
  Max,
  MinDate,
} from 'class-validator';
import { Type } from 'class-transformer';

/**
 * Payment Method Enum - Defines 5 supported payment methods
 */
export enum PaymentMethodEnum {
  FULL_UPFRONT = 'FULL_UPFRONT',
  PARTIAL_DEPOSIT = 'PARTIAL_DEPOSIT',
  ON_DELIVERY = 'ON_DELIVERY',
  INSTALLMENT = 'INSTALLMENT',
  ESCROW = 'ESCROW',
}

/**
 * Payment Status Enum - 7 possible payment states
 */
export enum PaymentStatusEnum {
  PENDING = 'PENDING',
  INITIATED = 'INITIATED',
  PROCESSING = 'PROCESSING',
  COMPLETED = 'COMPLETED',
  FAILED = 'FAILED',
  REFUNDED = 'REFUNDED',
  DISPUTED = 'DISPUTED',
}

/**
 * Supported Currencies - Multi-currency platform (6 currencies)
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
 * DTO 1: CreatePaymentDto
 * Used when initiating a new payment from a contract
 * @example
 * {
 *   "contractId": "uuid",
 *   "paymentMethod": "FULL_UPFRONT",
 *   "amount": 1500.00,
 *   "currency": "KES",
 *   "paymentTerms": { "netDays": 30 }
 * }
 */
export class CreatePaymentDto {
  @IsUUID('4', { message: 'Contract ID must be a valid UUID' })
  contractId: string;

  @IsEnum(PaymentMethodEnum, {
    message: `Payment method must be one of: ${Object.values(PaymentMethodEnum).join(', ')}`,
  })
  paymentMethod: PaymentMethodEnum;

  @IsNumber({ maxDecimalPlaces: 2 }, { message: 'Amount must be a valid number with max 2 decimal places' })
  @IsPositive({ message: 'Amount must be greater than 0' })
  amount: number;

  @IsEnum(CurrencyEnum, {
    message: `Currency must be one of: ${Object.values(CurrencyEnum).join(', ')}`,
  })
  currency: CurrencyEnum;

  @IsOptional()
  @IsObject({ message: 'Payment terms must be a JSON object' })
  paymentTerms?: Record<string, any>; // Flexible for different payment terms
}

/**
 * DTO 2: UpdatePaymentStatusDto
 * Used when updating payment status (e.g., after Flutterwave webhook)
 * @example
 * {
 *   "status": "COMPLETED",
 *   "transactionReference": "FLW-12345678",
 *   "metadata": { "flutterwaveResponse": {...} }
 * }
 */
export class UpdatePaymentStatusDto {
  @IsEnum(PaymentStatusEnum, {
    message: `Status must be one of: ${Object.values(PaymentStatusEnum).join(', ')}`,
  })
  status: PaymentStatusEnum;

  @IsOptional()
  @IsString({ message: 'Transaction reference must be a string' })
  transactionReference?: string;

  @IsOptional()
  @IsObject({ message: 'Metadata must be a JSON object' })
  metadata?: Record<string, any>; // Flutterwave response or additional data
}

/**
 * DTO 3: VerifyPaymentDto
 * Used when verifying a Flutterwave payment webhook
 * @example
 * {
 *   "flutterwaveTransactionId": "123456789",
 *   "amount": 1500.00,
 *   "currency": "KES",
 *   "timestamp": "2026-04-12T10:00:00Z"
 * }
 */
export class VerifyPaymentDto {
  @IsString({ message: 'Flutterwave transaction ID must be a string' })
  flutterwaveTransactionId: string;

  @IsNumber({ maxDecimalPlaces: 2 })
  @IsPositive()
  amount: number;

  @IsEnum(CurrencyEnum)
  currency: CurrencyEnum;

  @IsDateString({}, { message: 'Timestamp must be a valid ISO date string' })
  timestamp: string;
}

/**
 * DTO 4: RefundPaymentDto
 * Used when buyer requests refund (disputes, returns, etc.)
 * @example
 * {
 *   "reason": "Product quality issues",
 *   "refundAmount": 1500.00,
 *   "metadata": { "disputeId": "...", "proofUrl": "..." }
 * }
 */
export class RefundPaymentDto {
  @IsString({ message: 'Reason must be a string' })
  reason: string;

  @IsNumber({ maxDecimalPlaces: 2 })
  @IsPositive()
  refundAmount: number;

  @IsOptional()
  @IsObject()
  metadata?: Record<string, any>; // Evidence, dispute reference, etc.
}

/**
 * DTO 5: DisputePaymentDto
 * Used when buyer or seller disputes a payment/transaction
 * @example
 * {
 *   "reason": "Product not received",
 *   "evidence": "https://s3.amazonaws.com/evidence.jpg",
 *   "metadata": { "shipmentStatus": "LOST" }
 * }
 */
export class DisputePaymentDto {
  @IsString({ message: 'Reason must be a string' })
  reason: string;

  @IsOptional()
  @IsString({ message: 'Evidence URL must be a string' })
  evidence?: string; // URL to photo, document, etc.

  @IsOptional()
  @IsObject()
  metadata?: Record<string, any>; // Additional dispute info
}

/**
 * DTO 6: ProcessInstallmentDto
 * Used when processing an installment payment (for INSTALLMENT method)
 * @example
 * {
 *   "installmentNumber": 2,
 *   "amount": 500.00,
 *   "dueDate": "2026-05-12T23:59:59Z",
 *   "penalties": { "lateFeePercentage": 2, "perDays": 10 }
 * }
 */
export class ProcessInstallmentDto {
  @IsNumber({ allowInfinity: false, allowNaN: false })
  @Min(1, { message: 'Installment number must be at least 1' })
  @Max(12, { message: 'Installment number must not exceed 12' })
  installmentNumber: number;

  @IsNumber({ maxDecimalPlaces: 2 })
  @IsPositive()
  amount: number;

  @IsDateString({}, { message: 'Due date must be a valid ISO date string' })
  @MinDate(new Date(), { message: 'Due date must be in the future' })
  dueDate: string;

  @IsOptional()
  @IsObject()
  penalties?: {
    lateFeePercentage: number;
    perDays: number;
  };
}

/**
 * DTO 7: PaymentStatisticsQueryDto
 * Used when querying payment statistics and generating reports
 * @example
 * {
 *   "startDate": "2026-04-01T00:00:00Z",
 *   "endDate": "2026-04-30T23:59:59Z",
 *   "status": "COMPLETED",
 *   "paymentMethod": "ESCROW"
 * }
 */
export class PaymentStatisticsQueryDto {
  @IsOptional()
  @IsDateString()
  startDate?: string;

  @IsOptional()
  @IsDateString()
  endDate?: string;

  @IsOptional()
  @IsEnum(PaymentStatusEnum)
  status?: PaymentStatusEnum;

  @IsOptional()
  @IsEnum(PaymentMethodEnum)
  paymentMethod?: PaymentMethodEnum;

  @IsOptional()
  @IsEnum(CurrencyEnum)
  currency?: CurrencyEnum;
}

/**
 * DTO 8: CreateInvoiceDto
 * Used when generating invoice for a payment
 * @example
 * {
 *   "paymentId": "uuid",
 *   "items": [{ "description": "Cocoa beans", "quantity": 1000, "unit": "kg", "unitPrice": 1.5 }],
 *   "taxRate": 0.16,
 *   "notes": "Payment due within 30 days"
 * }
 */
export class CreateInvoiceDto {
  @IsUUID('4')
  paymentId: string;

  @IsOptional()
  @IsObject({ each: true })
  items?: Array<{
    description: string;
    quantity: number;
    unit: string;
    unitPrice: number;
  }>;

  @IsOptional()
  @IsNumber({ maxDecimalPlaces: 4 })
  @Min(0)
  @Max(1)
  taxRate?: number; // 0-100% as decimal (0.16 = 16%)

  @IsOptional()
  @IsString()
  notes?: string;
}

/**
 * Response DTO for payment creation
 * Returned after successful CreatePaymentDto submission
 */
export class PaymentResponseDto {
  id: string;
  contractId: string;
  reference: string; // INV-2026-001001 format
  amount: number;
  currency: CurrencyEnum;
  paymentMethod: PaymentMethodEnum;
  status: PaymentStatusEnum;
  createdAt: Date;
  dueDate?: Date;
}

/**
 * Response DTO for payment list queries
 * Includes pagination metadata
 */
export class PaymentListResponseDto {
  data: PaymentResponseDto[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    pageCount: number;
  };
}

/**
 * Response DTO for payment statistics
 * Summary data for analytics dashboards
 */
export class PaymentStatisticsResponseDto {
  totalTransactions: number;
  totalAmount: number;
  averageAmount: number;
  byStatus: {
    status: PaymentStatusEnum;
    count: number;
    totalAmount: number;
  }[];
  byMethod: {
    method: PaymentMethodEnum;
    count: number;
    totalAmount: number;
  }[];
  byCurrency: {
    currency: CurrencyEnum;
    count: number;
    totalAmount: number;
  }[];
}
