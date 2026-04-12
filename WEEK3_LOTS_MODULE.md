# 📦 WEEK 3: LOTS MODULE IMPLEMENTATION PLAN

**Date:** April 12, 2026  
**Phase:** Week 3 Development  
**Duration:** 5 working days  
**Status:** Ready for Kickoff

---

## 🎯 WEEK 3 OBJECTIVES

### Primary Goals
1. ✅ Design Lots entity (product batches)
2. ✅ Implement Lots CRUD API endpoints
3. ✅ Build Lot traceability system (QR codes)
4. ✅ Create product categorization system
5. ✅ Build Lots management UI (mobile)
6. ✅ Integrate with Authentication system

### Secondary Goals
- ✅ Complete testing & validation
- ✅ Document all new endpoints
- ✅ Plan Week 4 (Quality & Lab module)

---

## 📊 DELIVERABLES BREAKDOWN

### Backend (Estimated: 1,500+ LOC)

#### 1. Lot Entity & Database Schema
```typescript
// Lots Table (25+ columns)
Lot {
  id: UUID
  supplierId: UUID (FK to User)
  productId: UUID (FK to Product)
  status: enum (draft, listed, reserved, sold, archived)
  quantity: decimal (amount available)
  quantityReserved: decimal
  quantitySold: decimal
  unit: string (kg, tonnes, bags, etc.)
  unitPrice: decimal
  totalValue: decimal (calculated)
  
  // Lot Details
  originCountry: string
  originRegion: string
  harvestDate: date
  productionDate: date
  expiryDate: date
  batchNumber: string (unique)
  
  // Quality Info
  gradeLevel: enum (A, B, C, Standard)
  moistureContent: decimal
  afflatoxinLevel: decimal
  foreignMatterPercentage: decimal
  
  // Traceability
  qrCode: string (unique)
  qrCodeUrl: string
  serialNumber: string
  locationLat: decimal
  locationLng: decimal
  storageLocation: string
  
  // Timestamps
  createdAt: timestamp
  updatedAt: timestamp
  listingDate: timestamp
  expiresAt: timestamp (when lot listing expires)
}

// Product Category Table
ProductCategory {
  id: UUID
  name: string (Coffee, Cocoa, Grain, Vegetable, etc.)
  description: string
  commonGrades: array
  subcategories: relation
}

// Lot Traceability Table
LotTraceability {
  id: UUID
  lotId: UUID (FK)
  eventType: enum (created, inspected, transported, stored, sold)
  location: string
  timestamp: timestamp
  performer: UUID (FK to User)
  metadata: JSON
}
```

#### 2. API Endpoints (12 endpoints)

| # | Endpoint | Method | Purpose | Auth |
|---|----------|--------|---------|------|
| 1 | `/lots` | GET | List all lots (with filters) | Optional |
| 2 | `/lots/:id` | GET | Get lot details | Optional |
| 3 | `/lots` | POST | Create new lot | Required |
| 4 | `/lots/:id` | PUT | Update lot | Required |
| 5 | `/lots/:id` | DELETE | Delete lot | Required |
| 6 | `/lots/:id/publish` | POST | Publish lot to marketplace | Required |
| 7 | `/lots/:id/archive` | POST | Archive lot | Required |
| 8 | `/lots/:id/qr-code` | GET | Get QR code (as image or data) | Optional |
| 9 | `/lots/batch/:batchNumber` | GET | Search by batch number | Optional |
| 10 | `/lots/supplier/:supplierId` | GET | List supplier's lots | Optional |
| 11 | `/lots/category/:categoryId` | GET | List by category | Optional |
| 12 | `/lots/:id/traceability` | GET | Get full traceability history | Optional |

#### 3. Services (4 services)

**LotService** (250+ LOC)
- CRUD operations (create, read, update, delete)
- Publish/archive logic
- Validation (quantity, prices, dates)
- Search & filter (status, category, date range)

