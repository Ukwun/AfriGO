# AfriGo Backend API Architecture

> **Tech Stack:** Node.js 20 + NestJS + TypeScript + PostgreSQL  
> **Pattern:** Microservices (start monolithic, split later)  
> **Protocol:** REST (primary) + WebSocket (real-time)

---

## 🏗️ SYSTEM ARCHITECTURE OVERVIEW

```
┌─────────────────────────────────────────────────────────────┐
│              FLUTTER APP (Mobile + Web)                     │
│  • Role-based UI                                            │
│  • Offline-first state management                           │
│  • Real-time subscriptions                                  │
└────────────────────┬────────────────────────────────────────┘
                     │
        ┌────────────┴───────────┐
        ▼                        ▼
┌─────────────────┐      ┌─────────────────┐
│  Firebase Auth  │      │  API Gateway    │
│  (JWT tokens)   │      │  (Rate limit)   │
└─────────────────┘      └────────┬────────┘
                                   │
        ┌──────────────────────────┼──────────────────────────┐
        ▼              ▼              ▼              ▼          ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│ Auth Service │ │ Lot Service  │ │Payment Svc   │ │Logistics Svc │
│ • Register   │ │ • Lots (core)│ │ • Escrow     │ │ • Shipments  │
│ • Login      │ │ • Events     │ │ • Transactions
│ • KYC        │ │ • Custody    │ │ • Disputes   │ │ • Tracking   │
└──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘
        │              │              │              │
        └──────────────┴──────────────┴──────────────┴──────────┐
                                                                  ▼
                                  ┌─────────────────────────────────┐
                                  │    PostgreSQL Database          │
                                  │  • Relational data              │
                                  │  • Audit logs (immutable)       │
                                  │  • ACID transactions            │
                                  └─────────────────────────────────┘

        ┌──────────────────────────┐
        │  Firebase Realtime DB    │
        │  • Shipment locations    │
        │  • Live notifications    │
        │  • User presence         │
        └──────────────────────────┘

        ┌──────────────────────────┐
        │  Cloud Storage (S3)       │
        │  • Documents             │
        │  • Images                │
        │  • Lab reports           │
        └──────────────────────────┘
```

---

## 📋 API DESIGN PRINCIPLES

1. **REST for CRUD** - Predictable, standard
2. **WebSocket for Real-Time** - Live updates only (limited scope)
3. **Async Events** - Long-running ops (payments, approvals)
4. **Rate Limiting** - Per-user (prevent abuse)
5. **Error Handling** - Standardized codes + messages
6. **Request/Response** - Always JSON
7. **Authentication** - JWT Bearer token (Firebase)
8. **Authorization** - Role-based (RBAC) middleware

---

## 🔐 AUTHENTICATION FLOW

```
Frontend                    API Gateway              Firebase Auth
   │                            │                        │
   ├─ User clicks "Login" ─────►│                        │
   │                            │                        │
   │◄─── Redirect to login ─────┤                        │
   │                            │                        │
   ├─ Complete login ──────────────────────────────────►│
   │                            │                        │
   │◄─────── Firebase JWT ──────────────────────────────┤
   │                            │                        │
   ├─ Send JWT token ──────────►│                        │
   │                            │                        │
   │                            ├─ Verify JWT ──────────►│
   │                            │                        │
   │                            │◄─ Valid ───────────────┤
   │                            │                        │
   │◄─ API Response + refresh token ┤                   │
   │                            │                        │
   │ (JWT expires after 1 hour)
   │ (Refresh token expires after 7 days)
```

**Implementation:**
```typescript
// Firebase Admin SDK
import * as admin from 'firebase-admin';

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://your-project.firebaseio.com',
});

// Middleware: Verify JWT
export async function verifyAuth(req, res, next) {
  const token = req.headers.authorization?.split('Bearer ')[1];
  
  if (!token) {
    return res.status(401).json({ error: 'No token provided' });
  }
  
  try {
    const decodedToken = await admin.auth().verifyIdToken(token);
    req.user = decodedToken; // user_id = decodedToken.uid
    next();
  } catch (error) {
    res.status(401).json({ error: 'Invalid token' });
  }
}
```

---

## 📡 CORE API ENDPOINTS (Phase 1)

### **1. AUTH SERVICE**

```
POST   /auth/register
       Request: { email, password, phone, org_name, user_type }
       Response: { user_id, org_id, email_verified: false }

POST   /auth/login
       Request: { email, password } OR { phone, otp }
       Response: { access_token, refresh_token, user_id, role }

POST   /auth/refresh
       Request: { refresh_token }
       Response: { access_token }

POST   /auth/logout
       Request: {}
       Response: { success: true }

POST   /auth/request-otp
       Request: { phone }
       Response: { otp_sent: true, expires_in_seconds: 300 }

POST   /auth/verify-otp
       Request: { phone, otp }
       Response: { access_token, refresh_token }

GET    /auth/me
       Response: { user_id, email, org_id, role, kyc_status }

POST   /auth/kyc/upload
       Request: { document_type, file_url, document_number }
       Response: { doc_id, verification_status: 'pending' }

GET    /auth/kyc/status
       Response: { kyc_status, submitted_docs: [...], verified: false }
```

