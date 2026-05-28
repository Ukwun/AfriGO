# 🎯 IMPLEMENTATION QUICK REFERENCE
## Copy-Paste Code for Weeks 2-4

---

## FILE 1: API Client - Fix Authentication

**Path:** `c:\afrigo\mobile-app\lib\data\services\api_client.dart`

**First, find this line and REPLACE with your IP:**

```dart
// FIND THIS:
baseUrl: 'http://192.168.1.100:3000/api',

// REPLACE WITH (use your actual IP from ipconfig):
baseUrl: 'http://192.168.50.XX:3000/api',
```

**Then use complete code from:**  
`WEEKS_2-4_COMPLETE_IMPLEMENTATION_GUIDE.md` → Section 1 → "FIX 1: Configure Backend API Client URL"

---

## FILE 2: Backend - Enable CORS

**Path:** `c:\afrigo\backend\src\main.ts`

**Replace entire file with:**

```typescript
import { NestFactory } from '@nestjs/core';
import { Logger } from '@nestjs/common';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  // IMPORTANT: Allow connections from Android device
  app.enableCors({
    origin: '*',
    credentials: true,
  });

  const port = process.env.API_PORT || 3000;
  const host = '0.0.0.0'; // Listen on all interfaces
  
  await app.listen(port, host);
  
  const logger = new Logger('Bootstrap');
  logger.log(`🚀 AfriGo Backend running on http://0.0.0.0:${port}`);
}

bootstrap().catch((err) => {
  console.error('Failed to start application:', err);
  process.exit(1);
});
```

---

## FILE 3: Create Lot Model

**Path:** `c:\afrigo\mobile-app\lib\domain\models\lot_model.dart`

**Create new file with complete code from:**  
`WEEKS_2-4_COMPLETE_IMPLEMENTATION_GUIDE.md` → Section 2 → "Day 1-2: Create Riverpod Providers" → "File: lib/domain/models/lot_model.dart"

---

## FILE 4: Create Lots Provider

**Path:** `c:\afrigo\mobile-app\lib\presentation\providers\lots_provider.dart`

**Create new file with complete code from:**  
`WEEKS_2-4_COMPLETE_IMPLEMENTATION_GUIDE.md` → Section 2 → "Day 1-2: Create Riverpod Providers" → "File: lib/presentation/providers/lots_provider.dart"

---

## FILE 5: Update Marketplace Screen

**Path:** `c:\afrigo\mobile-app\lib\presentation\screens\marketplace\marketplace_screen.dart`

**REPLACE entire file with complete code from:**  
`WEEKS_2-4_COMPLETE_IMPLEMENTATION_GUIDE.md` → Section 2 → "Day 3-4: Build Marketplace Screen"

---

## FILE 6: Create Shipment Model

**Path:** `c:\afrigo\mobile-app\lib\domain\models\shipment_model.dart`

**Create new file with complete code from:**  
`WEEKS_2-4_COMPLETE_IMPLEMENTATION_GUIDE.md` → Section 3 → "Day 1-2: Shipment Tracking" → "File: lib/domain/models/shipment_model.dart"

---

## FILE 7: Create Shipment Provider

**Path:** `c:\afrigo\mobile-app\lib\presentation\providers\shipment_provider.dart`

**Create new file with complete code from:**  
`WEEKS_2-4_COMPLETE_IMPLEMENTATION_GUIDE.md` → Section 3 → "Day 1-2: Shipment Tracking" → "File: lib/presentation/providers/shipment_provider.dart"

---

## FILE 8: Create Tracking Screen

**Path:** `c:\afrigo\mobile-app\lib\presentation\screens\shipments\tracking_screen.dart`

**Create new file with complete code from:**  
`WEEKS_2-4_COMPLETE_IMPLEMENTATION_GUIDE.md` → Section 3 → "Day 1-2: Shipment Tracking" → "File: lib/presentation/screens/shipments/tracking_screen.dart"

---

## FILE 9: Create Payment Provider

**Path:** `c:\afrigo\mobile-app\lib\presentation\providers\payment_provider.dart`

**Create new file with complete code from:**  
`WEEKS_2-4_COMPLETE_IMPLEMENTATION_GUIDE.md` → Section 3 → "Day 3-4: Payment Flow Integration" → "File: lib/presentation/providers/payment_provider.dart"

---

## FILE 10: Create Checkout Screen

**Path:** `c:\afrigo\mobile-app\lib\presentation\screens\payment\checkout_screen.dart`

**Create new file with complete code from:**  
`WEEKS_2-4_COMPLETE_IMPLEMENTATION_GUIDE.md` → Section 3 → "Day 3-4: Payment Flow Integration" → "File: lib/presentation/screens/payment/checkout_screen.dart"

---

## FILE 11: Timeline Animation

**Path:** `c:\afrigo\mobile-app\lib\presentation\widgets\animations\timeline_entry_animation.dart`

**Create new file with complete code from:**  
`WEEKS_2-4_COMPLETE_IMPLEMENTATION_GUIDE.md` → Section 4 → "Day 1-2: Implement 5 Micro-Animations" → "Animation 1: Timeline Entry Animation"

---

## FILE 12: Payment Success Animation

**Path:** `c:\afrigo\mobile-app\lib\presentation\widgets\animations\payment_success_animation.dart`

**Create new file with complete code from:**  
`WEEKS_2-4_COMPLETE_IMPLEMENTATION_GUIDE.md` → Section 4 → "Day 1-2: Implement 5 Micro-Animations" → "Animation 2: Payment Success Animation"

---

## FILE 13: Bid Alert Animation

**Path:** `c:\afrigo\mobile-app\lib\presentation\widgets\animations\bid_received_animation.dart`

**Create new file with complete code from:**  
`WEEKS_2-4_COMPLETE_IMPLEMENTATION_GUIDE.md` → Section 4 → "Day 1-2: Implement 5 Micro-Animations" → "Animation 3: Bid Alert"

---

## CHECKLIST: Files to Create/Modify

### Week 2 (June 4-10)
```
MODIFY:
  ✏️ lib/data/services/api_client.dart          [Update baseUrl with your IP]
  ✏️ backend/src/main.ts                        [Enable CORS]
  ✏️ lib/presentation/screens/marketplace/marketplace_screen.dart

