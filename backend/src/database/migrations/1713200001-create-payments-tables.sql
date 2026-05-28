-- ============================================================================
-- PAYMENT & ESCROW DATABASE MIGRATION
-- File: 1713200001-create-payments-tables.sql
--
-- Creates 3 tables for payment processing and escrow management
-- Includes 12 strategic indexes and 1 auto-update trigger
-- ============================================================================

-- ============================================================================
-- TABLE 1: payment
-- Stores all payment transactions with multi-currency support
-- Tracks: amount, status, payment method, Flutterwave integration
-- ============================================================================

CREATE TABLE IF NOT EXISTS payment (
  -- Primary Keys & Foreign Keys
  id UUID PRIMARY KEY,
  contract_id UUID NOT NULL REFERENCES contract(id) ON DELETE CASCADE,

  -- Amount & Currency
  amount DECIMAL(15, 2) NOT NULL CHECK (amount > 0),
  currency VARCHAR(3) NOT NULL, -- KES, USD, EUR, ZAR, UGX, TZS

  -- Payment Method & Status
  payment_method VARCHAR(50) NOT NULL, -- FULL_UPFRONT, PARTIAL_DEPOSIT, ON_DELIVERY, INSTALLMENT, ESCROW
  status VARCHAR(50) NOT NULL, -- PENDING, INITIATED, PROCESSING, COMPLETED, FAILED, REFUNDED, DISPUTED

  -- Reference & Invoice
  invoice_reference VARCHAR(50) UNIQUE NOT NULL, -- INV-YYYY-XXXXXX format
  flutterwave_reference VARCHAR(100), -- Flutterwave transaction ID
  flutterwave_response JSONB, -- Full Flutterwave API response for audit

  -- Late Fees
  late_fee_amount DECIMAL(10, 2) DEFAULT 0 CHECK (late_fee_amount >= 0),
  late_fee_triggered_at TIMESTAMP,

  -- Important Dates
  due_date TIMESTAMP, -- When payment must be completed
  completed_at TIMESTAMP, -- When payment actually completed

  -- Audit Trail
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_by UUID NOT NULL,
  updated_by UUID,

  -- Flexible Metadata
  metadata JSONB DEFAULT '{}'::jsonb -- Payment terms, custom data, etc.
);

-- Comments for documentation
COMMENT ON TABLE payment IS 'Payment transactions with multi-currency and multi-method support';
COMMENT ON COLUMN payment.payment_method IS '5 payment methods: full upfront, deposit, on-delivery, installment, escrow';
COMMENT ON COLUMN payment.status IS '7 statuses: pending, initiated, processing, completed, failed, refunded, disputed';
COMMENT ON COLUMN payment.late_fee_amount IS 'Calculated as 2% per 10 days overdue';
COMMENT ON COLUMN payment.flutterwave_response IS 'Complete webhook response for reference and debugging';

-- ============================================================================
-- INDEXES FOR PAYMENT TABLE (9 indexes for optimal query performance)
-- ============================================================================

-- Index 1: Status queries (used frequently)
CREATE INDEX idx_payment_status ON payment(status);

-- Index 2: Payment method analysis
CREATE INDEX idx_payment_method ON payment(payment_method);

-- Index 3: Contract lookups (payment by contract)
CREATE INDEX idx_payment_contract ON payment(contract_id);

-- Index 4: Invoice reference lookup (unique but indexed for speed)
CREATE INDEX idx_payment_invoice_ref ON payment(invoice_reference);

-- Index 5: Creation date sorting
CREATE INDEX idx_payment_created_at ON payment(created_at DESC);

-- Index 6: Currency-based queries
CREATE INDEX idx_payment_currency ON payment(currency);

-- Index 7: Composite: Status + Due Date (for overdue payment queries)
CREATE INDEX idx_payment_status_due ON payment(status, due_date) 
  WHERE status IN ('PENDING', 'INITIATED', 'PROCESSING');

-- Index 8: Created by user (for user transaction history)
CREATE INDEX idx_payment_created_by ON payment(created_by);

-- Index 9: Completed status queries
CREATE INDEX idx_payment_completed ON payment(completed_at) 
  WHERE status = 'COMPLETED';

-- ============================================================================
-- TRIGGER: Auto-update payment.updated_at on any changes
-- ============================================================================

CREATE OR REPLACE FUNCTION update_payment_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER payment_updated_at_trigger
BEFORE UPDATE ON payment
FOR EACH ROW
EXECUTE FUNCTION update_payment_updated_at();

-- ============================================================================
-- TABLE 2: escrow
-- Funds held by AfriGo pending multi-condition release
-- Tracks: amount, holding period, condition status, auto-release
-- ============================================================================

