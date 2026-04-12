import {
  IsString,
  IsUUID,
  IsNumber,
  IsOptional,
  IsNotEmpty,
  Min,
  Max,
  IsEmail,
} from 'class-validator';

export class CreatePaymentDto {
  @IsUUID()
  orderId: string;

  @IsNumber()
  @Min(0.01)
  amount: number;

  @IsString()
  @IsNotEmpty()
  currency: string; // 'USD', 'GBP', etc. (default 'USD')

  // Stripe payment method ID (from Stripe.js)
  @IsString()
  @IsNotEmpty()
  paymentMethodId: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsString()
  idempotencyKey?: string; // Prevent duplicate charges
}

export class ConfirmPaymentDto {
  @IsString()
  @IsNotEmpty()
  paymentIntentId: string;

  @IsOptional()
  @IsString()
  paymentMethodId?: string;
}

export class RefundPaymentDto {
  @IsString()
  @IsNotEmpty()
  reason: string;

  @IsOptional()
  @IsNumber()
  @Min(0)
  amount?: number; // For partial refunds
}

export class PaymentMethodDto {
  @IsString()
  @IsNotEmpty()
  cardToken: string; // From Stripe Elements

  @IsString()
  @IsNotEmpty()
  @IsEmail()
  email: string;

  @IsString()
  @IsNotEmpty()
  cardholderName: string;

  @IsOptional()
  @IsString()
  billingAddress?: string;
}

export class PaymentResponseDto {
  id: string;
  orderId: string;
  userId: string;
  amount: number;
  currency: string;
  status: string; // pending, processing, succeeded, failed, cancelled
  escrowStatus: string; // pending, held, released, refunded
  paymentMethod: string;
  cardInfo?: {
    brand: string;
    last4: string;
    expiryMonth: number;
    expiryYear: number;
  };
  stripePaymentIntentId?: string;
  stripeChargeId?: string;
  receiptUrl?: string;
  createdAt: Date;
  paidAt?: Date;
  refundedAt?: Date;
  failureReason?: string;
}

export class PaymentListDto {
  id: string;
  orderId: string;
  amount: number;
  status: string;
  createdAt: Date;
  paidAt?: Date;
}

export class PayoutDto {
  id: string;
  sellerId: string;
  amount: number;
  status: string; // pending, processing, paid, failed
  paymentIds: string[];
  stripePayoutId?: string;
  createdAt: Date;
  paidAt?: Date;
}
