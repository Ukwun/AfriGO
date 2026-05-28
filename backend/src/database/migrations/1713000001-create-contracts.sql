-- Migration: Create Contract Management Tables
-- Description: Tables for contracts, amendments, disputes, and mediation
-- Created: Week 6 Contracts & Agreements Module

CREATE TABLE IF NOT EXISTS "contract" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "lotId" UUID NOT NULL REFERENCES "lot"("id") ON DELETE CASCADE,
  "rfqId" UUID REFERENCES "rfq"("id") ON DELETE SET NULL,
  "buyerId" UUID NOT NULL REFERENCES "user"("id") ON DELETE CASCADE,
  "sellerId" UUID NOT NULL REFERENCES "user"("id") ON DELETE CASCADE,
  
  "contractType" VARCHAR(50) NOT NULL CHECK (contractType IN ('standard', 'bulk', 'premium', 'custom')),
  "status" VARCHAR(50) DEFAULT 'draft' CHECK (status IN ('draft', 'active', 'signed', 'executed', 'terminated', 'disputed')),
  "templateName" VARCHAR(255) NOT NULL,
  
  "totalValue" NUMERIC(12, 2) NOT NULL,
  "totalQuantity" NUMERIC(12, 2) NOT NULL,
  "unit" VARCHAR(50) NOT NULL DEFAULT 'MT',
  "currency" VARCHAR(10) DEFAULT 'USD',
  "pricePerUnit" NUMERIC(12, 2) NOT NULL,
  
  "requiredGrade" VARCHAR(10),
  "qualitySpecifications" TEXT,
  "deliveryTerms" VARCHAR(255),
  
  "paymentMethod" VARCHAR(50) NOT NULL CHECK (paymentMethod IN ('full_upfront', 'partial_deposit', 'on_delivery', 'installment', 'escrow')),
  "depositPercentage" NUMERIC(5, 2) DEFAULT 0,
  "installmentCount" INTEGER,
  "paymentDuesDays" INTEGER,
  
  "signatureDeadline" TIMESTAMP NOT NULL,
  "deliveryStartDate" TIMESTAMP NOT NULL,
  "deliveryEndDate" TIMESTAMP NOT NULL,
  "expiryDate" TIMESTAMP NOT NULL,
  
  "buyerSigned" BOOLEAN DEFAULT FALSE,
  "buyerSignedAt" TIMESTAMP,
  "buyerSignature" VARCHAR(500),
  
  "sellerSigned" BOOLEAN DEFAULT FALSE,
  "sellerSignedAt" TIMESTAMP,
  "sellerSignature" VARCHAR(500),
  
  "isDisputed" BOOLEAN DEFAULT FALSE,
  "disputeReason" TEXT,
  "mediatorId" UUID REFERENCES "user"("id") ON DELETE SET NULL,
  
  "amendmentCount" INTEGER DEFAULT 0,
  "insuranceRequired" BOOLEAN DEFAULT FALSE,
  "insuranceProvider" VARCHAR(255),
  "insurancePolicyNumber" VARCHAR(100),
  "phytosanitaryCertificateRequired" BOOLEAN DEFAULT FALSE,
  
  "additionalTerms" TEXT,
  "createdAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  "executedAt" TIMESTAMP,
  "metadata" JSONB
);

CREATE INDEX "IDX_contract_status_buyer" ON "contract"("status", "buyerId");
CREATE INDEX "IDX_contract_seller_status" ON "contract"("sellerId", "status");
CREATE INDEX "IDX_contract_expiry" ON "contract"("expiryDate");
CREATE INDEX "IDX_contract_lot" ON "contract"("lotId");
CREATE INDEX "IDX_contract_rfq" ON "contract"("rfqId");
CREATE INDEX "IDX_contract_disputed" ON "contract"("isDisputed");

-- Create Contract Amendment Table
CREATE TABLE IF NOT EXISTS "contract_amendment" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "contractId" UUID NOT NULL REFERENCES "contract"("id") ON DELETE CASCADE,
  "submittedBy" UUID NOT NULL REFERENCES "user"("id") ON DELETE CASCADE,
  
  "reason" VARCHAR(50) NOT NULL CHECK (reason IN ('price_adjustment', 'delivery_date_change', 'quantity_adjustment', 'quality_change', 'other')),
  "description" TEXT NOT NULL,
  "proposedChanges" TEXT,
  
  "status" VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  "buyerApproved" BOOLEAN DEFAULT FALSE,
  "sellerApproved" BOOLEAN DEFAULT FALSE,
  "approvedAt" TIMESTAMP,
  "rejectionReason" TEXT,
  
  "createdAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  "metadata" JSONB
);

CREATE INDEX "IDX_amendment_contract_status" ON "contract_amendment"("contractId", "status");
CREATE INDEX "IDX_amendment_submitted_by" ON "contract_amendment"("submittedBy");
CREATE INDEX "IDX_amendment_created" ON "contract_amendment"("createdAt");

-- Trigger: Auto-update contract updatedAt when signed
CREATE OR REPLACE FUNCTION update_contract_signature_status()
RETURNS TRIGGER AS $$
BEGIN
  IF (NEW."buyerSigned" = TRUE AND OLD."buyerSigned" = FALSE) OR
     (NEW."sellerSigned" = TRUE AND OLD."sellerSigned" = FALSE) THEN
    NEW."updatedAt" = CURRENT_TIMESTAMP;
    
    -- Auto-activate when both signed
    IF NEW."buyerSigned" = TRUE AND NEW."sellerSigned" = TRUE THEN
      NEW."status" = 'signed';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_contract_on_signature
  BEFORE UPDATE ON "contract"
  FOR EACH ROW
  EXECUTE FUNCTION update_contract_signature_status();

-- Trigger: Apply amendment when both parties approve
CREATE OR REPLACE FUNCTION auto_apply_amendment()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW."buyerApproved" = TRUE AND NEW."sellerApproved" = TRUE AND NEW."status" = 'pending' THEN
    NEW."status" = 'approved';
    NEW."approvedAt" = CURRENT_TIMESTAMP;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_auto_apply_amendment
  BEFORE UPDATE ON "contract_amendment"
  FOR EACH ROW
  EXECUTE FUNCTION auto_apply_amendment();

COMMIT;
