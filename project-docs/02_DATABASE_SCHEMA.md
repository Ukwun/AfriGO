# AfriGo Database Schema - PostgreSQL + Firebase

> **Architecture:** PostgreSQL (ACID relational) + Firebase Realtime (subscriptions) + Cloud Storage (documents)

---

## 🗄️ POSTGRESQL SCHEMA (CORE BUSINESS DATA)

### **1. USERS & AUTHENTICATION**

```sql
-- Users table (core identity)
CREATE TABLE users (
  user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  phone_number VARCHAR(20) UNIQUE NOT NULL,
  auth_provider VARCHAR(50) NOT NULL, -- 'email', 'phone', 'google', 'apple'
  auth_provider_id VARCHAR(255) UNIQUE,
  
  -- Profile
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  profile_picture_url VARCHAR(500),
  
  -- Organization
  organization_id UUID NOT NULL REFERENCES organizations(org_id),
  user_role VARCHAR(50) NOT NULL, -- 'supplier', 'buyer', 'exporter', 'logistics', 'admin'
  
  -- KYC Status
  kyc_status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'submitted', 'verified', 'rejected'
  kyc_submitted_at TIMESTAMP,
  kyc_verified_at TIMESTAMP,
  kyc_verification_notes TEXT,
  
  -- Security & Activity
  is_active BOOLEAN DEFAULT true,
  last_login_at TIMESTAMP,
  last_activity_at TIMESTAMP,
  password_hash VARCHAR(255), -- if email auth
  two_fa_enabled BOOLEAN DEFAULT false,
  
  -- Metadata
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL -- Soft delete
);

-- User roles & permissions (RBAC)
CREATE TABLE roles (
  role_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  role_name VARCHAR(50) NOT NULL UNIQUE, -- 'supplier', 'buyer', 'admin'
  description TEXT,
  permissions JSONB, -- Array of permission strings
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_permissions (
  user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
  permission_id UUID,
  granted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, permission_id)
);

-- Audit logging (every login/permission change)
CREATE TABLE user_audit_log (
  audit_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(user_id),
  action VARCHAR(100), -- 'login', 'logout', 'permission_granted', 'kyc_submitted'
  action_details JSONB,
  ip_address VARCHAR(50),
  device_info VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_user_audit (user_id, created_at DESC)
);
```

### **2. ORGANIZATIONS**

```sql
CREATE TABLE organizations (
  org_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Basic Info
  org_name VARCHAR(255) NOT NULL,
  org_type VARCHAR(50) NOT NULL, -- 'farm', 'processor', 'exporter', 'buyer', 'logistics'
  description TEXT,
  logo_url VARCHAR(500),
  
  -- Legal
  tax_id VARCHAR(50) UNIQUE,
  business_registration_number VARCHAR(100),
  country_of_operation VARCHAR(100),
  city VARCHAR(100),
  address TEXT,
  
  -- Verification
  verification_status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'verified', 'suspended'
  verified_at TIMESTAMP,
  verification_notes TEXT,
  
  -- Service Tier
  service_tier VARCHAR(50) DEFAULT 'basic', -- 'basic', 'professional', 'enterprise'
  tier_expires_at TIMESTAMP,
  
  -- Contact
  primary_contact_email VARCHAR(255),
  primary_contact_phone VARCHAR(20),
  
  -- Metadata
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL,
  
  UNIQUE(tax_id)
);

-- Organization members (many-to-many)
CREATE TABLE org_members (
  org_id UUID REFERENCES organizations(org_id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
  role_in_org VARCHAR(50), -- 'admin', 'manager', 'staff'
  joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (org_id, user_id)
);
```

### **3. KYC DOCUMENTS**

```sql
CREATE TABLE kyc_documents (
  doc_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
  org_id UUID REFERENCES organizations(org_id) ON DELETE CASCADE,
  
  -- Document info
  document_type VARCHAR(100), -- 'passport', 'id_card', 'business_license', 'tax_cert'
  document_number VARCHAR(100),
  file_url VARCHAR(500), -- S3/Cloud Storage URL
  file_size_bytes BIGINT,
  
  -- Verification
  verification_status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'verified', 'rejected'
  verified_by UUID REFERENCES users(user_id),
  verified_at TIMESTAMP,
  rejection_reason TEXT,
  
  -- Metadata
  uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMP,
  is_primary BOOLEAN DEFAULT false,
  
  INDEX idx_user_docs (user_id),
  INDEX idx_org_docs (org_id),
  INDEX idx_verification_status (verification_status)
);
```

