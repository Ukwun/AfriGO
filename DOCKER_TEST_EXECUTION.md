# 🐳 DOCKER INSTALLATION & TEST EXECUTION GUIDE

**Date:** April 12, 2026  
**Objective:** Install Docker → Run complete test suite → Sign-off  
**Estimated Time:** 2-3 hours total

---

## ⚠️ IMPORTANT: This is a MANUAL EXECUTION GUIDE

This guide provides step-by-step instructions YOU must execute. I cannot install Docker or run tests remotely - these are local system operations.

**What's Required:**
- Administrative access to your Windows machine
- ~1 GB free disk space
- 10-15 minutes for Docker installation
- 90 minutes for testing

---

## PART 1: INSTALL DOCKER

### Step 1: Download Docker Desktop

1. **Open browser** (any browser)
2. **Go to:** https://www.docker.com/products/docker-desktop
3. **Click:** "Download for Windows"
4. **Save file:** `Docker Desktop Installer.exe`

### Step 2: Run Docker Desktop Installer

1. **Locate** the downloaded `Docker Desktop Installer.exe`
2. **Right-click** → "Run as Administrator"
3. **Click** "Yes" on the User Account Control prompt
4. **Follow** the installation wizard (click "Install" → Next, etc.)
5. **Allow Windows Hypervisor** when prompted
6. **Restart** your computer when installation completes

### Step 3: Verify Docker Installation

After restart, open PowerShell and run:

```powershell
docker --version
# Expected output: Docker version 26.0.0 (or higher)

docker ps
# Expected output: List of containers (empty list is fine)
```

✅ **If both commands work, Docker is installed!**

---

## PART 2: PREPARE TESTING ENVIRONMENT

### Terminal 1: Start Database

Open **PowerShell (as Administrator)** and run:

```powershell
cd c:\afrigo

# Start Docker containers (database + PgAdmin)
docker-compose up -d

# Wait 10 seconds for database to fully initialize
Start-Sleep -Seconds 10

# Verify containers are running
docker ps
```

✅ **Expected output:**
```
CONTAINER ID   IMAGE              STATUS                   NAMES
abc123xyz      postgres:15        Up 5 seconds (healthy)   afrigo_postgres_dev
def456uvw      dpage/pgadmin4     Up 5 seconds             afrigo_pgadmin
```

### Terminal 2: Start Backend Server

Open **another PowerShell window** and run:

```powershell
cd c:\afrigo\backend

# Install dependencies (if not already done)
npm install --legacy-peer-deps

# Start backend in development mode
npm run dev

# Wait for server to start...
# Expected output: "Server running on http://localhost:3000"
```

✅ **When you see "Starting Nest application", backend is ready**

### Terminal 3: Keep Open for Testing

Keep this terminal available for running curl commands. Don't close it.

---

## PART 3: RUN API TESTS (Terminal 3)

### Copy-Paste Testing Commands

For each test below:
1. Copy the ENTIRE curl command
2. Paste into Terminal 3
3. Verify the expected response
4. Check off the checkbox ✅

---

### TEST 1: Register New User

```powershell
curl -X POST http://localhost:3000/api/auth/register `
  -H "Content-Type: application/json" `
  -d '{
    "email": "testuser001@example.com",
    "password": "SecurePassword123",
    "firstName": "Test",
    "lastName": "User",
    "phone": "+254700000001",
    "organizationName": "Test Company",
    "countryCode": "KE"
  }' | ConvertFrom-Json | ConvertTo-Json
```

**Expected Response:**
```json
{
  "accessToken": "eyJhbGciOi...",
  "refreshToken": "eyJhbGciOi...",
  "user": {
    "id": "550e8400-e29b-...",
    "email": "testuser001@example.com",
    "firstName": "Test",
    "lastName": "User",
    "fullName": "Test User",
    "roles": [],
    "kycStatus": "pending",
    "emailVerified": false,
    "phoneVerified": false,
    "trustScore": 0,
    "completedTrades": 0
  }
}
```

**Validation Checklist:**
- [ ] Status code: 201
- [ ] Has accessToken (long string)
- [ ] Has refreshToken (long string)
- [ ] User email matches
- [ ] kycStatus is "pending"

✅ **Result:** PASS / FAIL

---

### TEST 2: Register Duplicate Email (Should Fail)

```powershell
curl -X POST http://localhost:3000/api/auth/register `
  -H "Content-Type: application/json" `
  -d '{
    "email": "testuser001@example.com",
    "password": "SecurePassword123",
    "firstName": "Another",
    "lastName": "User"
  }' | ConvertFrom-Json | ConvertTo-Json
```

