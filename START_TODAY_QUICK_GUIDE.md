# 🚀 QUICK START: GET RUNNING TODAY (May 28, 2026)

## YOUR IMMEDIATE ACTION PLAN (Next 2 Hours)

### STEP 1: Find Your Laptop's Local Network IP (5 minutes)

```bash
# Windows: Open PowerShell and run
ipconfig

# Look for: "IPv4 Address" under your WiFi adapter
# Example output:
# Ethernet adapter WiFi:
#    IPv4 Address. . . . . . . . . : 192.168.1.100
#    Subnet Mask . . . . . . . . . : 255.255.255.0

# WRITE DOWN YOUR IP: _____._____._____._____ 
# (You'll use this in next step)
```

---

### STEP 2: Update Mobile App to Connect to Your Backend (5 minutes)

**File:** `c:\afrigo\mobile-app\lib\data\services\api_client.dart`

Find this line:
```dart
baseUrl: 'http://192.168.1.100:3000/api', // ← CHANGE THIS
```

Replace `192.168.1.100` with YOUR IP from Step 1:
```dart
baseUrl: 'http://YOUR.IP.HERE:3000/api',
```

**Example:**
```dart
// If your IP is 192.168.50.42, change to:
baseUrl: 'http://192.168.50.42:3000/api',
```

---

### STEP 3: Connect Android Device via USB (5 minutes)

```bash
# 1. Connect your phone to laptop with USB cable
# 2. Phone will ask "Allow USB Debugging?" → Tap "Allow"
# 3. Verify connection:

adb devices

# Expected output:
# List of attached devices
# emulator-5554           device
# ABC123DEF456            device    ← Your phone appears here
```

---

### STEP 4: Start Backend API (Terminal 1)

```bash
# Terminal 1: Start backend
cd c:\afrigo\backend
npm run dev

# Expected output:
# [Nest] 12345  - 05/28/2026, 2:30:45 PM     LOG [NestFactory] Starting Nest application...
# 🚀 AfriGo Backend running on http://0.0.0.0:3000
# 📱 Accessible from: http://YOUR_IP:3000

# ✅ Backend is running and ready
```

---

### STEP 5: Run Mobile App on Android Device (Terminal 2)

```bash
# Terminal 2: Run app on connected device
cd c:\afrigo\mobile-app
flutter clean
flutter pub get
flutter run

# Expected output:
# Launching lib/main.dart on [your-device] in debug mode...
# ✓ Built build/app/outputs/flutter-app.apk
# Installed build/app/outputs/flutter-app.apk
# 
# ✅ App launches on your phone
```

---

### STEP 6: Test Login (Right Now)

**On your Android phone, in the running app:**

```
1. Tap "Register" button
2. Enter:
   Email: test@afrigo.app
   Password: Test@123456
   First Name: John
   Last Name: Doe
3. Tap "Register"
4. Watch console for API call
5. Should see: Login successful → Redirected to dashboard

✅ If this works, authentication is FIXED!
```

---

## WHAT YOU'LL SEE

### If It Works ✅
```
App Screen: Login → Success → Dashboard loads
Terminal: 
  POST /auth/register 200 OK
  Token received: eyJhbGc...
Browser: No errors, smooth transition
```

### If It Fails ❌
```
Common Error 1: "Connection refused"
  Fix: Check your IP address is correct
  Fix: Make sure backend is running (Step 4)
  
Common Error 2: "Cannot POST /auth/register"
  Fix: URL might be wrong
  Fix: Double-check IP address in api_client.dart
  
Common Error 3: "Unable to connect to host"
  Fix: Phone might be on different WiFi
  Fix: Make sure phone and laptop on same WiFi network
  
Common Error 4: "timeout waiting for response"
  Fix: Backend might be starting slowly
  Fix: Wait 10 seconds after "running on" message
```

---

## TROUBLESHOOTING

### Issue: Device Not Showing in "adb devices"

```bash
# Solution 1: Restart ADB
adb kill-server
adb start-server
adb devices

# Solution 2: Use IP connection (wireless)
adb connect YOUR.IP:5555
adb devices

# Solution 3: Install drivers (Windows only)
# Go to Device Manager → Find Android device → Right-click → Update driver
```

### Issue: "Cannot connect to backend"

```bash
# Check backend is actually running:
# Go to browser and visit: http://192.168.50.XX:3000/api/health
# Should return: {"status":"ok"}

# If not working:
# 1. Check you're on same WiFi as laptop
# 2. Disable firewalls temporarily (test only)
# 3. Restart backend: ctrl+C then npm run dev again
```

### Issue: "CORS error"

```dart
// This should be fixed by the CORS configuration in main.ts
// If still seeing errors, check:
// File: backend/src/main.ts
// Should have: app.enableCors({ origin: '*' })
```

---

## FIRST SUCCESSFUL TEST

When you see this, you know everything is working:

```
Phone Screen:
  ✅ Dashboard loaded
  ✅ User name displayed: "John Doe"
  ✅ Marketplace tab shows real lots
  ✅ Profile shows email: "test@afrigo.app"

Terminal shows:
  POST /auth/register 201 Created
  User registered successfully
  Token: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
  
Performance:
  ✅ No lag
  ✅ No errors
  ✅ Smooth animations
```

---

## CONTINUE WITH WEEK 2

Once login is working, open: `WEEKS_2-4_COMPLETE_IMPLEMENTATION_GUIDE.md`

Then follow:
- **Day 1-2:** Create Riverpod providers for API calls
- **Day 3-4:** Build marketplace screen (connected to real API)
- **Day 5:** Test on Android device

---

## TERMINAL COMMANDS YOU'LL USE

```bash
# Start backend
cd c:\afrigo\backend && npm run dev

# Start mobile app
cd c:\afrigo\mobile-app && flutter run

# Hot reload (while app running)
# Press 'R' in terminal

# Full restart
# Press 'X' in terminal

# View logs
flutter logs

# Check connected devices
adb devices

# Rebuild
flutter clean && flutter pub get
```

---

## SUCCESS CRITERIA

By end of today (May 28):
- ✅ Backend running on http://YOUR_IP:3000
- ✅ App running on connected Android device
- ✅ Can register new account
- ✅ Dashboard loads with user data
- ✅ No authentication errors

**If you have all 5 ✅, you're ready for Week 2!**

---

**Start NOW. Open two terminals. Step 1 → Step 2 → Step 3 → Step 4 → Step 5 → Test Login.**

**You got this! Let's go.** 🚀