---

## 🎁 LOTS & TRACEABILITY (CORE ENGINE)

```sql
-- Products catalog (reference data)
CREATE TABLE products (
  product_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_code VARCHAR(50) UNIQUE NOT NULL, -- 'CACAO_2024', 'CASHEW_GRADE_A'
  product_name VARCHAR(255) NOT NULL,
  hs_code VARCHAR(10), -- Harmonized System code
  description TEXT,
  typical_unit_of_measure VARCHAR(50), -- 'kg', 'bags', 'tons'
  typical_packaging VARCHAR(100),
  shelf_life_days INT,
  optimal_storage_temp_celsius FLOAT,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- CORE: Lots (batches of products)
CREATE TABLE lots (
  lot_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lot_number VARCHAR(50) UNIQUE NOT NULL, -- 'LOT-202604-001'
  
  -- What
  supplier_id UUID NOT NULL REFERENCES users(user_id),
  product_id UUID NOT NULL REFERENCES products(product_id),
  quantity NUMERIC(15, 3) NOT NULL, -- 1000.500 kg
  unit_of_measure VARCHAR(50), -- 'kg', 'bags'
  
  -- Quality
  quality_grade VARCHAR(50), -- 'A', 'B', 'C', 'REJECTED'
  batch_number VARCHAR(100),
  harvest_date DATE,
  production_date DATE,
  
  -- Status & Lifecycle
  current_status VARCHAR(50) NOT NULL DEFAULT 'pending', -- 'pending', 'qc_pending', 'qc_approved', 'exported', 'received', 'archived'
  
  -- Custody & Location
  current_custodian_id UUID REFERENCES users(user_id),
  current_location_warehouse VARCHAR(255),
  current_location_gps POINT, -- PostGIS
  
  -- Key Dates
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  exported_at TIMESTAMP,
  received_at TIMESTAMP,
  archived_at TIMESTAMP,
  
  -- Metadata
  notes TEXT,
  metadata JSONB, -- Custom fields
  
  INDEX idx_supplier_lots (supplier_id, created_at DESC),
  INDEX idx_lot_status (current_status),
  INDEX idx_lot_number (lot_number),
  INDEX idx_product_lots (product_id)
);

-- IMMUTABLE: Lot events (single source of truth for timeline)
CREATE TABLE lot_events (
  event_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lot_id UUID NOT NULL REFERENCES lots(lot_id) ON DELETE CASCADE,
  
  -- Event metadata
  event_type VARCHAR(100) NOT NULL, -- 'created', 'qc_passed', 'qc_failed', 'shipped', 'received', 'rejected'
  event_sequence INT NOT NULL, -- Order within lot (for immutability)
  
  -- Who & When
  actor_id UUID NOT NULL REFERENCES users(user_id),
  timestamp_utc TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- What happened (detailed)
  action_data JSONB, -- { "grade": "A", "inspector": "...", "notes": "..." }
  
  -- Immutability & Audit
  event_hash VARCHAR(256), -- SHA256 of event data (blockchain-ready)
  is_signed BOOLEAN DEFAULT true,
  signer_id UUID REFERENCES users(user_id), -- Digital signature
  signature_timestamp TIMESTAMP,
  
  -- Location (optional)
  event_location_gps POINT,
  
  -- Cannot be updated or deleted
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_lot_events (lot_id, event_sequence),
  INDEX idx_event_type (event_type),
  INDEX idx_timestamp (timestamp_utc DESC),
  UNIQUE(lot_id, event_sequence)
);

-- Custody chain (for regulatory compliance)
CREATE TABLE custody_chain (
  custody_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lot_id UUID NOT NULL REFERENCES lots(lot_id) ON DELETE CASCADE,
  
  -- Transfer details
  from_user_id UUID REFERENCES users(user_id),
  to_user_id UUID NOT NULL REFERENCES users(user_id),
  
  transfer_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  transfer_gps POINT,
  transfer_notes TEXT,
  
  -- Verification
  witness_1_user_id UUID REFERENCES users(user_id),
  witness_2_user_id UUID REFERENCES users(user_id),
  
  -- Signatures (e-signature data)
  from_signature VARCHAR(500),
  to_signature VARCHAR(500),
  witness_signatures JSONB,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_lot_custody (lot_id, transfer_date)
);
```

