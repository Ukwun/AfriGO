import { IsString, IsNumber, IsOptional, IsEnum, IsArray, IsDate, Min, Max, Length } from 'class-validator';
import { GradeLevel } from '../entities/lot.entity';

export class CreateLotDTO {
  @IsString()
  @Length(3, 255)
  productName: string;

  @IsString()
  @Length(1, 100)
  category: string;

  @IsNumber()
  @Min(0.01)
  quantity: number;

  @IsString()
  quantityUnit: string;

  @IsNumber()
  @Min(0.01)
  pricePerUnit: number;

  @IsString()
  @Length(10, 5000)
  description: string;

  @IsArray()
  @IsOptional()
  images: string[];

  @IsString()
  originCountry: string;

  @IsString()
  @IsOptional()
  originRegion: string;

  @IsString()
  @IsOptional()
  originLocation: string;

  @IsString()
  pickupLocation: string;

  @IsNumber()
  latitude: number;

  @IsNumber()
  longitude: number;

  @IsDate()
  @IsOptional()
  harvestDate: Date;

  @IsDate()
  @IsOptional()
  productionDate: Date;

  @IsDate()
  @IsOptional()
  expiryDate: Date;

  @IsEnum(GradeLevel)
  @IsOptional()
  gradeLevel: GradeLevel = GradeLevel.B;

  @IsNumber()
  @Min(0)
  @Max(100)
  @IsOptional()
  moistureContent: number;

  @IsNumber()
  @Min(0)
  @IsOptional()
  afflatoxinLevel: number;

  @IsNumber()
  @Min(0)
  @Max(100)
  @IsOptional()
  foreignMatterPercentage: number;

  @IsArray()
  @IsOptional()
  certifications: string[];

  @IsOptional()
  certifiedOrganic: boolean;

  @IsOptional()
  fairTradeCertified: boolean;
}

export class UpdateLotDTO {
  @IsString()
  @IsOptional()
  productName: string;

  @IsNumber()
  @IsOptional()
  @Min(0.01)
  quantity: number;

  @IsString()
  @IsOptional()
  quantityUnit: string;

  @IsNumber()
  @IsOptional()
  @Min(0.01)
  pricePerUnit: number;

  @IsString()
  @IsOptional()
  description: string;

  @IsArray()
  @IsOptional()
  images: string[];

  @IsString()
  @IsOptional()
  pickupLocation: string;

  @IsDate()
  @IsOptional()
  harvestDate: Date;

  @IsEnum(GradeLevel)
  @IsOptional()
  gradeLevel: GradeLevel;

  @IsNumber()
  @IsOptional()
  @Min(0)
  @Max(100)
  moistureContent: number;
}

export class LotResponseDTO {
  id: string;
  productName: string;
  category: string;
  quantity: number;
  quantityReserved: number;
  quantitySold: number;
  quantityUnit: string;
  pricePerUnit: number;
  totalValue: number;
  batchNumber: string;
  qrCode: string;
  originCountry: string;
  originRegion: string;
  originLocation: string;
  pickupLocation: string;
  harvestDate: Date;
  productionDate: Date;
  expiryDate: Date;
  gradeLevel: GradeLevel;
  status: string;
  verifyStatus: string;
  seller: {
    id: string;
    email: string;
    firstName: string;
    lastName: string;
  };
  images: string[];
  certifications: string[];
  createdAt: Date;
  updatedAt: Date;
}

export class LotFilterDTO {
  @IsString()
  @IsOptional()
  category: string;

  @IsString()
  @IsOptional()
  originCountry: string;

  @IsString()
  @IsOptional()
  status: string;

  @IsNumber()
  @IsOptional()
  minPrice: number;

  @IsNumber()
  @IsOptional()
  maxPrice: number;

  @IsEnum(GradeLevel)
  @IsOptional()
  gradeLevel: GradeLevel;

  @IsString()
  @IsOptional()
  searchTerm: string;
}
