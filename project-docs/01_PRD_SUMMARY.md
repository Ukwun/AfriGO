# AfriGo Digital Trade Operating System - PRD Summary

## 🌍 EXECUTIVE OVERVIEW

**Project:** AfriGo - Pan-African Digital Trade Operating System  
**Status:** Development Phase 1 - MVP Launch  
**Complexity:** Enterprise-grade multi-sided marketplace  
**Timeline:** 14 weeks (Phase 1)  
**Target Users:** 50,000+ concurrent users across 54 African nations  

---

## 👥 MARKET SEGMENTS & USER ROLES

### 1. **Suppliers**
- Smallholder farmers
- Cooperatives
- Processors
- Primary activity: Create lots, submit QC reports, respond to RFQs

### 2. **Buyers**
- Global importers
- Retailers
- Wholesale merchants
- Primary activity: Post RFQs, evaluate bids, negotiate contracts

### 3. **Exporters**
- Trading houses
- Export brokers
- Primary activity: Manage export pipelines, compliance docs

### 4. **Logistics Providers**
- Freight forwarders
- Warehouse operators
- Primary activity: Track shipments, manage delivery

### 5. **Compliance Officers**
- Government regulators
- Zone authorities
- Primary activity: Verify KYC, approve documentation

### 6. **Zone Service Operators**
- Digital zones
- Border facilities
- Primary activity: Business licensing, FX management, visa processing

---

## 🏗️ SYSTEM COMPONENTS (10 CORE MODULES)

### **Module 1: Auth + KYC/KYB** (Trust Foundation)
- Multi-factor authentication (email, phone, OTP)
- Organization registration
- Document upload & verification
- Role assignment & RBAC
- Audit logging

### **Module 2: Role-Based Dashboard**
- Dynamic widgets per user role
- Real-time KPI updates
- Activity feeds
- Notifications hub
- Customizable layouts

### **Module 3: Lot Traceability** ⭐ **CORE ENGINE**
- **Batch creation** - Suppliers upload product specs, quantity, expected quality
- **Product taxonomy** - Standardized product codes
- **Status lifecycle** - Pending → QC → Approved → Exported → Received → Archived
- **Event timeline** - Every action triggers immutable event (CRITICAL)
- **Custody chain** - Track who held lot, when, signatures
- **Real-time broadcasts** - All stakeholders notified
- **Offline support** - Local caching, sync on reconnect
- **Animated timeline UI** - "Alive" animated progression

### **Module 4: Quality & Lab**
- Customizable inspection forms
- Image evidence collection
- Grade classification system (A, B, C, Rejected)
- Lab report integration
- Quality metrics dashboard

### **Module 5: Marketplace (RFQ → Bidding)**
- RFQ creation (supplier broadcast)
- Bid submission with quotes
- Bid comparison (side-by-side UI)
- Winner selection
- Auto-escalation to contract

### **Module 6: Contract System**
- Contract templates (buyer, supplier, neutral)
- Auto-generation from lot + pricing
- E-signature integration
- Amendment workflow
- Contract-to-lot linking

### **Module 7: Logistics**
- Shipment creation (lot → destination)
- Real-time GPS tracking
- Warehouse capacity management
- Driver mobile app (Phase 2)
- Event-driven status updates

### **Module 8: Payments (Escrow)** 🔑 **CRITICAL**
- Payment initiation with terms
- Escrow account management
- Release triggers (delivery confirmation)
- Dispute handling (arbitration)
- Integration: Flutterwave, Stripe, or local banks
- Immutable transaction ledger

### **Module 9: Export Documentation**
- Auto-generation: Phytosanitary, Certificate of Origin, Invoice, Packing List
- Country-specific compliance
- Dossier bundling
- Digital signatures
- Download & distribution

### **Module 10: Digital Zone Services**
- Service request workflow (business setup, FX, visa)
- Queue management (admin processing)
- Status tracking
- Govt API integration (Phase 2)

---

## 🗂️ DATA MODEL (HIGH-LEVEL)

