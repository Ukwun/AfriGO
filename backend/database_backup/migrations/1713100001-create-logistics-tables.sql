-- Week 7: Logistics & Shipment Tracking Module
-- Created: April 12, 2026
-- Tables: shipment, shipment_tracking, delivery_proof

BEGIN;

-- Create shipment table
CREATE TABLE "shipment" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "contractId" uuid NOT NULL,
  "driverId" uuid,
  
  -- Shipment Reference & Status
  "shipmentReference" varchar(100) NOT NULL UNIQUE,
  "status" varchar(50) NOT NULL DEFAULT 'PENDING',
  "transportMode" varchar(50) NOT NULL,
  "description" text,
  
  -- Vehicle & Driver Details
  "vehicleRegistration" varchar(255),
  "vehicleType" varchar(100),
  "driverLicenseNumber" varchar(100),
  "totalWeight" numeric(10, 2),
  "totalVolume" numeric(10, 2),
  
  -- Pickup Location
  "pickupLocationName" varchar(255) NOT NULL,
  "pickupLatitude" varchar(100),
  "pickupLongitude" varchar(100),
  "pickupDate" timestamp NOT NULL,
  "departureTime" timestamp,
  
  -- Delivery Location
  "deliveryLocationName" varchar(255) NOT NULL,
  "deliveryLatitude" varchar(100),
  "deliveryLongitude" varchar(100),
  "expectedDeliveryDate" timestamp NOT NULL,
  "actualDeliveryDate" timestamp,
  "arrivedDestinationTime" timestamp,
  
  -- Tracking & Insurance
  "trackingUrl" varchar(100),
  "insured" boolean DEFAULT false,
  "insuranceProvider" varchar(100),
  "policyNumber" varchar(100),
  "declaredValue" numeric(12, 2),
  
  -- Delivery Handling
  "recipientName" varchar(255),
  "recipientPhone" varchar(100),
  "recipientEmail" varchar(100),
  "specialHandlingInstructions" text,
  "requiresSignature" boolean DEFAULT true,
  "requiresPhotographicEvidence" boolean DEFAULT false,
  "deliveryFailureReason" varchar(1000),
  "deliveryAttemptCount" integer DEFAULT 0,
  
  -- Additional Metadata
  "additionalNotes" json,
  
  -- Timestamps
  "createdAt" timestamp DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" timestamp DEFAULT CURRENT_TIMESTAMP,
  
  -- Foreign Keys
  CONSTRAINT fk_shipment_contract FOREIGN KEY ("contractId") 
    REFERENCES "contract"("id") ON DELETE CASCADE,
  CONSTRAINT fk_shipment_driver FOREIGN KEY ("driverId") 
    REFERENCES "user"("id") ON DELETE SET NULL
);

-- Create indexes on shipment table
CREATE INDEX idx_shipment_status_contract ON "shipment"("status", "contractId");
CREATE INDEX idx_shipment_driver_status ON "shipment"("driverId", "status");
CREATE INDEX idx_shipment_pickup_date ON "shipment"("pickupDate");
CREATE INDEX idx_shipment_expected_delivery ON "shipment"("expectedDeliveryDate");
CREATE INDEX idx_shipment_contract ON "shipment"("contractId");
CREATE INDEX idx_shipment_status ON "shipment"("status");

-- Create trigger to update updatedAt
CREATE TRIGGER update_shipment_updatedAt BEFORE UPDATE ON "shipment"
  FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- Create shipment_tracking table for real-time GPS tracking
CREATE TABLE "shipment_tracking" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "shipmentId" uuid NOT NULL,
  
  -- Event Details
  "eventType" varchar(50) NOT NULL,
  "message" varchar(500) NOT NULL,
  
  -- Location Data (GPS)
  "latitude" varchar(100),
  "longitude" varchar(100),
  "locationName" varchar(255),
  "address" varchar(100),
  
  -- Metadata (Temperature, humidity, battery, signal, speed, etc.)
  "metadata" json,
  "notes" text,
  
  -- Timestamps
  "createdAt" timestamp DEFAULT CURRENT_TIMESTAMP,
  "eventTime" timestamp,
  
  -- Foreign Key
  CONSTRAINT fk_tracking_shipment FOREIGN KEY ("shipmentId")
    REFERENCES "shipment"("id") ON DELETE CASCADE
);

-- Create indexes on shipment_tracking
CREATE INDEX idx_tracking_shipment_created ON "shipment_tracking"("shipmentId", "createdAt");
CREATE INDEX idx_tracking_event_type ON "shipment_tracking"("eventType");
CREATE INDEX idx_tracking_location ON "shipment_tracking"("latitude", "longitude");

-- Create delivery_proof table
CREATE TABLE "delivery_proof" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "shipmentId" uuid NOT NULL,
  "capturedById" uuid NOT NULL,
  
  -- Proof Details
  "proofType" varchar(50) NOT NULL,
  "description" varchar(500) NOT NULL,
  
  -- Content Storage
  "dataBlobUrl" text,
  "signatureCanvas" json,
  "photoPath" varchar(255),
  "videoPath" varchar(255),
  
  -- Recipient Information
  "recipientName" varchar(255),
  "recipientIdType" varchar(100),
  "recipientIdNumber" varchar(100),
  "recipientPhone" varchar(100),
  
  -- Condition Assessment
  "conditionAssessment" json,
  
  -- Environmental Data (cold chain tracking)
  "environmentalData" json,
  
  -- Location
  "latitude" varchar(100),
  "longitude" varchar(100),
  
  -- Verification
  "notes" text,
  "isVerified" boolean DEFAULT false,
  "verifiedBy" varchar(255),
  "verifiedAt" timestamp,
  
  -- Timestamps
  "createdAt" timestamp DEFAULT CURRENT_TIMESTAMP,
  
  -- Foreign Keys
  CONSTRAINT fk_proof_shipment FOREIGN KEY ("shipmentId")
    REFERENCES "shipment"("id") ON DELETE CASCADE,
  CONSTRAINT fk_proof_captured_by FOREIGN KEY ("capturedById")
    REFERENCES "user"("id") ON DELETE RESTRICT
);

-- Create indexes on delivery_proof
CREATE INDEX idx_proof_shipment_type ON "delivery_proof"("shipmentId", "proofType");
CREATE INDEX idx_proof_captured_by ON "delivery_proof"("capturedById");
CREATE INDEX idx_proof_created ON "delivery_proof"("createdAt");

-- Create trigger to update shipment status when both signatures captured
CREATE OR REPLACE FUNCTION auto_activate_shipment_on_signature()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE "shipment"
  SET "status" = 'DELIVERED', "actualDeliveryDate" = CURRENT_TIMESTAMP
  WHERE "id" = NEW."shipmentId" 
    AND "status" = 'ARRIVED_DESTINATION'
    AND EXISTS (
      SELECT 1 FROM "delivery_proof"
      WHERE "shipmentId" = NEW."shipmentId" AND "proofType" = 'SIGNATURE'
    );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_signature_delivery AFTER INSERT ON "delivery_proof"
  FOR EACH ROW
  WHEN (NEW."proofType" = 'SIGNATURE')
  EXECUTE FUNCTION auto_activate_shipment_on_signature();

COMMIT;

-- Verification queries
-- Check tables created
SELECT tablename FROM pg_tables 
WHERE tablename IN ('shipment', 'shipment_tracking', 'delivery_proof');

-- Check indexes created
SELECT indexname FROM pg_indexes 
WHERE tablename IN ('shipment', 'shipment_tracking', 'delivery_proof');
