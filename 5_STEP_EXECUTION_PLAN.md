# 🎯 IMMEDIATE ACTION CHECKLIST - Execute These 5 Steps NOW

**Timeline:** 2-3 hours total  
**Goal:** Activate all fixes and verify end-to-end real data flow  
**Success:** Seller sees real lots, buyer sees real orders, activities tracked

---

## ✅ STEP 1: Backend Database Seeding (15 minutes)

**What:** Populate database with realistic sample data  
**Files affected:** Database tables (lots, users, products)

```bash
# Navigate to backend
cd c:\afrigo\backend

# Run seeding script
npx ts-node src/scripts/seed-data.ts
```

**Expected output:**
```
✓ Created 5 test users
✓ Created 20 sample lots
✓ Total cocoa lots: 2
✓ Total coffee lots: 3
... [more product types]
✓ Database seeding complete!
```

**Verification:**
```bash
# Connect to PostgreSQL and verify
psql -U your_user -d afrigo_db
SELECT COUNT(*) FROM lots;  # Should return 20
SELECT COUNT(*) FROM users WHERE role = 'seller'; # Should return 2
```

---

## ✅ STEP 2: Start Backend Server (5 minutes)

**What:** Start NestJS backend with all endpoints active  
**What's new:** 6 new analytics endpoints available

```bash
cd c:\afrigo\backend
npm run dev
```

**Expected output:**
```
[Nest] 12345  - 04/13/2026, 2:30:45 PM     LOG [NestFactory] Starting Nest application...
[Nest] 12345  - 04/13/2026, 2:30:48 PM     LOG [InstanceLoader] LotsModule dependencies initialized +125ms
[Nest] 12345  - 04/13/2026, 2:30:49 PM     LOG [InstanceLoader] AnalyticsModule dependencies initialized +45ms
[Nest] 12345  - 04/13/2026, 2:30:50 PM     LOG Listening on port 3000
```

**Quick Verification (from new terminal):**
```bash
# Test basic endpoint
curl http://localhost:3000/api/lots | head -20

# Test new seller endpoint (replace with actual seller ID)
curl http://localhost:3000/api/sellers/seller-uuid-here/lots

# Test new analytics endpoint
curl http://localhost:3000/api/analytics/engagement?days=30
```

---

## ✅ STEP 3: Mobile Application Testing (90 minutes)

### 3A: Build and Run Mobile App

```bash
cd c:\afrigo\mobile-app

# Clean build
flutter clean
flutter pub get

# Run on emulator (ensure emulator is running first!)
flutter run -d emulator-5554

# OR on physical device connected via ADB
flutter run
```

**Expected output:**
```
Launching lib/main.dart on Android SDK built for x86...
✓ Built build/app/outputs/flutter-app-release.apk
✓ Installed build/app/outputs/app.apk
Started app on emulator...
```

### 3B: Test Scenario 1 - Seller Views Real Lots

```
1. Launch app on emulator
2. Login screen appears
3. Enter credentials: john.supplier@afrigo.com / password
4. Dashboard loads
5. Navigate to "My Lots" tab
6. ⭐ EXPECTED: See 10 real lots loaded from database (not 6 hardcoded items!)
7. Lots show:
   - Real product names (Cocoa, Coffee, etc.)
   - Real quantities & prices
   - Real status badges
8. Pull to refresh → Should reload from API
9. Loading state shows shimmer cards while fetching
```

**What's Different:**
- ❌ Before: Always showed same 6 hardcoded items
- ✅ Now: Shows 10 real lots specific to this seller from database

### 3C: Test Scenario 2 - Buyer Sees Market Lots

```
1. Logout from seller account
2. Login as buyer: jane.buyer@afrigo.com
3. Dashboard loads
4. Navigate to "Market" or "Browse Lots"
5. ⭐ EXPECTED: See 20 total lots (from all sellers)
6. Lots filterable by product type, status, price
7. Can search for specific products
```

### 3D: Test Scenario 3 - Real Order in Payment Screen