### **Relational (PostgreSQL)**
```
Users
├── user_id (PK)
├── email, phone, auth_provider
├── organization_id (FK)
├── role (supplier, buyer, exporter, etc.)
└── kyc_status, kyc_documents

Organizations
├── org_id (PK)
├── org_name, tax_id, business_type
├── verification_status
├── service_tier

Lots
├── lot_id (PK)
├── supplier_id (FK)
├── product_id (FK)
├── quantity, quality_grade, batch_number
├── created_at, current_status
└── custody_chain_json

Lot_Events (Immutable audit log)
├── event_id (PK)
├── lot_id (FK)
├── actor_id (FK)
├── event_type (created, qc_passed, shipped, received, etc.)
├── action_data (JSON)
├── timestamp (ISO8601)
└── signature (for critical events)

RFQs
├── rfq_id (PK)
├── buyer_id (FK)
├── product_id (FK)
├── quantity_range, budget, deadline
├── broadcast_list

Bids
├── bid_id (PK)
├── rfq_id (FK)
├── supplier_id (FK)
├── quote_price, payment_terms, delivery_date

Contracts
├── contract_id (PK)
├── buyer_id (FK)
├── supplier_id (FK)
├── lot_id (FK)
├── contract_terms_json
├── signature_status (pending, signed, executed)
└── e_signature_records

Shipments
├── shipment_id (PK)
├── lot_id (FK)
├── logistics_id (FK)
├── origin, destination, mode (air, sea, road)
├── estimated_arrival, actual_arrival

Shipment_Events (Real-time tracking)
├── event_id (PK)
├── shipment_id (FK)
├── event_type (picked_up, in_transit, delivered)
├── gps_coords, timestamp

Payments
├── payment_id (PK)
├── contract_id (FK)
├── payer_id (FK), payee_id (FK)
├── amount, status (pending, escrowed, released)
├── escrow_release_conditions (JSON)
└── immutable transaction_log

Export_Docs
├── doc_id (PK)
├── lot_id (FK)
├── doc_type (phytosanitary, coo, invoice)
├── generated_at, file_url, signature_status
```

### **Real-Time (Firebase)**
```
/realtime/shipments/{shipment_id}/
  ├── current_location (GPS)
  ├── last_event (type, timestamp)
  ├── eta_timestamp

/realtime/lots/{lot_id}/
  ├── current_status
  ├── latest_event
  ├── watchers (users viewing this lot)

/realtime/contracts/{contract_id}/
  ├── signature_status
  ├── latest_amendment

/notifications/{user_id}/
  ├── unread_count
  ├── recent_notifications (array)
```

---

## ⚡ CRITICAL BUSINESS RULES

### **1. Lot Traceability (Trust Foundation)**
- Every lot change triggers immutable event
- Event timeline = single source of truth
- No deletions, only "archived" status
- All events signed (actor + timestamp)

### **2. Role-Based Access Control (RBAC)**
- No cross-role data visibility
- Suppliers see only their lots
- Buyers see only their RFQs/contracts
- Admin sees everything (with audit trail)

### **3. Idempotency (Payments Critical)**
- All payment requests must include `idempotency_key`
- Duplicate requests return cached response
- No double-charging, ever

### **4. Escrow Logic**
- Funds locked until delivery confirmed
- Buyer or dispute authority can release
- Timeout auto-release (default: 30 days)
- All releases logged immutably

### **5. Document Integrity**
- All documents linked to lot + contract
- E-signatures required for legal docs
- Version control (amendments tracked)
- Blockchain-ready (hash each version)

### **6. Real-Time Scope (Limited)**
Real-time NOW (WebSocket):
- Shipment location updates
- Payment status changes
- New bids received
- Contract signature updates

Batch/Polling (HTTP, every 5 min):
- Dashboard KPIs
- Lot catalog updates
- User profile changes
- Approval queues

---

## 🎯 PHASE 1 MILESTONES (14 weeks)