CREATE:
  ✨ lib/domain/models/lot_model.dart
  ✨ lib/presentation/providers/lots_provider.dart
  ✨ (Run tests on Android device)
```

### Week 3 (June 11-17)
```
CREATE:
  ✨ lib/domain/models/shipment_model.dart
  ✨ lib/presentation/providers/shipment_provider.dart
  ✨ lib/presentation/screens/shipments/tracking_screen.dart
  ✨ lib/presentation/providers/payment_provider.dart
  ✨ lib/presentation/screens/payment/checkout_screen.dart
  ✨ (Run tests on Android device)
```

### Week 4 (June 18-24)
```
CREATE:
  ✨ lib/presentation/widgets/animations/timeline_entry_animation.dart
  ✨ lib/presentation/widgets/animations/payment_success_animation.dart
  ✨ lib/presentation/widgets/animations/bid_received_animation.dart
  ✨ (Run complete tests on Android device)
```

---

## DEPENDENCIES YOU MIGHT NEED

Check `pubspec.yaml` - if missing, add these:

```yaml
dependencies:
  flutter:
    sdk: flutter
  riverpod_annotation: ^2.1.0
  flutter_riverpod: ^2.3.0
  dio: ^5.0.0
  shared_preferences: ^2.0.0
  go_router: ^10.0.0
  google_maps_flutter: ^2.5.0
  json_annotation: ^4.8.0
  intl: ^0.18.0

dev_dependencies:
  build_runner: ^2.4.0
  riverpod_generator: ^2.2.0
  json_serializable: ^6.7.0
```

If you added new packages, run:
```bash
flutter pub get
```

---

## GENERATED CODE

After creating models with `@JsonSerializable()`, run:

```bash
# Terminal in mobile-app directory
flutter pub run build_runner build

