-- Migration: Create Quality Inspection Tables
-- Description: Tables for quality inspection workflow with visual, lab, and AI analysis
-- Created: Week 4 Quality & Lab Management Module

-- Drop existing tables if migration is rolled back
-- DROP TABLE IF EXISTS "quality_inspection" CASCADE;
-- DROP TABLE IF EXISTS "lab_certification" CASCADE;

-- Create Lab Certification Registry Table
CREATE TABLE IF NOT EXISTS "lab_certification" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "labName" VARCHAR(255) NOT NULL,
  "labCode" VARCHAR(50) UNIQUE NOT NULL,
  "country" VARCHAR(100) NOT NULL,
  "certificationNumber" VARCHAR(100) NOT NULL,
  "accreditationBody" VARCHAR(255),
  "testingCapabilities" TEXT[] DEFAULT '{}',
  "contactPerson" VARCHAR(255),
  "email" VARCHAR(255),
  "phone" VARCHAR(20),
  "testsCompleted" INTEGER DEFAULT 0,
  "averageAccuracy" DECIMAL(5, 2) DEFAULT 100,
  "expiryDate" TIMESTAMP NOT NULL,
  "status" VARCHAR(50) DEFAULT 'active' CHECK (status IN ('active', 'expired', 'suspended', 'revoked')),
  "createdAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  "metadata" JSONB
);

CREATE INDEX "IDX_lab_certification_status" ON "lab_certification"("status");
CREATE INDEX "IDX_lab_certification_code" ON "lab_certification"("labCode");
CREATE INDEX "IDX_lab_certification_country" ON "lab_certification"("country");
CREATE INDEX "IDX_lab_certification_expiry" ON "lab_certification"("expiryDate");

-- Create Quality Inspection Table
CREATE TABLE IF NOT EXISTS "quality_inspection" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "lotId" UUID NOT NULL REFERENCES "lot"("id") ON DELETE CASCADE,
  "inspectionType" VARCHAR(50) NOT NULL CHECK (inspectionType IN ('visual', 'lab', 'ai', 'manual')),
  "status" VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'approved', 'rejected')),
  
  -- Inspector & Approver References
  "inspectorId" UUID REFERENCES "user"("id") ON DELETE SET NULL,
  "approverId" UUID REFERENCES "user"("id") ON DELETE SET NULL,
  "labCertificationId" UUID REFERENCES "lab_certification"("id") ON DELETE SET NULL,
  
  -- Visual Inspection Results
  "visualGrade" VARCHAR(10),
  "visualDefectPercentage" DECIMAL(5, 2),
  "visualDefectsFound" TEXT[],
  "visualPhotos" TEXT[],
  
  -- Lab Test Results
  "moistureContent" DECIMAL(5, 2),
  "afflatoxinLevel" DECIMAL(8, 2),
  "foreignMatterPercentage" DECIMAL(5, 2),
  "pH" DECIMAL(3, 1),
  "bacterialCount" VARCHAR(255),
  "insectCount" INTEGER,
  
  -- AI Analysis Results
  "aiPredictedGrade" VARCHAR(10),
  "aiConfidenceScore" DECIMAL(5, 2),
  "aiAnalysisJSON" JSONB,
  
  -- Final Decision
  "finalGrade" VARCHAR(10),
  "isApproved" BOOLEAN DEFAULT FALSE,
  "approvalNotes" TEXT,
  "manualOverrideReason" TEXT,
  
  -- Timestamps
  "createdAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  "completedAt" TIMESTAMP,
  "approvedAt" TIMESTAMP,
  
  -- Meta
  "metadata" JSONB
);

CREATE INDEX "IDX_quality_inspection_lot" ON "quality_inspection"("lotId");
CREATE INDEX "IDX_quality_inspection_status" ON "quality_inspection"("status");
CREATE INDEX "IDX_quality_inspection_type" ON "quality_inspection"("inspectionType");
CREATE INDEX "IDX_quality_inspection_inspector" ON "quality_inspection"("inspectorId");
CREATE INDEX "IDX_quality_inspection_grade" ON "quality_inspection"("finalGrade");
CREATE INDEX "IDX_quality_inspection_approved" ON "quality_inspection"("isApproved");
CREATE INDEX "IDX_quality_inspection_lot_status" ON "quality_inspection"("lotId", "status");
CREATE INDEX "IDX_quality_inspection_created" ON "quality_inspection"("createdAt");

-- Add quality_inspection trigger to update parent Lot grade
CREATE OR REPLACE FUNCTION update_lot_grade_on_approval()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW."isApproved" = TRUE AND OLD."isApproved" = FALSE THEN
    UPDATE "lot" 
    SET "gradeLevel" = NEW."finalGrade",
        "updatedAt" = CURRENT_TIMESTAMP
    WHERE "id" = NEW."lotId";
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_lot_grade_on_approval
  AFTER UPDATE ON "quality_inspection"
  FOR EACH ROW
  EXECUTE FUNCTION update_lot_grade_on_approval();

-- Ensure lot table has gradeLevel column (if not already present)
ALTER TABLE "lot" ADD COLUMN IF NOT EXISTS "gradeLevel" VARCHAR(10);

COMMIT;