**TraceabilityService** (150+ LOC)
- Add traceability events
- Get traceability history
- Generate timeline
- Track lot movements

**QRCodeService** (100+ LOC)
- Generate QR codes
- Create QR images
- Encode lot information
- Generate URLs

**ProductCategoryService** (100+ LOC)
- CRUD for categories
- Standard grades per category
- Category metadata

#### 4. Entities (3 files)

```
backend/src/modules/lots/entities/
├── lot.entity.ts (200 LOC)
├── product-category.entity.ts (80 LOC)
├── lot-traceability.entity.ts (80 LOC)
└── index.ts
```

#### 5. DTOs (3 files)

```
backend/src/modules/lots/dto/
├── create-lot.dto.ts (40 LOC)
├── update-lot.dto.ts (40 LOC)
├── lot-response.dto.ts (60 LOC)
└── index.ts
```

#### 6. Controllers (2 files)

```
backend/src/modules/lots/controllers/
├── lots.controller.ts (300+ LOC, 12 endpoints)
├── categories.controller.ts (100+ LOC, 4 endpoints)
└── index.ts
```

#### 7. Module Configuration

```
backend/src/modules/lots/
├── lots.module.ts (60 LOC)
└── index.ts
```

**Total Backend: 1,500+ LOC**

---

### Mobile App (Estimated: 800+ LOC)

#### 1. Lot Viewing Screen
```dart
// View all lots with filters
LotListScreen {
  - List of lots (cards)
  - Filter by: status, category, price range
  - Search by batch number
  - Sort by: date, price, location
  - Pull-to-refresh
  - Pagination
}
```

#### 2. Lot Detail Screen
```dart
// View single lot details
LotDetailScreen {
  - Lot images carousel
  - QR code display
  - Detailed specifications
  - Supplier info
  - Price & quantity
  - Grade & quality info
  - Traceability timeline
  - "Request Quote" button
}
```

#### 3. Create Lot Screen
```dart
// Create new lot (for suppliers)
CreateLotScreen {
  - Product selection dropdown
  - Quantity & unit inputs
  - Price inputs
  - Grade selection
  - Quality parameters
  - Origin information
  - Storage location
  - Image upload (multiple)
  - Preview before submit
}
```

#### 4. QR Code Scanner
```dart
// Scan lot QR codes
QRScannerScreen {
  - Camera preview
  - QR detection
  - Navigate to lot details on scan
  - Show scanned data
}
```

#### 5. Lot Management Screen (Supplier Dashboard)
```dart
// Manage own lots
LotManagementScreen {
  - List of supplier's lots
  - Filter by status
  - Edit lot actions
  - Delete lot actions
  - View statistics (sold, reserved, etc.)
  - Create new lot button
}
```

**Total Mobile: 800+ LOC**

---

### Documentation (Estimated: 500+ lines)

1. **LOTS_MODULE_API.md** - REST API documentation
2. **LOTS_DATA_MODEL.md** - Entity relationships & schema
3. **TRACEABILITY_SYSTEM.md** - Tech specs for supply chain
4. **QR_CODE_IMPLEMENTATION.md** - QR generation details
5. **LOTS_TESTING.md** - Test cases (20+ scenarios)

**Total Documentation: 500+ lines**

---

## 📅 DAY-BY-DAY BREAKDOWN

### Day 1: Database & Backend Setup (Backend)

**Morning (4 hours)**
- [ ] Design Lot entity database schema
- [ ] Design Product Category schema
- [ ] Design Lot Traceability schema
- [ ] Create migration file
- [ ] Run migrations

**Afternoon (4 hours)**
- [ ] Create entity files (3 files)
- [ ] Create DTO files (3 files)
- [ ] Setup module file
- [ ] Configure TypeORM relationships

**Deliverable:** Database schema complete, entities defined

---

### Day 2: Backend Services & Controllers (Backend)

**Morning (4 hours)**
- [ ] Implement LotService (250+ LOC)
  - [ ] Create lot
  - [ ] Read lot(s)
  - [ ] Update lot
  - [ ] Delete lot
  - [ ] List with filters
