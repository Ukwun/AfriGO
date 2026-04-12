-- AfriGo Platform - Main Schema Migration
-- Creates all core tables for the digital trade platform

-- ============================================================================
-- 1. USERS & AUTHENTICATION
-- ============================================================================

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email VARCHAR(255) UNIQUE NOT NULL,
  phone_number VARCHAR(20) UNIQUE,
  password_hash VARCHAR(255),
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  kyc_status VARCHAR(50) DEFAULT 'unverified', -- unverified, pending, verified, rejected
  kyc_verified_at TIMESTAMP,
  kyc_document_url TEXT,
  kyc_rejection_reason TEXT,
  profile_image_url TEXT,
  bio TEXT,
  country VARCHAR(100),
  region VARCHAR(100),
  city VARCHAR(100),
  is_active BOOLEAN DEFAULT true,
  firebase_uid VARCHAR(255) UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP
);

CREATE TABLE user_roles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role VARCHAR(50) NOT NULL, -- buyer, seller, member, wholesale, axe, admin
  metadata JSONB, -- Additional role-specific data
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_verification_tokens (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token VARCHAR(255) UNIQUE NOT NULL,
  type VARCHAR(50) NOT NULL, -- email, phone, password_reset
  expires_at TIMESTAMP NOT NULL,
  used_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 2. LOTS (Core Event Entity)
-- ============================================================================

CREATE TABLE lots (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  lot_number VARCHAR(50) UNIQUE NOT NULL,
  seller_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  commodity_type VARCHAR(100) NOT NULL, -- cocoa, cashew, shea, etc.
  origin_country VARCHAR(100) NOT NULL,
  origin_region VARCHAR(100),
  quantity_tonnes DECIMAL(10, 2) NOT NULL,
  unit_price_usd DECIMAL(12, 2) NOT NULL,
  total_value_usd DECIMAL(15, 2) GENERATED ALWAYS AS (quantity_tonnes * unit_price_usd) STORED,
  quality_grade VARCHAR(10), -- AA, A, B, C, etc.
  quality_score DECIMAL(3, 1), -- 1.0-5.0
  description TEXT,
  destination_country VARCHAR(100),
  destination_region VARCHAR(100),
  estimated_delivery_date DATE,
  status VARCHAR(50) DEFAULT 'published', -- published, reviewing, contract_stage, shipped, completed, cancelled
  visibility VARCHAR(50) DEFAULT 'public', -- public, private (for specific buyers)
  created_by_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  published_at TIMESTAMP,
  completed_at TIMESTAMP,
  cancelled_at TIMESTAMP,
  cancellation_reason TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP
);

CREATE INDEX idx_lots_seller_id ON lots(seller_id);
CREATE INDEX idx_lots_status ON lots(status);
CREATE INDEX idx_lots_commodity_type ON lots(commodity_type);
CREATE INDEX idx_lots_created_at ON lots(created_at DESC);

-- ============================================================================
-- 3. LOT EVENTS (Immutable Audit Trail)
-- ============================================================================

CREATE TABLE lot_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  lot_id UUID NOT NULL REFERENCES lots(id) ON DELETE CASCADE,
  event_type VARCHAR(50) NOT NULL, -- created, published, updated, rfq_received, bid_received, contract_signed, shipped, etc.
  actor_id UUID REFERENCES users(id) ON DELETE SET NULL,
  metadata JSONB, -- Payload of the event
  old_values JSONB, -- Previous state (for update events)
  new_values JSONB, -- New state (for update events)
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_lot_events_lot_id ON lot_events(lot_id);
CREATE INDEX idx_lot_events_event_type ON lot_events(event_type);
CREATE INDEX idx_lot_events_created_at ON lot_events(created_at DESC);

-- ============================================================================
-- 4. MARKETPLACE & RFQs
-- ============================================================================

CREATE TABLE rfqs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  rfq_number VARCHAR(50) UNIQUE NOT NULL,
  buyer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  commodity_type VARCHAR(100) NOT NULL,
  quantity_tonnes_min DECIMAL(10, 2) NOT NULL,
  quantity_tonnes_max DECIMAL(10, 2),
  price_range_usd_min DECIMAL(12, 2),
  price_range_usd_max DECIMAL(12, 2),
  origin_country VARCHAR(100),
  destination_country VARCHAR(100),
  delivery_deadline DATE,
  required_quality_grade VARCHAR(10),
  description TEXT,
  status VARCHAR(50) DEFAULT 'open', -- open, receiving_bids, closed, expired
  expires_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE bids (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  bid_number VARCHAR(50) UNIQUE NOT NULL,
  rfq_id UUID NOT NULL REFERENCES rfqs(id) ON DELETE CASCADE,
  lot_id UUID REFERENCES lots(id) ON DELETE SET NULL,
  seller_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  quantity_tonnes DECIMAL(10, 2) NOT NULL,
  price_per_tonne_usd DECIMAL(12, 2) NOT NULL,
  total_value_usd DECIMAL(15, 2) GENERATED ALWAYS AS (quantity_tonnes * price_per_tonne_usd) STORED,
  delivery_timeline TEXT,
  payment_terms TEXT,
  status VARCHAR(50) DEFAULT 'submitted', -- submitted, accepted, rejected, negotiating
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_bids_rfq_id ON bids(rfq_id);
CREATE INDEX idx_bids_seller_id ON bids(seller_id);
CREATE INDEX idx_bids_lot_id ON bids(lot_id);

-- ============================================================================
-- 5. CONTRACTS & E-SIGNATURES
-- ============================================================================

CREATE TABLE contracts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  contract_number VARCHAR(50) UNIQUE NOT NULL,
  lot_id UUID NOT NULL REFERENCES lots(id) ON DELETE RESTRICT,
  seller_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  buyer_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  rfq_id UUID REFERENCES rfqs(id) ON DELETE SET NULL,
  bid_id UUID REFERENCES bids(id) ON DELETE SET NULL,
  contract_type VARCHAR(50), -- standard, custom
  contract_template_id UUID,
  quantity_tonnes DECIMAL(10, 2) NOT NULL,
  unit_price_usd DECIMAL(12, 2) NOT NULL,
  total_value_usd DECIMAL(15, 2) GENERATED ALWAYS AS (quantity_tonnes * unit_price_usd) STORED,
  payment_terms JSONB, -- {method, deadline, percentage}
  delivery_terms JSONB, -- {location, deadline, incoterm}
  quality_requirements TEXT,
  document_s3_url TEXT,
  document_hash VARCHAR(255), -- SHA-256 for integrity
  status VARCHAR(50) DEFAULT 'draft', -- draft, pending_signatures, signed, executed, completed, disputed, cancelled
  seller_signed_at TIMESTAMP,
  buyer_signed_at TIMESTAMP,
  both_signed_at TIMESTAMP,
  execution_date TIMESTAMP,
  completion_date TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE contract_signatures (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  contract_id UUID NOT NULL REFERENCES contracts(id) ON DELETE CASCADE,
  signer_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  signature_type VARCHAR(50), -- electronic, biometric
  signed_at TIMESTAMP NOT NULL,
  ip_address INET,
  device_info TEXT,
  signature_hash VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_contracts_seller_id ON contracts(seller_id);
CREATE INDEX idx_contracts_buyer_id ON contracts(buyer_id);
CREATE INDEX idx_contracts_status ON contracts(status);
CREATE INDEX idx_contract_signatures_contract_id ON contract_signatures(contract_id);

-- ============================================================================
-- 6. PAYMENTS & ESCROW
-- ============================================================================

CREATE TABLE payment_ledger (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  contract_id UUID NOT NULL REFERENCES contracts(id) ON DELETE RESTRICT,
  payment_type VARCHAR(50) NOT NULL, -- escrow_deposit, partial_payment, final_payment, refund
  payer_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  payee_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  amount_usd DECIMAL(15, 2) NOT NULL,
  currency VARCHAR(3) DEFAULT 'USD',
  status VARCHAR(50) DEFAULT 'pending', -- pending, processing, completed, failed, reversed
  flutterwave_transaction_ref VARCHAR(255),
  idempotency_key VARCHAR(255) UNIQUE NOT NULL,
  description TEXT,
  metadata JSONB,
  initiated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  completed_at TIMESTAMP,
  failed_reason TEXT
);

CREATE TABLE escrow_accounts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  contract_id UUID NOT NULL UNIQUE REFERENCES contracts(id) ON DELETE CASCADE,
  status VARCHAR(50) DEFAULT 'active', -- active, released, disputed, refunded
  total_amount_usd DECIMAL(15, 2) NOT NULL,
  released_amount_usd DECIMAL(15, 2) DEFAULT 0,
  hold_reason TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  released_at TIMESTAMP
);

CREATE INDEX idx_payment_ledger_contract_id ON payment_ledger(contract_id);
CREATE INDEX idx_payment_ledger_idempotency_key ON payment_ledger(idempotency_key);
CREATE INDEX idx_payment_ledger_status ON payment_ledger(status);

-- ============================================================================
-- 7. LOGISTICS & SHIPMENTS
-- ============================================================================

CREATE TABLE shipments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  shipment_number VARCHAR(50) UNIQUE NOT NULL,
  contract_id UUID NOT NULL REFERENCES contracts(id) ON DELETE RESTRICT,
  lot_id UUID NOT NULL REFERENCES lots(id) ON DELETE RESTRICT,
  seller_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  buyer_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  origin_location JSONB, -- {country, region, latitude, longitude, port}
  destination_location JSONB,
  departure_date TIMESTAMP,
  estimated_arrival_date TIMESTAMP,
  actual_arrival_date TIMESTAMP,
  status VARCHAR(50) DEFAULT 'pending', -- pending, in_transit, customs_clearance, delivered, lost, damaged
  tracking_number VARCHAR(100),
  carrier_name VARCHAR(100),
  carrier_contact TEXT,
  shipping_method VARCHAR(50), -- sea, air, land, rail
  container_numbers TEXT[], -- array of container IDs
  seal_numbers TEXT[],
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE shipment_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  shipment_id UUID NOT NULL REFERENCES shipments(id) ON DELETE CASCADE,
  event_type VARCHAR(50) NOT NULL, -- departed, in_transit, customs_inspection, delivered, etc.
  location JSONB, -- {port, region, country, lat, lng}
  event_timestamp TIMESTAMP NOT NULL,
  notes TEXT,
  photographic_evidence_url TEXT,
  recorded_by_id UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_shipments_contract_id ON shipments(contract_id);
CREATE INDEX idx_shipments_status ON shipments(status);
CREATE INDEX idx_shipment_events_shipment_id ON shipment_events(shipment_id);

-- ============================================================================
-- 8. DOCUMENTS & DOSSIERS
-- ============================================================================

CREATE TABLE documents (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  document_number VARCHAR(50) UNIQUE NOT NULL,
  lot_id UUID REFERENCES lots(id) ON DELETE SET NULL,
  contract_id UUID REFERENCES contracts(id) ON DELETE SET NULL,
  shipper_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  document_type VARCHAR(50) NOT NULL, -- bill_of_lading, commercial_invoice, packing_list, quality_cert, weight_cert, phytosanitary, insurance
  issued_date DATE,
  issued_by VARCHAR(100),
  s3_url TEXT NOT NULL,
  s3_key VARCHAR(255),
  file_hash VARCHAR(255),
  file_size_bytes BIGINT,
  is_verified BOOLEAN DEFAULT false,
  verified_by_id UUID REFERENCES users(id) ON DELETE SET NULL,
  verified_at TIMESTAMP,
  expiry_date DATE,
  metadata JSONB,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE dossiers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  dossier_number VARCHAR(50) UNIQUE NOT NULL,
  contract_id UUID NOT NULL REFERENCES contracts(id) ON DELETE RESTRICT,
  status VARCHAR(50) DEFAULT 'open', -- open, submitted, approved, rejected
  created_by_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  submitted_at TIMESTAMP,
  approved_at TIMESTAMP,
  approved_by_id UUID REFERENCES users(id) ON DELETE SET NULL,
  rejection_reason TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE dossier_documents (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  dossier_id UUID NOT NULL REFERENCES dossiers(id) ON DELETE CASCADE,
  document_id UUID NOT NULL REFERENCES documents(id) ON DELETE RESTRICT,
  sequence_number INT,
  UNIQUE(dossier_id, document_id)
);

CREATE INDEX idx_documents_lot_id ON documents(lot_id);
CREATE INDEX idx_documents_contract_id ON documents(contract_id);
CREATE INDEX idx_dossiers_contract_id ON dossiers(contract_id);

-- ============================================================================
-- 9. ZONE SERVICES (Business Setup, Compliance)
-- ============================================================================

CREATE TABLE zone_registrations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  registration_number VARCHAR(50) UNIQUE NOT NULL,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  country VARCHAR(100) NOT NULL,
  business_name VARCHAR(255) NOT NULL,
  business_type VARCHAR(100), -- sole_proprietor, partnership, company, cooperative
  registration_cert_url TEXT,
  registration_cert_verified BOOLEAN DEFAULT false,
  tax_id VARCHAR(50),
  bank_account_verified BOOLEAN DEFAULT false,
  status VARCHAR(50) DEFAULT 'pending', -- pending, approved, rejected, active, suspended
  approved_at TIMESTAMP,
  approved_by_id UUID REFERENCES users(id) ON DELETE SET NULL,
  rejection_reason TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE forex_rates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  source_currency VARCHAR(3) NOT NULL, -- USD, EUR, GBP, etc.
  target_currency VARCHAR(3) NOT NULL,
  rate DECIMAL(18, 6) NOT NULL,
  source VARCHAR(50), -- openexchangerates, fixer, etc.
  effective_date TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_forex_rates_currencies ON forex_rates(source_currency, target_currency);
CREATE INDEX idx_forex_rates_effective_date ON forex_rates(effective_date DESC);

-- ============================================================================
-- 10. QUALITY & COMPLIANCE
-- ============================================================================

CREATE TABLE quality_inspections (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  inspection_number VARCHAR(50) UNIQUE NOT NULL,
  lot_id UUID NOT NULL REFERENCES lots(id) ON DELETE RESTRICT,
  inspector_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  inspection_date TIMESTAMP NOT NULL,
  quality_grade VARCHAR(10),
  quality_score DECIMAL(3, 1),
  moisture_content DECIMAL(5, 2),
  foreign_matter_percentage DECIMAL(5, 2),
  defect_count INT,
  notes TEXT,
  photographic_evidence_url TEXT,
  report_s3_url TEXT,
  status VARCHAR(50) DEFAULT 'submitted', -- submitted, approved, rejected
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE compliance_checks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  check_number VARCHAR(50) UNIQUE NOT NULL,
  contract_id UUID NOT NULL REFERENCES contracts(id) ON DELETE RESTRICT,
  check_type VARCHAR(50) NOT NULL, -- sanitary, phytosanitary, customs, quality, financial
  status VARCHAR(50) DEFAULT 'pending', -- pending, approved, rejected, flagged
  checked_by_id UUID REFERENCES users(id) ON DELETE SET NULL,
  findings TEXT,
  approval_notes TEXT,
  checked_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_quality_inspections_lot_id ON quality_inspections(lot_id);
CREATE INDEX idx_compliance_checks_contract_id ON compliance_checks(contract_id);

-- ============================================================================
-- 11. NOTIFICATIONS & ACTIVITY
-- ============================================================================

CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  notification_type VARCHAR(100) NOT NULL,
  title TEXT NOT NULL,
  message TEXT,
  related_entity_type VARCHAR(50),
  related_entity_id UUID,
  is_read BOOLEAN DEFAULT false,
  read_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMP
);

CREATE TABLE activity_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  action VARCHAR(50) NOT NULL,
  entity_type VARCHAR(50),
  entity_id UUID,
  changes JSONB,
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_activity_logs_user_id ON activity_logs(user_id);
CREATE INDEX idx_activity_logs_created_at ON activity_logs(created_at DESC);

-- ============================================================================
-- 12. CHAT & MESSAGING
-- ============================================================================

CREATE TABLE conversations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  initiator_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  responder_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  related_entity_type VARCHAR(50),
  related_entity_id UUID,
  status VARCHAR(50) DEFAULT 'active', -- active, archived, blocked
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(initiator_id, responder_id)
);

CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  content TEXT NOT NULL,
  attachment_url TEXT,
  is_read BOOLEAN DEFAULT false,
  read_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_conversations_initiator_id ON conversations(initiator_id);
CREATE INDEX idx_conversations_responder_id ON conversations(responder_id);
CREATE INDEX idx_messages_conversation_id ON messages(conversation_id);
CREATE INDEX idx_messages_created_at ON messages(created_at DESC);

-- ============================================================================
-- 13. RATINGS & REVIEWS
-- ============================================================================

CREATE TABLE ratings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  seller_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  reviewer_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  contract_id UUID REFERENCES contracts(id) ON DELETE SET NULL,
  rating DECIMAL(2, 1) NOT NULL,
  comment TEXT,
  aspects JSONB, -- {quality: 5, communication: 4, reliability: 5}
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_ratings_seller_id ON ratings(seller_id);
CREATE INDEX idx_ratings_reviewer_id ON ratings(reviewer_id);

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================

-- Full-text search indexes
CREATE INDEX idx_lots_commodity_trgm ON lots USING GIST(commodity_type gist_trgm_ops);
CREATE INDEX idx_rfqs_commodity_trgm ON rfqs USING GIST(commodity_type gist_trgm_ops);

-- Composite indexes for common queries
CREATE INDEX idx_lots_status_created ON lots(status, created_at DESC);
CREATE INDEX idx_contracts_status_updated ON contracts(status, updated_at DESC);
CREATE INDEX idx_payment_ledger_status_created ON payment_ledger(status, created_at DESC);

-- Create some views for common queries
CREATE VIEW active_lots AS
SELECT * FROM lots
WHERE status = 'published' AND deleted_at IS NULL
AND estimated_delivery_date > CURRENT_DATE;

CREATE VIEW seller_statistics AS
SELECT
  s.id as seller_id,
  COUNT(DISTINCT l.id) as total_lots,
  COUNT(DISTINCT c.id) as completed_contracts,
  AVG(r.rating) as average_rating,
  COUNT(DISTINCT b.id) as total_bids
FROM users s
LEFT JOIN lots l ON s.id = l.seller_id
LEFT JOIN contracts c ON s.id = c.seller_id AND c.status = 'completed'
LEFT JOIN ratings r ON s.id = r.seller_id
LEFT JOIN bids b ON s.id = b.seller_id
WHERE s.deleted_at IS NULL
GROUP BY s.id;

-- ============================================================================
-- Final Statement
-- ============================================================================

GRANT USAGE, CREATE ON SCHEMA public TO afrigo_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO afrigo_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO afrigo_app;