### **2. LOTS SERVICE (CORE)**

```
POST   /lots
       Request: { product_id, quantity, harvest_date, notes }
       Response: { lot_id, lot_number, status: 'pending' }
       Publishes: LotCreatedEvent → Firebase Realtime

GET    /lots
       Query: ?status=pending&product_id=xyz&limit=50&offset=0
       Response: { total: 152, lots: [...] }

GET    /lots/:lot_id
       Response: {
         lot: { lot_id, lot_number, product_id, quantity, status, ... },
         events: [ ... ],  // Full timeline
         custody_chain: [ ... ],
         quality_checks: [ ... ]
       }

PATCH  /lots/:lot_id/status
       Request: { new_status: 'qc_approved' }
       Response: { lot_id, status: 'qc_approved' }
       Creates: LotStatusChangedEvent (immutable)

POST   /lots/:lot_id/events
       Request: { event_type, action_data, actor_signature }
       Response: { event_id, timestamp, event_hash }
       Creates: Immutable lot_events record
       Publishes: LotEventOccurred → Firebase Realtime

GET    /lots/:lot_id/timeline
       Response: {
         events: [
           { event_id, type, actor, timestamp, action_data, ... },
           ...
         ]
       }

POST   /lots/:lot_id/quality-check
       Request: { inspector_id, quality_grade, images[], notes }
       Response: { inspection_id, grade: 'A' }

POST   /lots/search
       Request: { filters: { supplier_id, product_id, status, date_from, date_to } }
       Response: { results: [...] }

POST   /lots/:lot_id/transfer-custody
       Request: { to_user_id, witness_1, witness_2, signatures: {...} }
       Response: { custody_id, chain_link_id }
```

### **3. MARKETPLACE SERVICE (RFQ)**

```
POST   /rfqs
       Request: { product_id, quantity, budget_min, budget_max, deadline, regions }
       Response: { rfq_id, rfq_number }

GET    /rfqs
       Query: ?status=open&product_id=xyz
       Response: { rfqs: [...] }

GET    /rfqs/:rfq_id
       Response: { rfq: {...}, bids: [...] }

POST   /rfqs/:rfq_id/bids
       Request: { supplier_id, quote_price, payment_terms, lot_id }
       Response: { bid_id }
       Publishes: NewBidReceived → Firebase Realtime for buyer

GET    /rfqs/:rfq_id/bid-comparison
       Response: {
         bids: [
           { bid_id, supplier_name, price, payment_terms, score },
           ...
         ]
       }

PATCH  /rfqs/:rfq_id/award
       Request: { winning_bid_id }
       Response: { rfq_id, status: 'awarded' }
```

### **4. CONTRACTS SERVICE**

```
POST   /contracts
       Request: { buyer_id, supplier_id, contract_type, value, terms: {...} }
       Response: { contract_id, contract_number, status: 'draft' }

GET    /contracts
       Query: ?status=draft&role=buyer
       Response: { contracts: [...] }

GET    /contracts/:contract_id
       Response: {
         contract: { contract_id, value, terms, ... },
         signature_status: { buyer: 'pending', supplier: 'signed' }
       }

POST   /contracts/:contract_id/generate-pdf
       Request: {}
       Response: { pdf_url }

POST   /contracts/:contract_id/request-signature
       Request: { recipient_email, recipient_role }
       Response: { signature_request_id, sign_link_expires_in: 86400 }

POST   /contracts/:contract_id/sign
       Request: { signature_canvas_data OR e_signature_provider_response }
       Response: { signature_id, status: 'signed' }

PATCH  /contracts/:contract_id/status
       Request: { new_status: 'executed' }
       Response: { contract_id, status: 'executed' }
```

### **5. LOGISTICS SERVICE**

```
POST   /shipments
       Request: { lot_id, destination_country, shipping_mode, vehicle_id }
       Response: { shipment_id, shipment_number, status: 'pending' }

GET    /shipments
       Query: ?status=in_transit&lot_id=xyz
       Response: { shipments: [...] }

GET    /shipments/:shipment_id
       Response: {
         shipment: { shipment_id, lot_id, status, origin, destination, ... },
         events: [ ... ],
         current_location: { latitude, longitude, timestamp }
       }

POST   /shipments/:shipment_id/events
       Request: { event_type, location, photo_url, notes, signature }
       Response: { event_id }
       Publishes: ShipmentEventOccurred → Firebase Realtime

GET    /shipments/:shipment_id/realtime-location
       ** WebSocket endpoint **
       Response: Continuous GPS updates + ETA

POST   /shipments/:shipment_id/confirm-delivery
       Request: { actual_delivery_date, receiver_signature, notes }
       Response: { shipment_id, status: 'received' }
       Triggers: Payment release (if escrow)
```