- [ ] Implement validation logic
- [ ] Implement error handling

**Afternoon (4 hours)**
- [ ] Implement TraceabilityService (150+ LOC)
- [ ] Implement QRCodeService (100+ LOC)
- [ ] Implement ProductCategoryService (100+ LOC)
- [ ] Test all services

**Deliverable:** All services complete and tested

---

### Day 3: API Endpoints (Backend)

**Morning (4 hours)**
- [ ] Create LotController (12 endpoints)
  - [ ] GET /lots (list with filters)
  - [ ] GET /lots/:id (details)
  - [ ] POST /lots (create)
  - [ ] PUT /lots/:id (update)
  - [ ] DELETE /lots/:id (delete)
  - [ ] POST /lots/:id/publish (publish)
  - [ ] POST /lots/:id/archive (archive)
  - [ ] GET /lots/:id/qr-code (QR)
  - [ ] GET /lots/batch/:batchNumber (search)
  - [ ] GET /lots/supplier/:supplierId (supplier lots)
  - [ ] GET /lots/category/:categoryId (by category)
  - [ ] GET /lots/:id/traceability (history)

**Afternoon (4 hours)**
- [ ] Create CategoryController (4 endpoints)
  - [ ] GET /categories
  - [ ] GET /categories/:id
  - [ ] POST /categories (admin only)
  - [ ] PUT /categories/:id (admin only)
- [ ] Add route protection with JwtAuthGuard
- [ ] Test all endpoints with curl

**Deliverable:** All 16 endpoints working, curl tested

---

### Day 4: Mobile UI (Mobile)

**Morning (4 hours)**
- [ ] Create Lot List Screen (200+ LOC)
  - [ ] Display lot cards
  - [ ] Implement filters
  - [ ] Implement search
  - [ ] Pagination logic
- [ ] Create Lot Detail Screen (150+ LOC)
  - [ ] Display all lot information
  - [ ] Show QR code
  - [ ] Traceability timeline

**Afternoon (4 hours)**
- [ ] Create Create Lot Screen (200+ LOC)
  - [ ] Form fields for all lot properties
  - [ ] Product selection dropdown
  - [ ] Image upload
  - [ ] Preview before submit
- [ ] Create QR Scanner Screen (100+ LOC)
- [ ] Create Lot Management Screen (150+ LOC)

**Deliverable:** All UI screens complete

---

### Day 5: Integration & Testing (Both)

**Morning (4 hours)**
- [ ] Connect mobile screens to API
- [ ] Test all API calls from mobile
- [ ] Implement error handling
- [ ] Add loading states
- [ ] Test across different screen sizes

**Afternoon (4 hours)**
- [ ] Complete documentation
- [ ] Run comprehensive test suite
- [ ] Create test plan for Week 4
- [ ] Code review & cleanup
- [ ] Prepare Week 4 spec

**Deliverable:** Fully integrated, tested, documented

---

## 🔧 TECHNICAL SPECIFICATIONS

### Database Relationships

```
User (Supplier)
  ├─ has many Lots
  └─ has many LotTraceability events

Lot
  ├─ belongs to User (supplier)
  ├─ belongs to ProductCategory
  ├─ has many LotTraceability events
  └─ has one QRCode

ProductCategory
  └─ has many Lots

LotTraceability
  ├─ belongs to Lot
  └─ belongs to User (performer)
```

### API Response Format