# Or watch for changes:
flutter pub run build_runner watch
```

This generates `.g.dart` files (JSON serialization)

---

## DAY-BY-DAY CHECKLIST

**Week 2, Day 1 (June 4):**
- [ ] Find your laptop IP (ipconfig)
- [ ] Update api_client.dart baseUrl
- [ ] Update backend main.ts (CORS)
- [ ] Start backend: `npm run dev`
- [ ] Start app: `flutter run`
- [ ] Test login works

**Week 2, Day 2-3 (June 5-6):**
- [ ] Create lot_model.dart
- [ ] Create lots_provider.dart
- [ ] Test compilation: `flutter pub get`

**Week 2, Day 4 (June 7):**
- [ ] Create marketplace_screen.dart
- [ ] Run hot reload (R key)
- [ ] Test on device

**Week 2, Day 5 (June 10):**
- [ ] Test all features on Android
- [ ] Fix any bugs
- [ ] Document what works

**Week 3, Day 1-2 (June 11-12):**
- [ ] Create shipment_model.dart
- [ ] Create shipment_provider.dart
- [ ] Create tracking_screen.dart

**Week 3, Day 3-4 (June 13-14):**
- [ ] Create payment_provider.dart
- [ ] Create checkout_screen.dart
- [ ] Test end-to-end flow

**Week 3, Day 5 (June 17):**
- [ ] Full test on Android device
- [ ] Performance profiling
- [ ] Fix any bugs

**Week 4, Day 1-2 (June 18-19):**
- [ ] Create timeline_entry_animation.dart
- [ ] Create payment_success_animation.dart
- [ ] Create bid_received_animation.dart

**Week 4, Day 3 (June 20):**
- [ ] Integrate animations into screens
- [ ] Test animation smoothness

**Week 4, Day 4 (June 21):**
- [ ] Full end-to-end testing
- [ ] Performance measurements
- [ ] Fix any issues

**Week 4, Day 5 (June 24):**
- [ ] Complete checklist
- [ ] Document completion
- [ ] Ready for Week 5 beta

---

## IF YOU GET STUCK

### Compilation Error: "Cannot find package"
```bash
flutter pub get
flutter clean
flutter pub get
flutter run
```

### Runtime Error: "Connection refused"
- Check backend is running
- Check IP address is correct
- Check mobile and laptop on same WiFi

### Runtime Error: "No route named '/dashboard/buyer'"
- Make sure your Go Router config has this route
- Check lib/main.dart routing setup

### Slow Performance
- Hot reload issues: Run `flutter clean` + `flutter run`
- Memory leak: Dispose animation controllers properly
- Too many rebuilds: Wrap with Consumer, not entire widget

### Button Not Clickable
- Check onPressed is not null
- Check widget is wrapped in GestureDetector or Button properly
- No nested taps (button inside another tappable widget)

---

## SUCCESS INDICATORS

### If working correctly, you'll see:
```
✅ App launches without errors
✅ Login works with real backend
✅ Marketplace shows real lots (numbers from API)
✅ Buttons are responsive (tap feedback)
✅ Animations are smooth (60 FPS)
✅ No crashes in 10 minute session
✅ Data loads within 1 second
✅ Memory stays below 200MB
```

### If something's wrong, you'll see:
```
❌ "Connection refused" → Backend not running
❌ "Cannot find route" → Routing issue
❌ "Null check failed" → Missing null safety
❌ "Memory spike" → Animation not disposing
❌ "Unresponsive button" → onPressed is null
❌ "CORS error" → CORS not enabled in backend
```

---

## COPY-PASTE WORKFLOW

1. **Read Section:** Open WEEKS_2-4_COMPLETE_IMPLEMENTATION_GUIDE.md
2. **Find Code:** Navigate to exact section (Day X, File name)
3. **Copy:** Select all code in the file section
4. **Create:** Create new file at exact path shown
5. **Paste:** Paste entire code
6. **Update IP:** If api_client.dart, change baseUrl
7. **Save:** Ctrl+S
8. **Test:** `flutter run` or hot reload (R)
9. **Verify:** Check Android device for functionality

---

## FINAL CHECKLIST BEFORE GOING LIVE (Week 5)

```
FUNCTIONALITY:
  ✅ Register works (new user can create account)
  ✅ Login works (existing user can log in)
  ✅ Marketplace works (lots load and display)
  ✅ Category filter works (can filter by type)
  ✅ Details work (can view full lot info)
  ✅ Checkout works (can proceed to payment)
  ✅ Payment initiates (can start payment flow)
  ✅ Tracking works (can see GPS updates)
  ✅ Logout works (user can log out safely)

BUTTONS & ICONS:
  ✅ Register button → Creates account
  ✅ Login button → Authenticates
  ✅ Category chips → Filter data
  ✅ View Details → Shows info
  ✅ Make Offer → Goes to checkout
  ✅ Pay button → Initiates payment
  ✅ Refresh → Reloads data
  ✅ Filter → Opens filter menu
  ✅ Back → Navigates back
  ✅ All respond to taps instantly

ANIMATIONS:
  ✅ Timeline cascades (staggered 280ms)
  ✅ Payment success (confetti + checkmark)
  ✅ Bid alert (shake + bounce)
  ✅ All smooth (60 FPS, no jank)
  ✅ No lag on animations

PERFORMANCE:
  ✅ Cold launch < 3 seconds
  ✅ List scrolls smooth (60 FPS)
  ✅ Memory < 200MB
  ✅ Battery < 3% per 30 min
  ✅ No crashes in 1 hour session

REAL DEVICE TESTING:
  ✅ Tested on physical Android phone
  ✅ All flows work end-to-end
  ✅ Touch is responsive
  ✅ Data from real backend (not mock)
  ✅ No crashes or errors
```

---

**You're ready. Start today. Let's build something real.** 🚀
