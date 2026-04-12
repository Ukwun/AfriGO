import { IsString, IsNumber, IsArray, IsOptional, IsEnum, IsLatitude, IsLongitude, IsPositive, Min, Max } from 'class-validator';

export class CreateLotDto {
  @IsString()
  productName: string;

  @IsNumber()
  @IsPositive()
  quantity: number;

  @IsString()
  quantityUnit: string; // kg, bag, ton, etc.

  @IsNumber()
  @IsPositive()
  pricePerUnit: number;

  @IsString()
  description: string;

  @IsArray()
  @IsString({ each: true })
  images: string[]; // URLs from image upload

  @IsString()
  pickupLocation: string;

  @IsLatitude()
  latitude: number;

  @IsLongitude()
  longitude: number;

  @IsOptional()
  @IsString()
  category?: string;

  @IsArray()
  @IsString({ each: true })
  @IsOptional()
  certifications?: string[];
}

export class UpdateLotDto {
  @IsOptional()
  @IsString()
  productName?: string;

  @IsOptional()
  @IsNumber()
  @IsPositive()
  quantity?: number;

  @IsOptional()
  @IsString()
  quantityUnit?: string;

  @IsOptional()
  @IsNumber()
  @IsPositive()
  pricePerUnit?: number;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  images?: string[];

  @IsOptional()
  @IsString()
  pickupLocation?: string;

  @IsOptional()
  @IsLatitude()
  latitude?: number;

  @IsOptional()
  @IsLongitude()
  longitude?: number;

  @IsOptional()
  @IsEnum(['draft', 'active', 'sold', 'expired'])
  status?: 'draft' | 'active' | 'sold' | 'expired';

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  certifications?: string[];

  @IsOptional()
  @IsString()
  category?: string;
}

export class LotResponseDto {
  id: string;
  sellerId: string;
  sellerName?: string;
  sellerRating?: number;
  productName: string;
  quantity: number;
  quantityUnit: string;
  pricePerUnit: number;
  description: string;
  images: string[];
  pickupLocation: string;
  latitude: number;
  longitude: number;
  qrCode?: string;
  status: 'draft' | 'active' | 'sold' | 'expired';
  verifyStatus: 'pending' | 'verified' | 'rejected';
  certifications: string[];
  category?: string;
  viewCount: number;
  averageRating: number;
  ratingCount: number;
  createdAt: Date;
  updatedAt: Date;
}

export class LotSearchQueryDto {
  @IsOptional()
  @IsString()
  productName?: string;

  @IsOptional()
  @IsNumber()
  minPrice?: number;

  @IsOptional()
  @IsNumber()
  maxPrice?: number;

  @IsOptional()
  @IsString()
  location?: string;

  @IsOptional()
  @IsEnum(['draft', 'active', 'sold', 'expired'])
  status?: 'draft' | 'active' | 'sold' | 'expired';

  @IsOptional()
  @IsNumber()
  @Min(1)
  page?: number;

  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(100)
  limit?: number;

  @IsOptional()
  @IsEnum(['newest', 'oldest', 'priceLow', 'priceHigh', 'ratings'])
  sortBy?: string;
}
