import { IsDecimal, IsString, IsUUID, IsOptional, IsDate, IsEnum } from 'class-validator';

// Create Quote DTO (Seller sends quote to buyer)
export class CreateQuoteDto {
  @IsUUID()
  orderId: string;

  @IsDecimal({ decimal_digits: '2' })
  quotedPrice: number;

  @IsDecimal({ decimal_digits: '2' })
  quotedQuantity: number;

  @IsString()
  quantityUnit: string;

  @IsOptional()
  @IsString()
  termsAndConditions?: string;

  @IsOptional()
  @IsString()
  notes?: string;

  @IsOptional()
  @IsString()
  deliveryLocation?: string;

  @IsOptional()
  @IsDate()
  proposedDeliveryDate?: Date;
}

// Counter Quote DTO (Response to a quote)
export class CounterQuoteDto {
  @IsUUID()
  originalQuoteId: string;

  @IsDecimal({ decimal_digits: '2' })
  quotedPrice: number;

  @IsDecimal({ decimal_digits: '2' })
  quotedQuantity: number;

  @IsString()
  quantityUnit: string;

  @IsOptional()
  @IsString()
  termsAndConditions?: string;

  @IsOptional()
  @IsString()
  notes?: string;

  @IsOptional()
  @IsString()
  deliveryLocation?: string;

  @IsOptional()
  @IsDate()
  proposedDeliveryDate?: Date;
}

// Accept Quote DTO
export class AcceptQuoteDto {
  @IsUUID()
  quoteId: string;
}

// Reject Quote DTO
export class RejectQuoteDto {
  @IsUUID()
  quoteId: string;

  @IsOptional()
  @IsString()
  rejectionReason?: string;
}

// Quote Response DTO
export class QuoteResponseDto {
  id: string;
  orderId: string;
  lotId: string;
  fromUserId: string;
  toUserId: string;
  quoteType?: string;
  quotedPrice: number;
  quotedQuantity: number;
  quantityUnit: string;
  termsAndConditions?: string;
  notes?: string;
  deliveryLocation?: string;
  proposedDeliveryDate?: Date;
  status: string;
  expiresAt: Date;
  createdAt: Date;
  updatedAt: Date;
  fromUser?: {
    id: string;
    fullName: string;
    phoneNumber?: string;
  };
  toUser?: {
    id: string;
    fullName: string;
    phoneNumber?: string;
  };
}

// Quote Search Query DTO
export class QuoteSearchQueryDto {
  @IsOptional()
  @IsEnum(['pending', 'accepted', 'rejected', 'expired', 'countered'])
  status?: 'pending' | 'accepted' | 'rejected' | 'expired' | 'countered';

  @IsOptional()
  @IsString()
  sortBy?: 'createdAt' | 'quotedPrice' | 'expiresAt';

  @IsOptional()
  @IsString()
  order?: 'ASC' | 'DESC';

  @IsOptional()
  skip?: number;

  @IsOptional()
  take?: number;
}