**Expected Response:** 409 Conflict (email already exists)

✅ **Result:** PASS / FAIL

---

### TEST 3: Login with Valid Credentials

**IMPORTANT:** Save the accessToken from TEST 1 response for later tests

```powershell
$response = curl -X POST http://localhost:3000/api/auth/login `
  -H "Content-Type: application/json" `  
  -d '{
    "email": "testuser001@example.com",
    "password": "SecurePassword123"
  }' | ConvertFrom-Json

# Display the response
$response | ConvertTo-Json

# Save token for next tests
$TOKEN = $response.accessToken
Write-Host "Token saved: $TOKEN"
```

**Expected Response:** 200 OK with tokens

**Validation:**
- [ ] Status code: 200
- [ ] Has accessToken
- [ ] Has refreshToken
- [ ] User data returned

✅ **Result:** PASS / FAIL

---

### TEST 4: Login with Wrong Password (Should Fail)

```powershell
curl -X POST http://localhost:3000/api/auth/login `
  -H "Content-Type: application/json" `
  -d '{
    "email": "testuser001@example.com",
    "password": "WrongPassword"
  }' | ConvertFrom-Json | ConvertTo-Json
```

**Expected Response:** 401 Unauthorized - "Invalid email or password"

**Validation:**
- [ ] Status code: 401
- [ ] Error message shown
- [ ] No token returned

✅ **Result:** PASS / FAIL

---

### TEST 5: Get User Profile (Protected Route)

**First, set the token variable:**
```powershell
# Use the token from TEST 3
$TOKEN = "eyJhbGciOi..."  # Replace with actual token
```

**Then run:**
```powershell
curl -X GET http://localhost:3000/api/auth/me `
  -H "Authorization: Bearer $TOKEN" | ConvertFrom-Json | ConvertTo-Json
```

**Expected Response:** 200 OK with user profile

**Validation:**
- [ ] Status code: 200
- [ ] User data returned
- [ ] Email matches
- [ ] createdAt timestamp present

✅ **Result:** PASS / FAIL

---

### TEST 6: Get User Without Token (Should Fail)

```powershell
curl -X GET http://localhost:3000/api/auth/me | ConvertFrom-Json | ConvertTo-Json
```

**Expected Response:** 401 Unauthorized

**Validation:**
- [ ] Status code: 401
- [ ] No user data returned

✅ **Result:** PASS / FAIL

---

### TEST 7: Update User Profile

```powershell
curl -X PUT http://localhost:3000/api/auth/profile `
  -H "Content-Type: application/json" `
  -H "Authorization: Bearer $TOKEN" `
  -d '{
    "firstName": "TestUpdated",
    "organizationName": "Updated Company",
    "location": "Nairobi, Kenya"
  }' | ConvertFrom-Json | ConvertTo-Json
```

**Expected Response:** 200 OK with updated data

**Validation:**
- [ ] Status code: 200
- [ ] firstName changed to "TestUpdated"
- [ ] organizationName updated
- [ ] location updated

✅ **Result:** PASS / FAIL

---

### TEST 8: Refresh Token

**Get refreshToken from TEST 3 response:**
```powershell
$REFRESH_TOKEN = "eyJhbGciOi..."  # Replace with actual refresh token

curl -X POST http://localhost:3000/api/auth/refresh `
  -H "Content-Type: application/json" `
  -d "{\"refreshToken\": \"$REFRESH_TOKEN\"}" | ConvertFrom-Json | ConvertTo-Json
```

**Expected Response:** 200 OK with new tokens

**Validation:**
- [ ] Status code: 200
- [ ] New accessToken returned
- [ ] New refreshToken returned

✅ **Result:** PASS / FAIL

---

### TEST 9: Logout

```powershell
curl -X POST http://localhost:3000/api/auth/logout `
  -H "Authorization: Bearer $TOKEN" | ConvertFrom-Json | ConvertTo-Json
```

**Expected Response:** 200 OK - "Logged out successfully"

**Validation:**
- [ ] Status code: 200
- [ ] Success message shown

✅ **Result:** PASS / FAIL

---

### TEST 10: Invalid Email Registration (Should Fail)

```powershell
curl -X POST http://localhost:3000/api/auth/register `
  -H "Content-Type: application/json" `
  -d '{
    "email": "notanemail",
    "password": "SecurePassword123",
    "firstName": "Test",
    "lastName": "User"
  }' | ConvertFrom-Json | ConvertTo-Json
```

