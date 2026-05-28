import { IsString, IsNumber, IsOptional, IsDateString, IsArray, Min, MinLength, MaxLength } from 'class-validator';

export class CreateRFQDTO {
  @IsString()
  @MinLength(3)
  productCategory: string;

  @IsString()
  @MinLength(20)
  @MaxLength(2000)
  productDescription: string;

  @IsString()
  @MinLength(10)
  @MaxLength(5000)
  description: string;

  @IsNumber()
  @Min(0.01)
  quantity: number;

  @IsString()
  @MinLength(1)
  quantityUnit: string;

  @IsOptional()
  @IsString()
  originCountryPreference?: string;

  @IsOptional()
  @IsString()
  gradePreference?: string;

  @IsOptional()
  @IsString()
  deliveryLocation?: string;

  @IsDateString()
  deliveryDeadline: string;

  @IsString()
  @MinLength(5)
  paymentTerms: string;

  @IsNumber()
  @Min(1)
  maxBidsExpected: number;
}

export class SubmitBidDTO {
  @IsString()
  rfqId: string;

  @IsNumber()
  @Min(0.01)
  pricePerUnit: number;

  @IsString()
  @MinLength(2)
  originCountry: string;

  @IsString()
  @MinLength(1)
  gradeLevel: string;

  @IsDateString()
  estimatedDelivery: string;

  @IsString()
  @MinLength(3)
  paymentMethod: string;

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  specialTerms?: string;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  certificationsIncluded?: string[];
}

export class RFQBidResponseDTO {
  id: string;
  rfqId: string;
  supplierId: string;
  supplierEmail: string;
  supplierCompanyName: string;
  pricePerUnit: number;
  totalPrice: number;
  originCountry: string | null;
  gradeLevel: string | null;
  estimatedDelivery: Date;
  paymentMethod: string;
  specialTerms: string | null;
  status: string;
  submittedAt: Date;
  documentCount: number;
  certificationsIncluded: string[] | null;
}

export class RFQResponseDTO {
  id: string;
  buyerId: string;
  buyerEmail: string;
  buyerCompanyName: string;
  productCategory: string;
  productDescription: string;
  quantity: number;
  quantityUnit: string;
  originCountryPreference: string | null;
  gradePreference: string | null;
  deliveryLocation: string | null;
  deliveryDeadline: Date;
  paymentTerms: string;
  maxBidsExpected: number;
  submittedBids: RFQBidResponseDTO[];
  status: string;
  selectedSupplierId: string | null;
  selectedSupplierBidId: string | null;
  createdAt: Date;
  expiresAt: Date;
  description: string;
}

export class RFQFilterDTO {
  status?: string;
  category?: string;
  searchTerm?: string;
  page?: number = 1;
  limit?: number = 20;
}

export class AwardBidDTO {
  @IsString()
  bidId: string;
}