### **6. PAYMENTS SERVICE**

```
POST   /payments
       Request: { contract_id, amount, idempotency_key }
       Response: { payment_id, status: 'pending' }

GET    /payments
       Query: ?contract_id=xyz&status=escrowed
       Response: { payments: [...] }

GET    /payments/:payment_id
       Response: { payment: {...}, ledger: [...] }

POST   /payments/:payment_id/initiate
       Request: { payment_method, payer_account_id }
       Response: { payment_id, status: 'processing', redirect_url? }

POST   /payments/:payment_id/confirm
       Request: { provider_transaction_id, provider_response }
       Response: { payment_id, status: 'escrowed' }

POST   /payments/:payment_id/release
       Request: { trigger_condition: 'delivery_confirmed', shipment_id }
       Response: { payment_id, status: 'released' }

GET    /payments/:payment_id/ledger
       Response: { ledger: [ { type, amount, account, timestamp }, ... ] }

POST   /payments/:payment_id/dispute
       Request: { reason, evidence_urls }
       Response: { dispute_id, status: 'open' }
```

### **7. DOCUMENTS SERVICE**

```
POST   /documents
       Request: { lot_id, document_type, content: {...} }
       Response: { doc_id, document_number, status: 'draft' }

GET    /documents/:doc_id
       Response: { document: {...}, file_url, signature_status }

POST   /documents/:doc_id/generate-pdf
       Request: {}
       Response: { file_url, document_hash }

POST   /documents/:doc_id/sign
       Request: { signature_data }
       Response: { doc_id, status: 'signed' }

POST   /dossiers
       Request: { lot_id, contract_id }
       Response: { dossier_id, dossier_number, documents: [...] }

GET    /dossiers/:dossier_id
       Response: { dossier: {...}, documents: [...] }

POST   /dossiers/:dossier_id/submit
       Request: { destination: 'customs', notes }
       Response: { dossier_id, status: 'submitted' }
```

### **8. ZONE SERVICES**

```
POST   /zone-services
       Request: { service_type, details: {...} }
       Response: { request_id, request_number, status: 'draft' }

GET    /zone-services
       Query: ?status=under_review&org_id=xyz
       Response: { requests: [...] }

GET    /zone-services/:request_id
       Response: { request: {...}, documents: [...], processing_notes }

POST   /zone-services/:request_id/submit
       Request: { documents: [...], declaration }
       Response: { request_id, status: 'submitted' }

GET    /zone-services/admin/queue
       Response: { pending_requests: [...] } (admin only)

PATCH  /zone-services/:request_id/admin/process
       Request: { action: 'approve' | 'reject', notes }
       Response: { request_id, status: 'approved' }
```

---

## 🔌 WEBSOCKET ENDPOINTS (Real-Time)

```javascript
// Connect
WS /ws/realtime?token=<JWT>

// Subscribe to shipment updates
Message: { type: 'subscribe', resource: 'shipment_123' }
Receives: { type: 'shipment_updated', shipment_id, current_location, last_event, eta }

// Subscribe to lot events
Message: { type: 'subscribe', resource: 'lot_456' }
Receives: {
  type: 'lot_event_added',
  lot_id,
  event: { event_id, type, timestamp, actor_name, action_data }
}

// Subscribe to payment status
Message: { type: 'subscribe', resource: 'payment_789' }
Receives: { type: 'payment_status_changed', payment_id, status, timestamp }

// Notifications
Message: { type: 'subscribe', resource: 'notifications' }
Receives: { type: 'notification', notification_id, title, message, timestamp }
```

---

## 📁 NestJS PROJECT STRUCTURE