**Expected Response:** 400 Bad Request - email validation error

**Validation:**
- [ ] Status code: 400
- [ ] Error message about invalid email

✅ **Result:** PASS / FAIL

---

## PART 4: MOBILE APP TESTING

### Terminal 4: Start Flutter App

Open **new PowerShell window**:

```powershell
cd c:\afrigo\mobile-app

# Get dependencies (if needed)
flutter pub get

# Run the app
flutter run

# Select platform:
# For Android: Press 'a'
# For iOS: Press 'i'
# For Web: Press 'w'
```

**Wait for app to launch** (30-60 seconds)

---

### FLOW 1: Register New Account

1. **App loads** → Login Screen visible
2. **See "Create Account" link** → Click it
3. **Register Screen appears** with form fields
4. **Fill form:**
   ```
   First Name: FlutterTest
   Last Name: User
   Email: fluttertest@example.com
   Password: FlutterPass123
   Confirm: FlutterPass123
   Phone: +254700000002
   Organization: Flutter Test Corp
   Country: KE
   Role: Buyer
   Terms: ✓ Check
   ```
5. **Tap "Create Account"** button
6. **Verify:**
   - [ ] Loading spinner appears
   - [ ] No error messages shown
   - [ ] Redirects to dashboard OR verify-email screen

✅ **Result:** PASS / FAIL

---

### FLOW 2: Login with Registered Account

1. **From Register screen, tap "Sign In" link**
2. **Login Screen appears**
3. **Fill credentials:**
   ```
   Email: fluttertest@example.com
   Password: FlutterPass123
   ```
4. **Tap "Sign In"** button
5. **Verify:**
   - [ ] Loading spinner appears
   - [ ] Redirects to dashboard
   - [ ] User data displayed

✅ **Result:** PASS / FAIL

---

### FLOW 3: Login with Wrong Password

1. **Go back to Login Screen** (or restart app)
2. **Enter:**
   ```
   Email: fluttertest@example.com
   Password: WrongPassword
   ```
3. **Tap "Sign In"**
4. **Verify:**
   - [ ] Error message shows: "Invalid email or password"
   - [ ] Message appears in RED box
   - [ ] NOT redirected to dashboard
   - [ ] Can retry

✅ **Result:** PASS / FAIL

---

### FLOW 4: Form Validation

1. **Go to Register Screen**
2. **Click Submit WITHOUT entering anything**
3. **Verify:** Error shows "First name is required"
4. **Enter first name, submit**
5. **Verify:** Error shows "Last name is required"
6. **Continue testing all fields** (email, password, etc.)
7. **For password field:**
   - Enter "short" → Error: "Password must be 8+ characters"
   - Enter "NoNumber" → Error: "Must include uppercase and numbers"
   - Enter "NoUppercase123" → Error: "Must include uppercase"

✅ **Result:** PASS / FAIL

---

### FLOW 5: Password Visibility Toggle

1. **Go to Login Screen**
2. **Type in Password field**: `TestPassword123`
3. **Verify:** Text shows as bullets: ••••••••••••••
4. **Tap eye icon** next to password
5. **Verify:** Password shows as plain text: `TestPassword123`
6. **Tap eye icon again**
7. **Verify:** Password hidden again as bullets

✅ **Result:** PASS / FAIL

---

### FLOW 6: Terms & Conditions

1. **Go to Register Screen**
2. **Fill all fields**
3. **DON'T check Terms checkbox**
4. **Click Submit**
5. **Verify:** Error shows "Please agree to terms and conditions"
6. **Check the checkbox**
7. **Click Submit**
8. **Verify:** Form submits (no error about terms)

✅ **Result:** PASS / FAIL

---

## PART 5: DATABASE VALIDATION

### Terminal 5: Connect to Database

```powershell
# Verify PgAdmin is running
Start-Process "http://localhost:5050"

# Login credentials:
# Email: admin@afrigo.local
# Password: admin_password_123
```

### Verify Tables Exist

In PgAdmin:
1. Left panel → Servers → postgres → Databases → afrigo_dev → Schemas → public
2. Expand "Tables"
3. **Verify you see:**
   - [ ] users
   - [ ] user_roles
   - [ ] verification_tokens

### Check User Records

Run in PgAdmin Query Tool:

```sql
SELECT id, email, first_name, account_status, created_at 
FROM users 
WHERE email = 'testuser001@example.com';
```

**Expected:** User row exists with correct data

✅ **Result:** PASS / FAIL

---

## PART 6: SIGN-OFF

