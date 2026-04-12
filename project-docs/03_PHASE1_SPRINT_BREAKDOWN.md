# AfriGo Phase 1 - Detailed Sprint Breakdown

> **Total Duration:** 14 weeks (3.5 months)  
> **Team Size:** 5-6 engineers  
> **Methodology:** Agile (2-week sprints)

---

## 📅 SPRINT SCHEDULE

### **SPRINTS 1-2: AUTH + KYC + DASHBOARD (Weeks 1-4)**

#### **Sprint 1 (Week 1)**

**Theme:** Authentication Foundation

**Backend Tasks (2 engineers)**
- [ ] Firebase Admin SDK integration
- [ ] PostgreSQL users/orgs tables migration
- [ ] Auth service (register, login, refresh token)
- [ ] OTP generation & verification logic
- [ ] JWT token generation & validation
- [ ] Firebase Auth configuration
- [ ] User audit logging setup
- [ ] API docs (Swagger) for auth endpoints
- [ ] Unit tests for auth service

**Deliverable:** POST /auth/register, POST /auth/login, POST /auth/refresh working

**Frontend Tasks (2 engineers)**
- [ ] Flutter project setup (Clean Architecture)
- [ ] Riverpod state management setup
- [ ] Go Router navigation configured
- [ ] Splash screen
- [ ] Login screen UI (design tokens applied)
- [ ] Register screen UI
- [ ] OTP input screen
- [ ] Theme system (colors.dart, typography.dart)
- [ ] API client (Dio) setup

**Deliverable:** User can see login, register, OTP screens (UI only, not connected)

**DevOps Tasks (0.5 engineer)**
- [ ] GitHub repo setup (with CI/CD workflow)
- [ ] Environment variables (.env.local)
- [ ] Docker files for backend
- [ ] GitHub Actions for testing

**Deliverable:** Automated tests run on every push

---

#### **Sprint 2 (Week 2)**

**Theme:** KYC Verification

**Backend Tasks**
- [ ] KYC documents table migration
- [ ] Document upload handler (S3 integration)
- [ ] File validation (virus scan, size checks)
- [ ] KYC status management
- [ ] Organization creation
- [ ] Role assignment (RBAC)
- [ ] Tests for KYC flow

**Deliverable:** POST /auth/kyc/upload, GET /auth/kyc/status working

**Frontend Tasks**
- [ ] Connect login screen to API
- [ ] Connect register screen to API
- [ ] Document picker (camera + gallery)
- [ ] Document upload UI
- [ ] Verification status screen
- [ ] Loading states (skeletons)
- [ ] Error handling & retries
- [ ] Deep linking (direct to app after auth)

**Deliverable:** Full auth flow end-to-end (user can register, upload docs)

---

### **SPRINT 3: DASHBOARD FOUNDATION (Week 3)**

**Theme:** Role-Based Dashboards

**Backend Tasks**
- [ ] Dashboard data service
- [ ] KPI calculation (by user role)
- [ ] Real-time KPI provider
- [ ] Notification center backend
- [ ] Activity feed endpoints
- [ ] User presence tracking (Firebase)

**Deliverable:** GET /dashboard, GET /notifications endpoints

**Frontend Tasks**
- [ ] Dashboard layout (role-based switching)
- [ ] Supplier dashboard widgets
- [ ] Buyer dashboard widgets
- [ ] KPI cards & animation
- [ ] Activity feed UI
- [ ] Notifications center UI
- [ ] Bottom navigation setup
- [ ] Responsive design (mobile + tablet)

**Deliverable:** Users can see their role-specific dashboard with real data

---

### **SPRINT 4: LOT TRACEABILITY - PART 1 (Week 4)**

**Theme:** Lot Creation + Timeline Foundation

**Backend Tasks**
- [ ] Lots table migration
- [ ] Lot creation service
- [ ] Lot_events table (immutable)
- [ ] LotCreatedEvent trigger
- [ ] Lot list/search endpoints
- [ ] Event timestamp + signature logic
- [ ] Event hashing (SHA256)

**Frontend Tasks**
- [ ] Lot creation form (multi-step)
- [ ] Lot list screen (with filters)
- [ ] Lot details screen (basic)
- [ ] Timeline component (structure, no animation yet)
- [ ] Status badge component

**Deliverable:** Supplier can create lot, see lot in list

---

### **SPRINTS 5-6: LOT TRACEABILITY - PART 2 + QUALITY (Weeks 5-6)**

#### **Sprint 5 (Week 5)**

**Theme:** Timeline Animations + Events

**Backend Tasks**
- [ ] Post /lots/:id/events endpoint
- [ ] All event types defined (created, qc_submitted, qc_passed, etc.)
- [ ] Custody chain creation
- [ ] WebSocket setup (Firebase Realtime sync)
- [ ] Real-time event broadcasting