### **4. QUALITY & LAB**

```sql
CREATE TABLE quality_inspections (
  inspection_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lot_id UUID NOT NULL REFERENCES lots(lot_id),
  
  -- Inspector info
  inspector_id UUID NOT NULL REFERENCES users(user_id),
  inspection_type VARCHAR(50), -- 'visual', 'lab', 'certified_lab'
  
  -- Grades & Results
  quality_grade VARCHAR(50), -- 'A', 'B', 'C', 'REJECTED'
  grade_justification TEXT,
  
  -- Form responses (normalized)
  inspection_form_id UUID, -- Reference to form template
  form_responses JSONB, -- { "color": "golden", "moisture": "12%", ... }
  
  -- Evidence
  image_urls VARCHAR(500)[], -- Array of S3 URLs
  
  -- Status
  is_approved BOOLEAN DEFAULT false,
  approval_notes TEXT,
  approved_by UUID REFERENCES users(user_id),
  approved_at TIMESTAMP,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  INDEX idx_lot_inspections (lot_id),
  INDEX idx_inspector (inspector_id)
);

CREATE TABLE lab_reports (
  report_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lot_id UUID NOT NULL REFERENCES lots(lot_id),
  inspection_id UUID REFERENCES quality_inspections(inspection_id),
  
  -- Lab info
  lab_name VARCHAR(255),
  lab_certification VARCHAR(100), -- 'ISO_17025', etc
  
  -- Report data
  test_type VARCHAR(100), -- 'moisture', 'pest', 'chemical_residue'
  test_results JSONB,
  report_file_url VARCHAR(500),
  
  -- Approval
  verified_at TIMESTAMP,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 📋 MARKETPLACE (RFQ & BIDDING)

```sql
CREATE TABLE rfqs (
  rfq_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  rfq_number VARCHAR(50) UNIQUE NOT NULL,
  
  -- Posted by
  buyer_id UUID NOT NULL REFERENCES users(user_id),
  
  -- What they want
  product_id UUID NOT NULL REFERENCES products(product_id),
  quantity_needed NUMERIC(15, 3) NOT NULL,
  unit_of_measure VARCHAR(50),
  quality_grade_required VARCHAR(50),
  
  -- Terms
  budget_min NUMERIC(15, 2),
  budget_max NUMERIC(15, 2),
  currency VARCHAR(3) DEFAULT 'USD',
  
  -- Timeline
  desired_delivery_date DATE,
  shipping_terms VARCHAR(50), -- 'FOB', 'CIF', 'DDP'
  
  -- Status
  status VARCHAR(50) DEFAULT 'open', -- 'open', 'closed', 'awarded'
  broadcast_regions VARCHAR(100)[], -- Countries/regions
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deadline_at TIMESTAMP,
  awarded_at TIMESTAMP,
  awarded_to_bid_id UUID,
  
  INDEX idx_buyer_rfqs (buyer_id),
  INDEX idx_rfq_status (status),
  INDEX idx_deadline (deadline_at)
);