### Test Results Summary

Fill in this table:

```
╔════════════════════════════════════════════════════╗
║           BACKEND API TESTS (10)                   ║
╠════════════════════════════════════════════════════╣
║ Test #  │ Description          │ Status            ║
╠═════════╪══════════════════════╪═══════════════════╣
║ 1       │ Register User        │ [ ] PASS [ ] FAIL ║
║ 2       │ Duplicate Email      │ [ ] PASS [ ] FAIL ║
║ 3       │ Valid Login          │ [ ] PASS [ ] FAIL ║
║ 4       │ Invalid Password     │ [ ] PASS [ ] FAIL ║
║ 5       │ Get Profile          │ [ ] PASS [ ] FAIL ║
║ 6       │ No Token             │ [ ] PASS [ ] FAIL ║
║ 7       │ Update Profile       │ [ ] PASS [ ] FAIL ║
║ 8       │ Refresh Token        │ [ ] PASS [ ] FAIL ║
║ 9       │ Logout               │ [ ] PASS [ ] FAIL ║
║ 10      │ Invalid Email        │ [ ] PASS [ ] FAIL ║
╠════════════════════════════════════════════════════╣
║ Overall API Tests:   [ ] ALL PASS [ ] SOME FAILED ║
╚════════════════════════════════════════════════════╝

╔════════════════════════════════════════════════════╗
║         MOBILE APP TESTS (6 FLOWS)                ║
╠════════════════════════════════════════════════════╣
║ Flow #  │ Description          │ Status            ║
╠═════════╪══════════════════════╪═══════════════════╣
║ 1       │ Register Account     │ [ ] PASS [ ] FAIL ║
║ 2       │ Valid Login          │ [ ] PASS [ ] FAIL ║
║ 3       │ Invalid Password     │ [ ] PASS [ ] FAIL ║
║ 4       │ Form Validation      │ [ ] PASS [ ] FAIL ║
║ 5       │ Password Toggle      │ [ ] PASS [ ] FAIL ║
║ 6       │ Terms Validation     │ [ ] PASS [ ] FAIL ║
╠════════════════════════════════════════════════════╣
║ Overall Mobile Tests: [ ] ALL PASS [ ] SOME FAILED║
╚════════════════════════════════════════════════════╝

╔════════════════════════════════════════════════════╗
║       DATABASE VALIDATION                          ║
╠════════════════════════════════════════════════════╣
║ Check   │ Description          │ Status            ║
╠═════════╪══════════════════════╪═══════════════════╣
║ 1       │ Tables Exist         │ [ ] PASS [ ] FAIL ║
║ 2       │ User Records         │ [ ] PASS [ ] FAIL ║
║ 3       │ Audit Fields         │ [ ] PASS [ ] FAIL ║
╠════════════════════════════════════════════════════╣
║ Overall DB Validation: [ ] ALL PASS [ ] SOME FAILED║
╚════════════════════════════════════════════════════╝

╔════════════════════════════════════════════════════╗
║         FINAL SIGN-OFF                            ║
╠════════════════════════════════════════════════════╣
║                                                    ║
║ Backend API Tests:      [ ] PASS [ ] FAIL          ║
║ Mobile UI Tests:        [ ] PASS [ ] FAIL          ║
║ Database Validation:    [ ] PASS [ ] FAIL          ║
║                                                    ║
║ OVERALL STATUS:         [ ] PASS [ ] FAIL          ║
║                                                    ║
║ Signed by: ___________________  Date: ___________  ║
║                                                    ║
╚════════════════════════════════════════════════════╝
```

### Issues Found (if any)

```
Issue 1:
Description: ___________________________________
Status: [ ] Blocking [ ] Minor
Resolution: ______________________________

Issue 2:
Description: ___________________________________
Status: [ ] Blocking [ ] Minor
Resolution: ______________________________
```

---

## CLEANUP AFTER TESTING

When done testing, stop services:

```powershell
# Terminal 1: Stop Docker
docker-compose down

# Terminal 2: Stop Backend
Ctrl+C

# Terminal 3: (can close)

# Terminal 4: Stop Flutter
Ctrl+C

# Terminal 5: (close PgAdmin browser)
```

---

## ✅ NEXT: WEEK 3 PLANNING

When all tests PASS, move to [WEEK3_LOTS_MODULE.md](../WEEK3_LOTS_MODULE.md)

**Expected completion:** 
- Docker install: 15 minutes
- Testing: 90 minutes
- Total: ~2 hours

**Status:** Ready to begin! ✅
