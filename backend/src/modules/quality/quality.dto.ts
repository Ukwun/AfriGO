import {
  IsString,
  IsNumber,
  IsOptional,
  IsArray,
  IsBoolean,
  IsUUID,
  Min,
  Max,
  MinLength,
} from 'class-validator';

export class CreateQualityInspectionDTO {
  @IsUUID()
  lotId: string;

  @IsString()
  @MinLength(3)
  inspectionType: string; // visual, lab, ai, manual

  @IsOptional()
  @IsUUID()
  labCertificationId?: string;

  @IsOptional()
  @IsUUID()
  inspectorId?: string;
}

export class SubmitVisualInspectionDTO {
  @IsUUID()
  inspectionId: string;

  @IsString()
  @MinLength(1)
  visualGrade: string; // A, B, C, Rejected

  @IsNumber()
  @Min(0)
  @Max(100)
  visualDefectPercentage: number;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  visualDefectsFound?: string[];

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  inspectionPhotos?: string[];
}

export class SubmitLabTestDTO {
  @IsUUID()
  inspectionId: string;

  @IsOptional()
  @IsNumber()
  @Min(0)
  @Max(50)
  moistureContent?: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  afflatoxinLevel?: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  @Max(100)
  foreignMatterPercentage?: number;

  @IsOptional()
  @IsNumber()
  insectFragmentCount?: number;

  @IsOptional()
  @IsNumber()
  pH?: number;

  @IsOptional()
  @IsString()
  bacterialCount?: string;

  @IsOptional()
  labCertificationId?: string;
}

export class ApproveQualityInspectionDTO {
  @IsUUID()
  inspectionId: string;

  @IsString()
  @MinLength(1)
  finalGrade: string; // A, B, C, Rejected

  @IsBoolean()
  isApproved: boolean;

  @IsOptional()
  @IsString()
  approvalNotes?: string;
}

export class QualityInspectionResponseDTO {
  id: string;
  lotId: string;
  inspectionType: string;
  status: string;
  visualGrade: string | null;
  visualDefectPercentage: number | null;
  visualDefectsFound: string[] | null;
  inspectionPhotos: string[];
  moistureContent: number | null;
  afflatoxinLevel: number | null;
  foreignMatterPercentage: number | null;
  insectFragmentCount: number | null;
  pH: number | null;
  bacterialCount: string | null;
  aiPredictedGrade: string | null;
  aiConfidenceScore: number | null;
  finalGrade: string | null;
  isApproved: boolean;
  approvalNotes: string | null;
  createdAt: Date;
  completedAt: Date | null;
  labName: string | null;
  inspectorName: string | null;
}

export class LabCertificationResponseDTO {
  id: string;
  labName: string;
  labCode: string;
  country: string;
  certificationNumber: string;
  issuedDate: Date;
  expiryDate: Date;
  accreditation: string;
  testingCertifications: string[];
  status: string;
  contactEmail: string;
  contactPhone: string;
  costPerTest: number | null;
  testsCompleted: number;
  averageAccuracy: number;
}

export class CreateLabCertificationDTO {
  @IsString()
  @MinLength(3)
  labName: string;

  @IsString()
  @MinLength(3)
  labCode: string;

  @IsString()
  @MinLength(2)
  country: string;

  @IsString()
  certificationNumber: string;

  @IsString()
  certificationUrl: string;

  @IsString()
  issuedDate: string; // ISO date

  @IsString()
  expiryDate: string; // ISO date

  @IsString()
  accreditation: string;

  @IsArray()
  @IsString({ each: true })
  testingCertifications: string[];

  @IsString()
  contactEmail: string;

  @IsString()
  contactPhone: string;

  @IsOptional()
  @IsNumber()
  costPerTest?: number;
}

export class QualityInspectionFilterDTO {
  @IsOptional()
  @IsString()
  status?: string;

  @IsOptional()
  @IsString()
  inspectionType?: string;

  @IsOptional()
  @IsUUID()
  lotId?: string;

  @IsOptional()
  @IsNumber()
  page?: number = 1;

  @IsOptional()
  @IsNumber()
  limit?: number = 20;
}