| Week | Sprint | Focus | Deliverable |
|------|--------|-------|---|
| 1-2 | 1-2 | Auth + KYC + Dashboard | Users can log in, verify identity, see role-based dashboard |
| 3-4 | 3 | Lot Traceability | Suppliers create lots, timeline is 100% functional |
| 5-6 | 4 | Quality + RFQ | QC forms, inspection workflow, RFQ broadcast |
| 7-8 | 5 | Contracts | Contract generation, e-signature, linking |
| 9-10 | 6A | Logistics | Shipment creation, tracking, GPS events |
| 11-12 | 6B | Payments | Payment flow, escrow, release logic |
| 13-14 | Integration | Testing + Hardening | Stress tests, security audit, bug fixes |

**MVP Cutoff:** End of Week 14
- Core lot-to-payment pipeline working
- 5 role-based dashboards live
- Complete audit trail
- Basic offline support
- Performance optimized

---

## 🚀 TECH STACK (FINAL)

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| **Frontend** | Flutter 3.x | Cross-platform (iOS, Android, Web) |
| **Auth** | Firebase Auth | Multi-factor, OTP integrated |
| **Real-time** | Firebase Realtime DB | Subscriptions, low latency |
| **Backend** | Node.js 20 + NestJS | Microservices-ready, TypeScript |
| **Database** | PostgreSQL 15 | ACID, relational integrity |
| **Object Storage** | AWS S3 or Firebase Storage | Document + image storage |
| **Payments** | Flutterwave/Stripe | African market coverage |
| **Notifications** | Firebase Cloud Messaging | Push + in-app |
| **Monitoring** | Sentry + DataDog | Error tracking, APM |
| **Infrastructure** | AWS or GCP | Cloud-native, auto-scaling |
| **CI/CD** | GitHub Actions | Automated deployments |

---

## 💰 BUSINESS MODEL (Documented but NOT Phase 1)

- **Marketplace Fee:** 2.5% on successful trades
- **Payment Processing:** 1.5% on escrow releases
- **Premium Services:** KYC acceleration, priority support
- **Zone Services:** Government licensing commission
- **API Access:** 3rd-party integrations (Phase 2+)

---

## 📊 SUCCESS METRICS (Phase 1)

| Metric | Target |
|--------|--------|
| App Stability | 99.9% uptime |
| Auth Success Rate | 99.5% |
| Lot Creation → Payment | < 5 min average |
| Timeline Load Time | < 300ms |
| Animation Frame Rate | 60 FPS |
| Error Rate | < 0.1% |
| User Retention (7-day) | > 70% |

---

## 🔐 SECURITY PRIORITIES

1. **End-to-end encryption** for sensitive docs
2. **Role-based access control** (RBAC) - no exceptions
3. **Audit logging** - every mutation tracked
4. **PCI-DSS compliance** (for payments)
5. **API rate limiting** - DDoS protection
6. **Data residency** - African data stays in Africa (GDPR/local law)

---

## 📱 UI/UX PHILOSOPHY

**"Alive" Does NOT Mean Fast**
- Responsive: Instant feedback to user actions
- Fluid: Smooth transitions, no janky animations
- Organic: Animations mimic real-world physics
- Alive: Timeline breaths, reacts to live events

**Design Principles:**
- Timeline UI everywhere (lots, shipments, payments)
- Status colors (yellow=pending, green=approved, red=error, blue=progress)
- Card-based layout (8pt grid, clean spacing)
- Micro-interactions (skeletons, success pulses, error states)

---

## 🎬 NEXT STEPS (IMMEDIATE)

1. ✅ Lock design system (colors, typography, buttons) - DONE
2. ✅ Create database schema - DOING NOW
3. ✅ Set up Flutter project structure - DOING NOW
4. ✅ Create API architecture docs - DOING NOW
5. ✅ Build animation system specification - DOING NOW
6. Initialize backend boilerplate
7. Initialize Firebase configuration
8. Create design tokens for Flutter
9. Begin Sprint 1 development

---

**Status:** 🟢 Ready for Execution  
**Last Updated:** April 12, 2026  
**Owner:** Development Team  