**Frontend Tasks**
- [ ] Animated timeline widget (all animations from spec)
  - [ ] Event entry animation (fade + scale + slide)
  - [ ] Node completion animation (scale + color + pulse)
  - [ ] Connecting line animation (growth)
  - [ ] Expand/collapse animation (stagger)
- [ ] Add event form
- [ ] Real-time event subscription (WebSocket)
- [ ] Timestamp formatting + caching
- [ ] Offline support (cache lots locally)

**Deliverable:** Timeline is 100% animated and responsive

---

#### **Sprint 6 (Week 6)**

**Theme:** Quality & Lab Integration

**Backend Tasks**
- [ ] Quality inspections table migration
- [ ] Inspection form builder
- [ ] Lab reports integration
- [ ] Grade classification endpoints
- [ ] Quality approval workflow
- [ ] Image upload + CDN delivery

**Frontend Tasks**
- [ ] Inspection form screens
- [ ] Image picker (multiple + camera)
- [ ] Quality grade selector
- [ ] Lab report viewer
- [ ] Quality metrics dashboard

**Deliverable:** Inspectors can submit quality reports with images

---

### **SPRINT 7: MARKETPLACE (Week 7)**

**Theme:** RFQ Creation + Bidding

**Backend Tasks**
- [ ] RFQ table migration
- [ ] RFQ creation + broadcast service
- [ ] Bids table migration
- [ ] Bid submission service
- [ ] Bid comparison calculation
- [ ] RFQ filtering by region
- [ ] Notification on new bids (Firebase)

**Frontend Tasks**
- [ ] RFQ creation form (multi-step)
- [ ] RFQ list screen (by user role)
- [ ] RFQ details screen
- [ ] Bid submission form
- [ ] Bid comparison UI (side-by-side)
- [ ] RFQ awarding screen

**Deliverable:** Buyer can post RFQ, suppliers can bid, buyer can see comparison

---

### **SPRINT 8: CONTRACTS (Week 8)**

**Theme:** Contract Generation + E-Signature

**Backend Tasks**
- [ ] Contracts table migration
- [ ] Contract template engine
- [ ] Contract auto-generation from RFQ+Bid
- [ ] E-signature provider integration (Firebase-based or 3rd party)
- [ ] Signature verification
- [ ] Contract amendments

**Frontend Tasks**
- [ ] Contract viewer (PDF + web view)
- [ ] Signature pad widget
- [ ] Signature request flow
- [ ] Amendment proposal UI
- [ ] Contract status tracking

**Deliverable:** Contract can be generated, viewed, and signed e-sig style

---

### **SPRINT 9: LOGISTICS (Week 9)**

**Theme:** Shipment Creation + Real-Time Tracking

**Backend Tasks**
- [ ] Shipments table migration
- [ ] Shipment_events table
- [ ] Shipment creation service
- [ ] Tracking event endpoints
- [ ] Real-time location sync (Firebase)
- [ ] ETA calculation
- [ ] Driver assignment (basic)

**Frontend Tasks**
- [ ] Shipment creation form
- [ ] Shipment list screen
- [ ] Real-time tracking map (with Google Maps)
- [ ] Tracking timeline (reuses timeline component)
- [ ] Event reporting form (for drivers/logistics)
- [ ] Delivery confirmation screen

**Deliverable:** Shipment can be created, tracked in real-time, delivered

---

### **SPRINT 10: PAYMENTS + ESCROW (Week 10)**

**Theme:** Payment Processing + Escrow Logic

**Backend Tasks**
- [ ] Payments table migration
- [ ] Payment_ledger table (immutable)
- [ ] Idempotency key validation
- [ ] Payment gateway integration (Flutterwave)
- [ ] Escrow account setup
- [ ] Release trigger logic (delivery confirmation)
- [ ] Dispute handling basics
- [ ] Transaction ledger

**Frontend Tasks**
- [ ] Payment initiation screen
- [ ] Payment method selector
- [ ] Payment confirmation screen
- [ ] Payment status (real-time updates)
- [ ] Escrow timeline visualization
- [ ] Dispute raising form

**Deliverable:** Payment flow works end-to-end (initiator → escrow → release)

---

### **SPRINTS 11-14: INTEGRATION + HARDENING**

#### **Sprint 11 (Week 11)**

**Theme:** Export Documents + Dossiers

**Backend Tasks**
- [ ] Export documents table migration
- [ ] Document generation (templates for phytosanitary, COO, invoice)
- [ ] Dossier bundling
- [ ] Document signing
- [ ] Download endpoints

**Frontend Tasks**
- [ ] Document generator UI
- [ ] Dossier viewer
- [ ] Download center
- [ ] Document preview

**Deliverable:** Export dossier can be auto-generated and downloaded

---

#### **Sprint 12 (Week 12)**

**Theme:** Zone Services + Admin Panel

**Backend Tasks**
- [ ] Zone services table migration
- [ ] Service request workflow
- [ ] Admin processing queue
- [ ] Status tracking