**Success Response (200)**
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "supplierId": "660e8400-e29b-41d4-a716-446655440001",
    "productCategory": "Coffee",
    "quantity": 50000,
    "unit": "kg",
    "status": "listed",
    "qrCode": "AFG-2026-04-0001",
    ...
  },
  "timestamp": "2026-04-12T15:30:00Z"
}
```

**Error Response (400/401/500)**
```json
{
  "success": false,
  "error": "Invalid lot quantity",
  "statusCode": 400,
  "timestamp": "2026-04-12T15:30:00Z"
}
```

### Validation Rules

**Lot Creation**
- ✓ Quantity > 0
- ✓ Unit Price >= 0
- ✓ Harvest date <= today
- ✓ Expiry date > today
- ✓ Batch number unique per supplier
- ✓ Valid product category
- ✓ Grade level valid for category

**Lot Update**
- ✓ Can only update draft lots
- ✓ Cannot decrease quantity below sold amount
- ✓ Supplier can only update own lots

**Publishing**
- ✓ Lot must be in "draft" status
- ✓ All required fields must be filled
- ✓ Status changes to "listed"

---

## 🧪 TESTING PLAN (Week 3)

### Backend Tests (20+ scenarios)

**CRUD Operations**
- [ ] Create lot (valid input)
- [ ] Create lot (missing required fields)
- [ ] Read lot by ID
- [ ] Read list of lots
- [ ] Update lot (valid changes)
- [ ] Update lot (invalid data)
- [ ] Delete lot
- [ ] Delete non-existent lot (404)

**Filters & Searches**
- [ ] Filter by status
- [ ] Filter by category
- [ ] Filter by price range
- [ ] Filter by date range
- [ ] Search by batch number
- [ ] Search by supplier ID
- [ ] Pagination (offset/limit)

**Business Logic**
- [ ] Publish lot (valid)
- [ ] Publish lot (already published)
- [ ] Archive lot
- [ ] Quantity calculations
- [ ] Price validations

**Traceability**
- [ ] Add traceability event
- [ ] Get traceability history
- [ ] Timeline generation

**QR Code**
- [ ] Generate QR code
- [ ] Scan QR code
- [ ] QR data validation

**Authentication & Authorization**
- [ ] Protected endpoints require JWT
- [ ] Supplier can only modify own lots
- [ ] Non-suppliers cannot create lots

### Mobile Tests (15+ scenarios)

**UI Rendering**
- [ ] Lot list displays correctly
- [ ] Lot detail screen shows all info
- [ ] Create lot form has all fields
- [ ] QR code displays properly
- [ ] Images load correctly

**User Interactions**
- [ ] Can filter lots
- [ ] Can search lots
- [ ] Can create new lot
- [ ] Can edit own lot
- [ ] Can delete own lot
- [ ] Can scan QR code

**Data Sync**
- [ ] API data loads into mobile
- [ ] Form data submits to API
- [ ] Errors display properly
- [ ] Loading states show

**Edge Cases**
- [ ] Empty lot list
- [ ] Network disconnection
- [ ] Invalid QR scan
- [ ] Form validation errors

---

## 📈 METRICS & SUCCESS CRITERIA

### Code Metrics
- ✅ Backend: 1,500+ LOC
- ✅ Mobile: 800+ LOC
- ✅ Tests: 20+ Backend + 15+ Mobile
- ✅ Documentation: 500+ lines

### Performance Targets
- ✅ List lots: <500ms
- ✅ Get lot detail: <300ms
- ✅ Create lot: <2s
- ✅ QR generation: <100ms
- ✅ Mobile screen load: <1s

### Quality Standards
- ✅ 100% endpoint coverage
- ✅ All validations passed
- ✅ Zero security issues
- ✅ All tests pass
- ✅ Complete documentation

---

## 🔗 INTEGRATION POINTS

### With Auth Module (Week 1-2)
- ✅ Lot creation requires authenticated user
- ✅ Supplier ID from auth context
- ✅ JwtAuthGuard on protected endpoints
- ✅ User roles (buyer vs seller)

### With Marketplace (Week 5-7)
- ✅ Lots published to marketplace
- ✅ Buyers can find lots
- ✅ Create RFQ for lot
- ✅ Price discovery

### With Quality Module (Week 4)
- ✅ Quality grades stored in lot
- ✅ Link to quality tests
- ✅ Lab results integration
- ✅ Quality certification

### With Logistics (Week 11-12)
- ✅ Lot location tracking
- ✅ Delivery integration
- ✅ Transportation status
- ✅ Traceability updates

---

## 📚 FILES TO CREATE

### Backend (13 files)
```
backend/src/modules/lots/
├── entities/
│   ├── lot.entity.ts (200 LOC)
│   ├── product-category.entity.ts (80 LOC)
│   ├── lot-traceability.entity.ts (80 LOC)
│   └── index.ts (8 LOC)
├── dto/
│   ├── create-lot.dto.ts (40 LOC)
│   ├── update-lot.dto.ts (40 LOC)
│   ├── lot-response.dto.ts (60 LOC)
│   └── index.ts (8 LOC)
├── services/
│   ├── lot.service.ts (250 LOC)
│   ├── traceability.service.ts (150 LOC)
│   ├── qrcode.service.ts (100 LOC)
│   ├── product-category.service.ts (100 LOC)
│   └── index.ts (8 LOC)
├── controllers/
│   ├── lots.controller.ts (300 LOC)
│   ├── categories.controller.ts (100 LOC)
│   └── index.ts (8 LOC)
├── lots.module.ts (60 LOC)
└── index.ts (8 LOC)
```

### Mobile (5 screens, 800+ LOC)
```
mobile-app/lib/presentation/screens/
├── lots/
│   ├── lot_list_screen.dart (200 LOC)
│   ├── lot_detail_screen.dart (150 LOC)
│   ├── create_lot_screen.dart (200 LOC)
│   ├── lot_management_screen.dart (150 LOC)
│   └── qr_scanner_screen.dart (100 LOC)
```

### Documentation (5 files, 500+ lines)
```
c:\afrigo\
├── LOTS_MODULE_API.md
├── LOTS_DATA_MODEL.md
├── TRACEABILITY_SYSTEM.md
├── QR_CODE_IMPLEMENTATION.md
└── LOTS_TESTING.md
```

---

## ⚠️ DEPENDENCIES & BLOCKERS

### Required (Already Done)
- ✅ Authentication system (Week 1-2)
- ✅ JWT tokens working
- ✅ Database connection established

### New Dependencies
- [ ] QR code library (for code generation)
  - Backend: `qrcode` npm package (2 KB)
  - Mobile: `qr_flutter` package

### No Blockers
- ✅ Will not be blocked by external services
- ✅ Can proceed immediately after Week 2 sign-off
- ✅ Self-contained module

---

## 🚀 KICKOFF PREPARATION

### Pre-Week 3 Checklist
- [ ] All Week 1-2 tests PASS
- [ ] Week 2 code signed off
- [ ] Review this document
- [ ] Setup development environment
- [ ] Create database backups

### Day 1 Morning Checklist
- [ ] Pull latest code: `git pull origin main`
- [ ] Create Week 3 branch: `git checkout -b feature/lots-module`
- [ ] Verify environment: `npm run type-check`
- [ ] Start development

---

## 📞 REFERENCE DOCUMENTS

| Document | Use For |
|----------|---------|
| COMPREHENSIVE_PROJECT_ANALYSIS.md | Full project context |
| TESTING_PLAN.md | How to test |
| DATABASE_SETUP_GUIDE.md | Database reference |
| API_ARCHITECTURE.md | API patterns |

---

## 🎉 WEEK 3 SUCCESS LOOKS LIKE

✅ All 12 lot endpoints working  
✅ All 4 category endpoints working  
✅ Mobile screens showing lot data  
✅ QR codes generating and scanning  
✅ All 20+ backend tests passing  
✅ All 15+ mobile tests passing  
✅ Complete documentation  
✅ Ready for Week 4 (Quality module)

---

**Week 3 Ready to Begin!** 🚀

**Next Step:** After Week 2 sign-off → Start Day 1: Database Schema

---

*Generated: April 12, 2026*  
*Week: 3 of 24*  
*Team: Architecture & Development*  
*Status: Planning Complete*