```
backend/
├── src/
│   ├── main.ts                 # Entry point
│   │
│   ├── modules/
│   │   ├── auth/
│   │   │   ├── auth.controller.ts
│   │   │   ├── auth.service.ts
│   │   │   ├── auth.module.ts
│   │   │   ├── guards/
│   │   │   │   ├── jwt.guard.ts
│   │   │   │   └── roles.guard.ts
│   │   │   └── strategies/
│   │   │       └── jwt.strategy.ts
│   │   │
│   │   ├── lots/
│   │   │   ├── lots.controller.ts
│   │   │   ├── lots.service.ts
│   │   │   ├── events.service.ts      # Lot events (immutable)
│   │   │   ├── lots.module.ts
│   │   │   └── entities/
│   │   │       ├── lot.entity.ts
│   │   │       └── lot-event.entity.ts
│   │   │
│   │   ├── marketplace/
│   │   │   ├── rfq.controller.ts
│   │   │   ├── rfq.service.ts
│   │   │   ├── bid.service.ts
│   │   │   └── marketplace.module.ts
│   │   │
│   │   ├── contracts/
│   │   │   ├── contracts.controller.ts
│   │   │   ├── contracts.service.ts
│   │   │   ├── signature.service.ts
│   │   │   └── contracts.module.ts
│   │   │
│   │   ├── logistics/
│   │   │   ├── shipments.controller.ts
│   │   │   ├── shipments.service.ts
│   │   │   ├── tracking.service.ts
│   │   │   └── logistics.module.ts
│   │   │
│   │   ├── payments/
│   │   │   ├── payments.controller.ts
│   │   │   ├── payments.service.ts
│   │   │   ├── escrow.service.ts
│   │   │   ├── providers/
│   │   │   │   ├── flutterwave.provider.ts
│   │   │   │   └── stripe.provider.ts
│   │   │   └── payments.module.ts
│   │   │
│   │   ├── documents/
│   │   │   ├── documents.controller.ts
│   │   │   ├── documents.service.ts
│   │   │   ├── export.service.ts
│   │   │   └── documents.module.ts
│   │   │
│   │   └── zone-services/
│   │       ├── zone.controller.ts
│   │       ├── zone.service.ts
│   │       └── zone.module.ts
│   │
│   ├── common/
│   │   ├── decorators/
│   │   │   ├── user.decorator.ts    # Extract @User from JWT
│   │   │   └── roles.decorator.ts   # @Roles('buyer', 'supplier')
│   │   │
│   │   ├── filters/
│   │   │   └── http-exception.filter.ts
│   │   │
│   │   ├── pipes/
│   │   │   └── validation.pipe.ts
│   │   │
│   │   └── interceptors/
│   │       ├── logging.interceptor.ts
│   │       └── response.interceptor.ts
│   │
│   ├── database/
│   │   ├── migrations/
│   │   │   ├── 001_create_users.sql
│   │   │   ├── 002_create_orgs.sql
│   │   │   ├── 003_create_lots.sql
│   │   │   └── ...
│   │   │
│   │   └── seeders/
│   │       └── seed.ts
│   │
│   ├── events/
│   │   ├── lot-created.event.ts
│   │   ├── lot-event-added.event.ts
│   │   ├── shipment-updated.event.ts
│   │   └── ...
│   │
│   ├── firebase/
│   │   ├── firebase.service.ts
│   │   └── realtime-sync.service.ts
│   │
│   ├── config/
│   │   ├── database.config.ts
│   │   ├── firebase.config.ts
│   │   └── env.validation.ts
│   │
│   └── app.module.ts
│
├── test/
│   ├── auth.e2e-spec.ts
│   ├── lots.e2e-spec.ts
│   └── ...
│
├── .env.example
├── .env.local
├── ormconfig.ts              # TypeORM config
├── docker-compose.yml
└── package.json
```

---

## 🔄 ERROR HANDLING STANDARDIZATION

```typescript
// Standard error response
{
  error: {
    code: "LOT_NOT_FOUND",
    message: "Lot with ID xyz does not exist",
    status: 404,
    timestamp: "2024-04-12T10:30:00Z",
    request_id: "req_abc123"  // For debugging
  }
}

// Success response
{
  data: { ... },
  meta: {
    status: "success",
    message: "Lot created successfully",
    timestamp: "2024-04-12T10:30:00Z"
  }
}

// Paginated response
{
  data: [ ... ],
  pagination: {
    total: 500,
    limit: 50,
    offset: 0,
    pages: 10,
    current_page: 1
  },
  meta: { ... }
}
```

---

## 🔒 RATE LIMITING

```
Per-user tier:
- Free: 100 requests/minute
- Professional: 1,000 requests/minute
- Enterprise: 10,000 requests/minute

Critical endpoints (slower limits):
- POST /payments: 10/minute per user
- POST /contracts: 20/minute per user
- POST /lots: 30/minute per user
```

---

## 📊 MONITORING & LOGGING

```typescript
// All endpoints log:
- Request timestamp
- User ID
- Request method + path
- Request body (excluding sensitive fields)
- Response status
- Response time (ms)
- IP address

// Critical operations:
- All authentication events
- All payment operations
- All signature events
- All document access
- All role changes
```

---

## ✅ API CHECKLIST

- [ ] NestJS boilerplate set up
- [ ] PostgreSQL connected (TypeORM)
- [ ] Firebase Auth integrated
- [ ] All 8 service modules created
- [ ] All CRUD endpoints implemented
- [ ] WebSocket gateway (for real-time)
- [ ] Error handling standardized
- [ ] Rate limiting implemented
- [ ] Logging/monitoring set up
- [ ] API docs generated (Swagger)