**Frontend Tasks**
- [ ] Service request form (multi-form UX)
- [ ] Request status tracking
- [ ] Admin processing panel
- [ ] Approval/rejection workflow

**Deliverable:** Users can request zone services, admins can process

---

#### **Sprint 13 (Week 13)**

**Theme:** End-to-End Testing & Bug Fixes

**Both Teams**
- [ ] Integration tests (full flows)
- [ ] Load testing (1000+ concurrent users)
- [ ] Security audit (OWASP)
- [ ] Performance optimization
- [ ] Bug fixes from testing
- [ ] Performance profiling
- [ ] Memory leak checks

**Deliverable:** All critical paths tested + stable

---

#### **Sprint 14 (Week 14)**

**Theme:** Polish + Production Prep

**Both Teams**
- [ ] UI/UX polish (animations, transitions)
- [ ] Accessibility audit (WCAG AA)
- [ ] Internationalization setup (English first)
- [ ] API documentation finalization
- [ ] Deployment infrastructure (staging + prod)
- [ ] Monitoring setup (error tracking, APM)
- [ ] Backup & disaster recovery
- [ ] Final security review

**Deliverable:** MVP ready for production launch

---

## 🎯 FEATURE COMPLETION BY SPRINT

| Feature | Sprint | Status |
|---------|--------|--------|
| Auth (email/phone/OTP) | 1-2 | ✅ |
| KYC verification | 2 | ✅ |
| Role-based dashboard | 3 | ✅ |
| Lot creation | 4 | ✅ |
| Lot timeline (animated) | 5 | ✅ 🎬 |
| Quality inspections | 6 | ✅ |
| RFQ marketplace | 7 | ✅ |
| Contracts + e-sig | 8 | ✅ |
| Logistics tracking | 9 | ✅ |
| Payments + escrow | 10 | ✅ |
| Export documents | 11 | ✅ |
| Zone services | 12 | ✅ |
| Integration testing | 13 | ✅ |
| Production ready | 14 | ✅ |

---

## 📊 TEAM ASSIGNMENTS (Recommended)

```
iOS Lead (Flutter Mobile) ............... 1 engineer
Android Lead (Flutter Mobile) ........... 1 engineer (same person, for cross-platform)
Back-end Lead (Node.js/NestJS) ......... 1-2 engineers
Database Architect (PostgreSQL/Schema) . 0.5 engineer
DevOps/Infrastructure .................. 0.5 engineer
QA/Test Lead ............................ 1 engineer

Total: 5.5 engineers (can scale up to 7 if needed)
```

**Daily Standup:** 15 min (each team + both)  
**Sprint Planning:** 2 hours (start of sprint)  
**Sprint Review:** 1.5 hours (end of sprint)  
**Retrospective:** 1 hour (end of sprint)

---

## 🚀 DEPLOYMENT STRATEGY

### **Staging Environment**
- Deploy after each sprint
- Full testing by QA
- Stakeholder demo

### **Production Environment**
- Week 14 end: First production deploy
- Canary deployment (10% users first)
- Monitor error rates, performance
- Gradual rollout to 100%

---

## ✅ SPRINT SUCCESS CRITERIA

Each sprint must meet:

1. **Code Quality**
   - [ ] 80%+ test coverage
   - [ ] Zero critical bugs
   - [ ] Code review passed

2. **Performance**
   - [ ] API responses < 300ms (p95)
   - [ ] Frontend < 60 FPS animations
   - [ ] No memory leaks

3. **Security**
   - [ ] No SQL injection
   - [ ] No unauthorized access
   - [ ] All sensitive data encrypted

4. **User Experience**
   - [ ] All animations smooth (60 FPS)
   - [ ] All screens responsive (mobile + tablet)
   - [ ] Error messages clear

5. **Documentation**
   - [ ] API documented
   - [ ] Code commented
   - [ ] README updated

---

## 📝 SPRINT TEMPLATE (Use for each sprint)

```
Sprint: #X (Week Y)
Theme: [Feature name]

Goals:
- [ ] Goal 1
- [ ] Goal 2
- [ ] Goal 3

Backend Tasks:
- [ ] Task 1 (2 days)
- [ ] Task 2 (1 day)
- ...

Frontend Tasks:
- [ ] Task 1 (1.5 days)
- [ ] Task 2 (2 days)
- ...

Blockers:
- (To be filled during sprint)

Deliverable:
- What does "done" look like?
```

---

## 🎬 ANIMATION SPRINT FOCUS (Sprint 5 CRITICAL)

**Timeline animations are your competitive advantage.** Allocate 1 full engineer-week to:

- Event entry (280ms)
- Node activation (220ms + 600ms pulse)
- Connecting line growth (400ms)
- Expand/collapse (320ms expand, 200ms collapse)
- Scroll parallax
- Real-time update pulse

**Testing:**
- 60 FPS on Pixel 6 + iPhone 12+
- Smooth on mid-range devices (Moto G)
- No jank on lower-end (Moto E)