CREATE TABLE bids (
  bid_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  rfq_id UUID NOT NULL REFERENCES rfqs(rfq_id) ON DELETE CASCADE,
  supplier_id UUID NOT NULL REFERENCES users(user_id),
  
  -- Bid details
  quote_price NUMERIC(15, 2) NOT NULL,
  price_per_unit NUMERIC(15, 2),
  payment_terms VARCHAR(100), -- '30% upfront, 70% on delivery'
  delivery_date DATE,
  
  -- Lot linkage (optional)
  lot_id UUID REFERENCES lots(lot_id),
  
  -- Status
  status VARCHAR(50) DEFAULT 'active', -- 'active', 'accepted', 'rejected'
  win_probability_score FLOAT, -- ML-based ranking (Phase 2)
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  accepted_at TIMESTAMP,
  
  INDEX idx_rfq_bids (rfq_id),
  INDEX idx_supplier_bids (supplier_id)
);
```

---

## 📄 CONTRACTS

```sql
CREATE TABLE contracts (
  contract_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  contract_number VARCHAR(50) UNIQUE NOT NULL,
  
  -- Parties
  buyer_id UUID NOT NULL REFERENCES users(user_id),
  supplier_id UUID NOT NULL REFERENCES users(user_id),
  
  -- Links
  rfq_id UUID REFERENCES rfqs(rfq_id),
  bid_id UUID REFERENCES bids(bid_id),
  lot_id UUID REFERENCES lots(lot_id),
  
  -- Terms
  contract_type VARCHAR(50), -- 'purchase', 'supply', 'logistics'
  contract_value NUMERIC(15, 2),
  currency VARCHAR(3) DEFAULT 'USD',
  payment_terms TEXT,
  delivery_terms TEXT,
  contract_terms_json JSONB, -- Full legal terms
  
  -- Document
  contract_document_url VARCHAR(500),
  contract_hash VARCHAR(256), -- SHA256 for integrity
  
  -- Signatures (e-signature)
  signature_status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'partially_signed', 'signed', 'executed'
  buyer_signature_status VARCHAR(50) DEFAULT 'pending',
  supplier_signature_status VARCHAR(50) DEFAULT 'pending',
  
  -- E-Signature records
  e_signature_records JSONB, -- Array of signature objects with timestamps
  
  -- Amendments
  amendment_count INT DEFAULT 0,
  latest_amendment_date TIMESTAMP,
  
  -- Status
  status VARCHAR(50) DEFAULT 'draft',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  signed_at TIMESTAMP,
  executed_at TIMESTAMP,
  completed_at TIMESTAMP,
  
  INDEX idx_buyer_contracts (buyer_id),
  INDEX idx_supplier_contracts (supplier_id),
  INDEX idx_contract_status (status)
);

CREATE TABLE contract_amendments (
  amendment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  contract_id UUID NOT NULL REFERENCES contracts(contract_id),
  
  amendment_number INT,
  proposed_by UUID REFERENCES users(user_id),
  proposed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  change_description TEXT,
  amended_terms_json JSONB,
  
  status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'accepted', 'rejected'
  accepted_by UUID REFERENCES users(user_id),
  accepted_at TIMESTAMP,
  
  PRIMARY KEY (amendment_id)
);
```

---

## 🚚 LOGISTICS & SHIPMENTS

```sql
CREATE TABLE shipments (
  shipment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shipment_number VARCHAR(50) UNIQUE NOT NULL,
  
  -- What
  lot_id UUID NOT NULL REFERENCES lots(lot_id),
  delivery_order_id VARCHAR(100), -- From contract
  
  -- Who
  logistics_provider_id UUID REFERENCES users(user_id),
  driver_id UUID REFERENCES users(user_id),
  
  -- Route
  origin_location VARCHAR(255),
  origin_gps POINT,
  destination_location VARCHAR(255),
  destination_gps POINT,
  
  shipping_mode VARCHAR(50), -- 'air', 'sea', 'road', 'rail'
  transport_vehicle_id VARCHAR(100), -- License plate, container number
  
  -- Timeline
  pickup_scheduled_date DATE,
  pickup_actual_date DATE,
  estimated_arrival_date DATE,
  actual_arrival_date DATE,
  
  -- Status
  current_status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'picked_up', 'in_transit', 'in_port', 'delivered', 'received'
  
  -- Metadata
  tracking_number VARCHAR(100),
  awb_number VARCHAR(100), -- Air waybill
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  INDEX idx_lot_shipments (lot_id),
  INDEX idx_shipment_status (current_status),
  INDEX idx_tracking (tracking_number)
);

CREATE TABLE shipment_events (
  event_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shipment_id UUID NOT NULL REFERENCES shipments(shipment_id) ON DELETE CASCADE,
  
  -- Event
  event_type VARCHAR(100), -- 'picked_up', 'departed', 'arrived_port', 'customs_cleared', 'delivered'
  event_location VARCHAR(255),
  event_location_gps POINT,
  event_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  -- Who reported
  reported_by UUID REFERENCES users(user_id),
  
  -- Evidence
  event_notes TEXT,
  evidence_photo_url VARCHAR(500),
  signature_url VARCHAR(500),
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  INDEX idx_shipment_events (shipment_id, event_timestamp DESC)
);