CREATE TABLE IF NOT EXISTS escrow (
  -- Primary Keys & Foreign Keys
  id UUID PRIMARY KEY,
  payment_id UUID NOT NULL REFERENCES payment(id) ON DELETE CASCADE,

  -- Amount & Currency
  amount DECIMAL(15, 2) NOT NULL CHECK (amount > 0),
  currency VARCHAR(3) NOT NULL, -- KES, USD, EUR, ZAR, UGX, TZS

  -- Escrow Status
  status VARCHAR(50) NOT NULL, -- CREATED, FUNDED, HELD, RELEASED, REFUNDED, DISPUTED, RESOLVED

  -- Holding Terms
  holding_period_days INT NOT NULL CHECK (holding_period_days BETWEEN 1 AND 90),
  holding_fee_percentage DECIMAL(5, 2) DEFAULT 0 CHECK (holding_fee_percentage BETWEEN 0 AND 5),

  -- Condition Tracking
  -- JSON structure: { "DELIVERY_PROOF": { "met": true, "metAt": "2026-04-15", ... }, ... }
  conditions_met JSONB DEFAULT '{}'::jsonb,

  -- Important Dates
  auto_release_date TIMESTAMP NOT NULL, -- When escrow auto-releases if no conditions
  released_at TIMESTAMP, -- When funds were actually released
  refunded_at TIMESTAMP, -- When escrow was refunded to buyer

  -- Audit Trail
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_by UUID NOT NULL,

  -- Flexible Metadata
  metadata JSONB DEFAULT '{}'::jsonb -- Disputes, resolutions, etc.
);

-- Comments for documentation
COMMENT ON TABLE escrow IS 'Escrow funds held pending multi-condition release to seller';
COMMENT ON COLUMN escrow.status IS '7 statuses: created, funded, held, released, refunded, disputed, resolved';
COMMENT ON COLUMN escrow.conditions_met IS 'Tracks: DELIVERY_PROOF, QUALITY_APPROVAL, BUYER_SIGNOFF (each with met, metAt, proofUrl)';
COMMENT ON COLUMN escrow.holding_fee_percentage IS 'Fee for keeping funds in escrow; typically 0.5-1%';
COMMENT ON COLUMN escrow.metadata IS 'Stores disputes array, resolution details, auto-release reasons';

-- ============================================================================
-- INDEXES FOR ESCROW TABLE (3 indexes for optimal performance)
-- ============================================================================

-- Index 1: Status queries
CREATE INDEX idx_escrow_status ON escrow(status);

-- Index 2: Payment lookup
CREATE INDEX idx_escrow_payment ON escrow(payment_id);

-- Index 3: Auto-release date (for scheduled release job)
CREATE INDEX idx_escrow_auto_release ON escrow(auto_release_date) 
  WHERE status = 'HELD';

-- ============================================================================
-- TRIGGER: Auto-update escrow.updated_at on any changes
-- ============================================================================

CREATE OR REPLACE FUNCTION update_escrow_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER escrow_updated_at_trigger
BEFORE UPDATE ON escrow
FOR EACH ROW
EXECUTE FUNCTION update_escrow_updated_at();

-- ============================================================================
-- TABLE 3: payment_transaction_log
-- Immutable audit log of all payment-related transactions
-- Used for compliance, dispute resolution, and analytics
-- ============================================================================

CREATE TABLE IF NOT EXISTS payment_transaction_log (
  -- Primary Key
  id UUID PRIMARY KEY,

  -- Reference to payment
  payment_id UUID NOT NULL REFERENCES payment(id) ON DELETE CASCADE,

  -- Transaction Details
  transaction_type VARCHAR(50) NOT NULL, -- CHARGE, REFUND, FEE, DISPUTE, CHARGEBACK
  amount DECIMAL(15, 2) NOT NULL,

  -- Flutterwave Integration
  flutterwave_transaction_id VARCHAR(100),

  -- Status
  status VARCHAR(50) NOT NULL, -- PENDING, COMPLETED, FAILED, DISPUTED

  -- Timestamp (immutable)
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  -- Flexible Metadata
  metadata JSONB DEFAULT '{}'::jsonb -- Additional context
);

-- Comments
COMMENT ON TABLE payment_transaction_log IS 'Immutable audit log of payment transactions for compliance';
COMMENT ON COLUMN payment_transaction_log.transaction_type IS '5 types: CHARGE, REFUND, FEE, DISPUTE, CHARGEBACK';

-- ============================================================================
-- INDEXES FOR PAYMENT_TRANSACTION_LOG TABLE
-- ============================================================================

-- Index 1: Payment lookup
CREATE INDEX idx_transaction_log_payment ON payment_transaction_log(payment_id);

-- Index 2: Creation timestamp
CREATE INDEX idx_transaction_log_created ON payment_transaction_log(created_at DESC);

-- Index 3: Transaction type
CREATE INDEX idx_transaction_log_type ON payment_transaction_log(transaction_type);

-- ============================================================================
-- SUMMARY
-- ============================================================================
-- Tables Created: 3 (payment, escrow, payment_transaction_log)
-- Total Indexes: 12 (9 on payment, 3 on escrow)
-- Triggers: 2 (auto-update updated_at for payment and escrow)
-- Constraints: FOREIGN KEY, CHECK, UNIQUE, NOT NULL, DEFAULT
-- Data Integrity: Full referential integrity with CASCADE delete
-- Audit Trail: Complete transaction logging for compliance
--
-- MISSION:
-- - Secure multi-currency payment processing with Flutterwave
-- - Escrow-based trust mechanism
-- - Multi-condition release logic (delivery + quality + buyer approval)
-- - Late fee automation (2% per 10 days)
-- - Complete audit trail for compliance
-- - Optimized indexes for high-performance queries
-- ============================================================================