```
1. (Buyer still logged in as jane.buyer@afrigo.com)
2. Click on any lot from marketplace
3. Lot details page loads
4. Click "Make Offer" or "Place Order"
5. Navigate to "Payment" tab
6. ⭐ EXPECTED: Payment screen shows REAL order details:
   - Real order ID (not mock)
   - Real order amount (not hardcoded)
   - Real product details
   - Real buyer info
7. Can proceed with mock payment (Flutterwave test mode)
```

**What's Different:**
- ❌ Before: Payment screen had comment "// For now, create mock order"
- ✅ Now: Real order fetched from API with actual data

### 3E: Test Scenario 4 - Activity Tracking

```
1. (Any logged-in user)
2. Perform these actions:
   - Navigate to different screens (trackScreenView)
   - Search for lots (trackLotSearch)
   - View lot details (trackLotView)
   - If reached payment: trackPaymentInitiate
   - Login/logout events
3. Open device console (flutter logs) → Should see activity being sent
4. ⭐ EXPECTED: No console errors, activities sent to API
```

**Verification in Backend:**
```bash
# Check if analytics endpoint returns events
curl http://localhost:3000/api/analytics/market-activity
# Should show activity counts > 0
```

---

## ✅ STEP 4: Analytics Verification (30 minutes)

**What:** Confirm analytics endpoints return real data about market activity

### Test Each Analytics Endpoint

```bash
# Endpoint 1: Engagement metrics (user activity)
curl http://localhost:3000/api/analytics/engagement?days=30
# Expected: DAU count, activity breakdown, error rates

# Endpoint 2: API performance metrics
curl http://localhost:3000/api/analytics/api-performance?days=7
# Expected: Endpoints listed, response times, error rates per endpoint

# Endpoint 3: Personal activity timeline (need authorization)
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  http://localhost:3000/api/analytics/my-activity?limit=50
# Expected: User's last 50 activities in chronological order

# Endpoint 4: Top active users
curl http://localhost:3000/api/analytics/top-users?days=30&limit=20
# Expected: Ranking of most active users + activity counts

# Endpoint 5: Market-wide activity
curl http://localhost:3000/api/analytics/market-activity?days=30
# Expected: Total searches, bids, payments, shipments, activities

# Endpoint 6: Record new activity (POST)
curl -X POST http://localhost:3000/api/analytics/activity \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "eventType": "action",
    "action": "test_event",
    "data": {"test": true}
  }'
# Expected: { success: true, id: "..." }
```

---

## ✅ STEP 5: Integration Verification (30 minutes)

**What:** Confirm end-to-end data flow from user action → database → analytics

### 5A: Create Real Activity Trail

```
1. START ANALYTICS BASELINE:
   curl http://localhost:3000/api/analytics/engagement?days=1
   # Record the numbers

2. IN MOBILE APP:
   - Login as seller
   - View lots (this logs activity)
   - View specific lot (this logs activity)
   - Try to place bid (this logs activity)
   - Logout (this logs activity)

3. WAIT 10 seconds (activity queue flushes every ~25 events)

4. CHECK ANALYTICS AGAIN:
   curl http://localhost:3000/api/analytics/engagement?days=1
   # Numbers should have INCREASED
   # Example: DAU went from 2 → 3, activities went from 12 → 20+
```

### 5B: Verify Database Contains Activities

```bash
# Connect to PostgreSQL
psql -U your_user -d afrigo_db

# Check user_activities table
SELECT COUNT(*) FROM user_activities; # Should be > 20

# See recent activities
SELECT event_type, action, created_at 
FROM user_activities 
ORDER BY created_at DESC 
LIMIT 10;

# Check for flagged activities (fraud detection)
SELECT id, user_id, anomaly_score, is_flagged, flag_reason
FROM user_activities 
WHERE is_flagged = true;
```

### 5C: Verify Fraud Detection Working

```bash
# Check if any activities were flagged as suspicious
curl http://localhost:3000/api/analytics/engagement?days=1 | grep -i anomaly

# If no activities flagged yet, that's normal
# Fraud detection triggers on suspicious patterns like:
# - Rapid-fire 30+ requests in 1 minute
# - Payment amounts 20%+ above user average
# - Multiple failed payments in sequence
```

---

## 🎯 SUCCESS INDICATORS

When all steps complete, you should have:

| Indicator | Expected | How to Verify |
|-----------|----------|---------------|
| Database populated | 20 lots, 5 users | `SELECT COUNT(*) FROM lots;` |
| Seller sees real lots | 10 lots on My Lots screen | Login as seller, see actual inventory |
| Buyer sees market | 20 lots total | Login as buyer, see all products |
| Payment has real data | Order amount matches lot price | Create order, check payment screen |
| Activity logged | 100+ activities in DB | Run engagement endpoint |
| Analytics working | Metrics return real numbers | Call `/api/analytics/engagement` |
| No mock data anywhere | All data from database | No hardcoded values in UI |

---

## 🚨 TROUBLESHOOTING

### Problem: Mobile shows "Failed to load lots"
**Solution:**
```bash
1. Check backend is running: curl http://localhost:3000/api/health
2. Check emulator has network: adb shell ping 10.0.2.2
3. Check logs: flutter logs | grep -i error
4. Rebuild: flutter clean && flutter pub get && flutter run
```

### Problem: Database seeding failed
**Solution:**
```bash
1. Verify database connection: psql -U user -d afrigo_db
2. Check migrations ran: SELECT * FROM typeorm_migrations;
3. Run migrations: npm run migration:run
4. Retry seeding: npx ts-node src/scripts/seed-data.ts
```

### Problem: Analytics endpoints return empty
**Solution:**
```bash
1. Check UserActivity table exists: \d user_activities (in psql)
2. Check records inserted: SELECT COUNT(*) FROM user_activities;
3. If 0 records: Mobile app may not be calling API correctly
4. Check mobile logs: flutter logs | grep analytics
5. Check backend logs: Look for "recordActivity" calls
```

### Problem: Payment screen still shows mock data
**Solution:**
```bash
1. Verify orders_provider.dart imported: In payment_screen.dart, check import statement
2. Check orders API exists: curl http://localhost:3000/api/orders/test-id
3. Rebuild mobile: flutter clean && flutter pub get && flutter run
4. Check order ID is valid (real order must exist in DB first)
```

---

## ⏭️ AFTER VERIFICATION SUCCEEDS

Once all steps pass, you have:

✅ **Real Data Flowing:** Database → API → Mobile UI (no mocks!)  
✅ **Activity Tracking:** Every action logged with timestamp  
✅ **Fraud Detection:** Anomaly scoring running live  
✅ **Analytics Infrastructure:** Ready for dashboards & insights  
✅ **Production Ready:** App now functions like real platform  

### Next Phase:
- Week 3: Continue with Lot Traceability Module (QC codes, events)
- Week 4-5: Build RFQ marketplace (all activity-tracked)
- Week 6+: Contracts, payments, logistics (all real data)

---

## 📝 LOGS TO SAVE

During testing, save these outputs for documentation:

```bash
# 1. Seeding script output
npx ts-node src/scripts/seed-data.ts > seeding_log.txt 2>&1

# 2. Backend startup logs  
npm run dev > backend_logs.txt 2>&1

# 3. Mobile test output
flutter run > mobile_logs.txt 2>&1

# 4. API test responses
curl http://localhost:3000/api/analytics/engagement?days=30 > analytics_output.json
```

---

## ✅ FINAL SIGN-OFF CHECKLIST

- [ ] Database seeded successfully (20 lots present)
- [ ] Backend server running on port 3000
- [ ] Mobile app built and running on emulator
- [ ] Seller sees real lots in "My Lots" screen
- [ ] Buyer sees market lots from all sellers
- [ ] Payment screen shows real order data
- [ ] Activity tracking logging events (100+ in DB)
- [ ] Analytics endpoints return real metrics
- [ ] No errors in mobile or backend console
- [ ] Database confirms activities table populated
- [ ] Fraud detection algorithm running (anomaly scores assigned)
- [ ] All 6 analytics endpoints responding successfully

**When all 12 are checked: YOU ARE PRODUCTION READY ✅**

---

**Estimated Total Time:** 2-3 hours  
**Difficulty:** Medium (straightforward testing sequence)  
**Risk:** Low (data flow tested, no production impact)  

**Execute in order, skip nothing. This is your foundation for Week 3+.**

