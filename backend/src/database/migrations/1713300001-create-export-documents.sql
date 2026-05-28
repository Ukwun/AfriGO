-- Migration: Create Export Documents Table
-- Timestamp: 1713300001
-- Description: Creates table for storing export documentation records

CREATE TABLE IF NOT EXISTS export_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Document Identity
  document_number VARCHAR(50) UNIQUE NOT NULL,
  document_type VARCHAR(50) NOT NULL,
  status VARCHAR(50) NOT NULL DEFAULT 'DRAFT',
  version INT NOT NULL DEFAULT 1,
  
  -- Relationships
  shipment_id UUID NOT NULL,
  contract_id UUID NOT NULL,
  created_by UUID NOT NULL,
  
  -- Geographic Info
  origin_country VARCHAR(2) NOT NULL,
  destination_country VARCHAR(2) NOT NULL,
  
  -- Product Details
  product_description TEXT NOT NULL,
  total_value DECIMAL(15, 2) NOT NULL,
  currency VARCHAR(3) NOT NULL,
  
  -- Cloud Storage & Signatures
  cloud_url TEXT,
  signatures JSONB,
  
  -- Metadata & Compliance
  metadata JSONB,
  expiry_date TIMESTAMP,
  
  -- Timestamps
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  -- Indexes for common queries
  CONSTRAINT fk_export_docs_shipment FOREIGN KEY (shipment_id) REFERENCES shipments(id),
  CONSTRAINT fk_export_docs_contract FOREIGN KEY (contract_id) REFERENCES contracts(id),
  CONSTRAINT fk_export_docs_user FOREIGN KEY (created_by) REFERENCES users(id)
);

-- Create indexes for query performance
CREATE INDEX idx_export_docs_shipment ON export_documents(shipment_id);
CREATE INDEX idx_export_docs_contract ON export_documents(contract_id);
CREATE INDEX idx_export_docs_status ON export_documents(status);
CREATE INDEX idx_export_docs_type ON export_documents(document_type);
CREATE INDEX idx_export_docs_origin ON export_documents(origin_country);
CREATE INDEX idx_export_docs_destination ON export_documents(destination_country);
CREATE INDEX idx_export_docs_created ON export_documents(created_at);
CREATE INDEX idx_export_docs_created_by ON export_documents(created_by);
CREATE INDEX idx_export_docs_number ON export_documents(document_number);

-- Create index for document type + status (common filter combination)
CREATE INDEX idx_export_docs_type_status ON export_documents(document_type, status);

-- Create index for country pair (used for compliance checking)
CREATE INDEX idx_export_docs_countries ON export_documents(origin_country, destination_country);

-- Update trigger for updated_at timestamp
CREATE OR REPLACE FUNCTION update_export_documents_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER export_documents_updated_at_trigger
BEFORE UPDATE ON export_documents
FOR EACH ROW
EXECUTE FUNCTION update_export_documents_updated_at();