CREATE TABLE warehouse_bookings (
  booking_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lot_id UUID REFERENCES lots(lot_id),
  
  warehouse_id UUID, -- Reference to warehouse master
  warehouse_name VARCHAR(255),
  
  storage_type VARCHAR(50), -- 'regular', 'cold_storage', 'bonded'
  storage_duration_days INT,
  
  check_in_date DATE,
  check_out_date DATE,
  
  storage_cost NUMERIC(15, 2),
  
  status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'active', 'completed'
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 💰 PAYMENTS & ESCROW

```sql
CREATE TABLE payments (
  payment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  payment_number VARCHAR(50) UNIQUE NOT NULL,
  
  -- Link to contract
  contract_id UUID NOT NULL REFERENCES contracts(contract_id),
  
  -- Parties
  payer_id UUID NOT NULL REFERENCES users(user_id), -- Usually buyer
  payee_id UUID NOT NULL REFERENCES users(user_id), -- Usually supplier
  
  -- Amount
  amount NUMERIC(15, 2) NOT NULL,
  currency VARCHAR(3) DEFAULT 'USD',
  
  -- Idempotency (CRITICAL for payments)
  idempotency_key VARCHAR(255) UNIQUE NOT NULL,
  
  -- Payment method
  payment_method VARCHAR(50), -- 'flutterwave', 'stripe', 'bank_transfer'
  payment_provider_ref_id VARCHAR(255), -- External transaction ID
  
  -- Status
  status VARCHAR(50) NOT NULL DEFAULT 'pending', -- 'pending', 'processing', 'escrowed', 'released', 'failed', 'refunded'
  
  -- Escrow details
  is_escrow BOOLEAN DEFAULT true,
  escrow_account_id VARCHAR(255),
  escrow_release_condition VARCHAR(100), -- 'delivery_confirmed', 'date_based', 'manual'
  escrow_release_required_by TIMESTAMP,
  
  -- Release trigger
  release_triggered_by UUID REFERENCES users(user_id),
  release_triggered_at TIMESTAMP,
  released_at TIMESTAMP,
  
  -- Failure/Refund
  failure_reason TEXT,
  refund_reason TEXT,
  refunded_at TIMESTAMP,
  
  -- Immutable log
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_status_change_at TIMESTAMP,
  
  INDEX idx_contract_payments (contract_id),
  INDEX idx_payment_status (status),
  INDEX idx_idempotency (idempotency_key),
  UNIQUE(idempotency_key)
);

-- Immutable transaction ledger (audit trail)
CREATE TABLE payment_ledger (
  ledger_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  payment_id UUID NOT NULL REFERENCES payments(payment_id) ON DELETE CASCADE,
  
  transaction_type VARCHAR(50), -- 'debit', 'credit', 'hold', 'release'
  amount NUMERIC(15, 2),
  account_affected VARCHAR(100),
  
  timestamp_utc TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  recorded_by_system BOOLEAN DEFAULT true,
  
  INDEX idx_payment_ledger (payment_id)
);

-- Disputes (if payment issues)
CREATE TABLE payment_disputes (
  dispute_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  payment_id UUID NOT NULL REFERENCES payments(payment_id),
  
  initiated_by UUID NOT NULL REFERENCES users(user_id),
  dispute_reason VARCHAR(255),
  dispute_evidence_urls VARCHAR(500)[],
  
  status VARCHAR(50) DEFAULT 'open', -- 'open', 'investigating', 'resolved', 'escalated'
  
  resolution_notes TEXT,
  resolved_by UUID REFERENCES users(user_id),
  resolved_at TIMESTAMP,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 📄 EXPORT DOCUMENTATION

```sql
CREATE TABLE export_documents (
  doc_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  doc_number VARCHAR(50) UNIQUE NOT NULL,
  
  -- Link
  lot_id UUID NOT NULL REFERENCES lots(lot_id),
  contract_id UUID REFERENCES contracts(contract_id),
  shipment_id UUID REFERENCES shipments(shipment_id),
  
  -- Type & Destination
  document_type VARCHAR(100), -- 'phytosanitary', 'coo', 'invoice', 'packing_list'
  destination_country VARCHAR(100),
  
  -- Content
  document_content JSONB,
  document_file_url VARCHAR(500),
  document_hash VARCHAR(256), -- Integrity check
  
  -- Signatures
  generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  generated_by UUID NOT NULL REFERENCES users(user_id),
  signed_at TIMESTAMP,
  signed_by UUID REFERENCES users(user_id),
  signature_url VARCHAR(500),
  
  -- Status
  status VARCHAR(50) DEFAULT 'draft', -- 'draft', 'generated', 'signed', 'submitted', 'approved'
  
  INDEX idx_lot_docs (lot_id),
  INDEX idx_doc_type (document_type)
);

CREATE TABLE export_dossiers (
  dossier_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  dossier_number VARCHAR(50) UNIQUE NOT NULL,
  
  lot_id UUID NOT NULL REFERENCES lots(lot_id),
  contract_id UUID REFERENCES contracts(contract_id),
  
  -- Documents bundled
  document_ids UUID[] REFERENCES export_documents(doc_id),
  document_count INT,
  
  -- Dossier status
  is_complete BOOLEAN DEFAULT false,
  is_submitted BOOLEAN DEFAULT false,
  submitted_to_customs_at TIMESTAMP,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  completed_at TIMESTAMP
);
```

---

## 🏢 DIGITAL ZONE SERVICES

```sql
CREATE TABLE zone_service_requests (
  request_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  request_number VARCHAR(50) UNIQUE NOT NULL,
  
  -- Who
  requested_by UUID NOT NULL REFERENCES users(user_id),
  org_id UUID NOT NULL REFERENCES organizations(org_id),
  
  -- What service
  service_type VARCHAR(100), -- 'business_setup', 'fx_account', 'visa_processing'
  service_details JSONB,
  
  -- Documents required
  required_documents VARCHAR(255)[],
  submitted_documents UUID[] REFERENCES kyc_documents(doc_id),
  
  -- Status
  status VARCHAR(50) DEFAULT 'draft', -- 'draft', 'submitted', 'under_review', 'approved', 'rejected'
  
  -- Processing
  assigned_to UUID REFERENCES users(user_id), -- Zone officer
  assigned_at TIMESTAMP,
  processed_at TIMESTAMP,
  processing_notes TEXT,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  submitted_at TIMESTAMP,
  completed_at TIMESTAMP,
  
  INDEX idx_org_requests (org_id),
  INDEX idx_request_status (status)
);
```

---

## 🔥 FIREBASE REALTIME SCHEMA

```json
{
  "realtime": {
    "shipments": {
      "shipment_id_123": {
        "current_location": {
          "latitude": 6.5244,
          "longitude": 3.3792,
          "timestamp": 1712973600000
        },
        "last_event": {
          "type": "in_transit",
          "description": "Package in transit to Lagos",
          "timestamp": 1712973500000
        },
        "eta_minutes": 120,
        "last_update": 1712973600000
      }
    },
    
    "lots": {
      "lot_id_456": {
        "current_status": "qc_pending",
        "latest_event": {
          "type": "qc_submitted",
          "timestamp": 1712973400000
        },
        "watchers": ["user1", "user2"]
      }
    },
    
    "contracts": {
      "contract_id_789": {
        "signature_status": "buyer_pending",
        "latest_amendment": null,
        "last_update": 1712973300000
      }
    },
    
    "notifications": {
      "user_id_abc": {
        "unread_count": 3,
        "notifications": [
          {
            "id": "notif_1",
            "type": "bid_received",
            "title": "New bid on RFQ-2024-001",
            "timestamp": 1712973600000
          }
        ]
      }
    },
    
    "user_presence": {
      "user_id_def": {
        "status": "online",
        "current_view": "lots_list",
        "last_activity": 1712973650000
      }
    }
  }
}
```

---

## 📝 MIGRATION CHECKLIST

- [ ] Create all tables (users, orgs, kyc, lots, events, qa, contracts, shipments, payments, docs)
- [ ] Set up indexes (performance)
- [ ] Set up foreign key constraints
- [ ] Set up triggers for `updated_at` timestamps
- [ ] Configure row-level security (if using RLS)
- [ ] Create indexes on commonly filtered columns
- [ ] Set up Firebase Realtime sync functions
- [ ] Create S3 bucket policies (document storage)
- [ ] Set up database backups
- [ ] Create test data sets

---

## 🔒 SECURITY NOTES

- All timestamps in UTC (ISO 8601)
- Immutable tables (lot_events, payment_ledger, audit logs) - no updates/deletes
- Role-based access control at database level
- Sensitive fields (contract terms, payment data) encrypted at rest
- Audit logs on every write to critical tables
- Soft deletes for users/orgs (maintain data integrity)

