# Quick Start Testing Commands

**Copy-paste ready testing for AfriGo Authentication API**

---

## Prerequisites (One-time Setup)

```pwsh
# Terminal 1: Start PostgreSQL
cd c:\afrigo
docker-compose up -d

# Terminal 2: Start Backend (in new terminal)
cd c:\afrigo\backend
npm run dev
# Wait for: "[Nest] ... LOG [NestFactory] Starting Nest application..."
# Verify: Server running on http://localhost:3000
```

---

## API Testing (Terminal 3 - Copy & Paste Commands)

### 1️⃣ Register New User
```pwsh
curl -X POST http://localhost:3000/api/auth/register `
  -H "Content-Type: application/json" `
  -d '{
    "email": "john.doe.test@example.com",
    "password": "SecurePassword123",
    "firstName": "John",
    "lastName": "Doe",
    "phone": "+254700000000",
    "organizationName": "Doe Trading",
    "countryCode": "KE"
  }' | ConvertFrom-Json | ConvertTo-Json
```

✅ **Expected:** `201 Created` with accessToken, refreshToken, user object

---

### 2️⃣ Login User
```pwsh
curl -X POST http://localhost:3000/api/auth/login `
  -H "Content-Type: application/json" `
  -d '{
    "email": "john.doe.test@example.com",
    "password": "SecurePassword123"
  }' | ConvertFrom-Json | ConvertTo-Json
```

✅ **Expected:** `200 OK` with tokens and user data

---

### 3️⃣ Save Token for Next Tests
```pwsh
# Run login above, then copy the accessToken value
# Create a variable (replace with actual token):
$TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1..."
```

---

### 4️⃣ Get Current User (Protected)
```pwsh
curl -X GET http://localhost:3000/api/auth/me `
  -H "Authorization: Bearer $TOKEN" | ConvertFrom-Json | ConvertTo-Json
```

✅ **Expected:** `200 OK` with complete user profile

---

### 5️⃣ Get Without Token (Should Fail)
```pwsh
curl -X GET http://localhost:3000/api/auth/me | ConvertFrom-Json | ConvertTo-Json
```

✅ **Expected:** `401 Unauthorized`

---

### 6️⃣ Update Profile (Protected)
```pwsh
curl -X PUT http://localhost:3000/api/auth/profile `
  -H "Content-Type: application/json" `
  -H "Authorization: Bearer $TOKEN" `
  -d '{
    "firstName": "Jonathan",
    "organizationName": "Doe Trading Enterprises",
    "location": "Nairobi, Kenya"
  }' | ConvertFrom-Json | ConvertTo-Json
```

✅ **Expected:** `200 OK` with updated user data

---

### 7️⃣ Invalid Login (Should Fail)
```pwsh
curl -X POST http://localhost:3000/api/auth/login `
  -H "Content-Type: application/json" `
  -d '{
    "email": "john.doe.test@example.com",
    "password": "WrongPassword"
  }' | ConvertFrom-Json | ConvertTo-Json
```

✅ **Expected:** `401 Unauthorized` - "Invalid email or password"

---

### 8️⃣ Refresh Token
```pwsh
# From login response, get the refreshToken:
$REFRESH_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

curl -X POST http://localhost:3000/api/auth/refresh `
  -H "Content-Type: application/json" `
  -d "{\"refreshToken\": \"$REFRESH_TOKEN\"}" | ConvertFrom-Json | ConvertTo-Json
```

✅ **Expected:** `200 OK` with new accessToken and refreshToken

---

### 9️⃣ Logout
```pwsh
curl -X POST http://localhost:3000/api/auth/logout `
  -H "Authorization: Bearer $TOKEN" | ConvertFrom-Json | ConvertTo-Json
```

✅ **Expected:** `200 OK` - "Logged out successfully"

---

### 🔟 Weak Password (Should Fail)
```pwsh
curl -X POST http://localhost:3000/api/auth/register `
  -H "Content-Type: application/json" `
  -d '{
    "email": "test@example.com",
    "password": "weak",
    "firstName": "Test",
    "lastName": "User"
  }' | ConvertFrom-Json | ConvertTo-Json
```

✅ **Expected:** `400 Bad Request` - password validation error

---

## Flutter App Testing

### Start Backend (if not running)
```pwsh
cd c:\afrigo\backend
npm run dev
```

### Terminal 4: Start Flutter App
```pwsh
cd c:\afrigo\mobile-app
flutter run
# Or open emulator/device first, then run
```

---

## Test Scenarios in Flutter App

### Scenario 1: Register New Account
1. Click "Create Account"
2. Fill: John / Doe / john@test.com / SecurePass123 / SecurePass123
3. Click checkbox for terms
4. Submit
5. ✅ Should redirect to dashboard or verify-email

### Scenario 2: Login
1. (Restart app if needed)
2. Email: john@test.com
3. Password: SecurePass123
4. Click "Sign In"
5. ✅ Should see dashboard or home screen

### Scenario 3: Password Wrong
1. Same as above
2. Password: WrongPassword
3. Click "Sign In"
4. ✅ Should show red error box: "Invalid email or password"

### Scenario 4: Form Validation
1. Click "Create Account"
2. Click Submit without entering anything
3. ✅ Should show "First name is required"
4. Enter first name, submit
5. ✅ Should show "Last name is required"
6. (Continue for all fields)

### Scenario 5: Password Visibility
1. On Register screen, type in Password field
2. ✅ Text shows as bullets
3. Click eye icon
4. ✅ Text shows as plain text
5. Click eye again
6. ✅ Text hidden again

---

## Verification Checklist

After running all tests, verify:

### Backend Tests
- [ ] Test 1: Register successful (201)
- [ ] Test 2: Login successful (200)
- [ ] Test 3: Get user with token (200)
- [ ] Test 4: Get user without token fails (401)
- [ ] Test 5: Update profile (200)
- [ ] Test 6: Invalid login fails (401)
- [ ] Test 7: Weak password fails (400)
- [ ] Test 8: Refresh token works (200)
- [ ] Test 9: Logout works (200)

### Mobile Tests
- [ ] Register screen appears on "Create Account" tap
- [ ] All form fields visible and work
- [ ] Form validation shows errors
- [ ] Can register account successfully
- [ ] Can login with registered account
- [ ] Shows error for invalid password
- [ ] Shows error when fields missing
- [ ] Password visibility toggle works
- [ ] Loading spinner appears during submit
- [ ] Dashboard shows after login

### Database Checks
- [ ] postgres_data volume exists (docker volume ls)
- [ ] User records created in database
- [ ] PgAdmin accessible at http://localhost:5050
- [ ] Can query users table

---

## Troubleshooting

### "Connection refused" or "Cannot connect to backend"
1. Verify backend is running: Check Terminal 2 for "Starting Nest application"
2. Verify port 3000 is not blocked
3. Restart backend: Ctrl+C then `npm run dev` again

### "Cannot find module @nestjs/config"
```pwsh
cd backend
npm install @nestjs/config --legacy-peer-deps
npm run dev
```

### "Flutter app won't connect to API"
1. **Emulator:** Use http://10.0.2.2:3000 (Android) or http://localhost:3000 (iOS)
2. **Physical device:** Get your IP: `ipconfig` → Use http://192.168.x.x:3000
3. **WSL:** Use WSL IP if backend running in WSL

### "Database error" or "Cannot connect to database"
```pwsh
# Check if PostgreSQL is running
docker ps
# Should see: afrigo_postgres_dev RUNNING

# If not running:
docker-compose up -d postgres
```

### Token errors in API calls
1. Make sure token is from a RECENT login (not old)
2. Copy the full token value (very long string)
3. Use exact format: `Authorization: Bearer eyJ...`

---

## Expected Response Format

### Successful Login (Test #2)
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ...",
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "john.doe.test@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "fullName": "John Doe",
    "roles": [],
    "kycStatus": "pending",
    "emailVerified": false,
    "phoneVerified": false,
    "trustScore": 0,
    "completedTrades": 0
  }
}
```

### Error Response (Test #7)
```json
{
  "statusCode": 401,
  "message": "Invalid email or password",
  "error": "Unauthorized"
}
```

---

## Summary

| Test | Expected | Status |
|------|----------|--------|
| 1. Register | 201 Created | __ |
| 2. Login | 200 OK | __ |
| 3. Get User | 200 OK | __ |
| 4. No Token | 401 Unauth | __ |
| 5. Update | 200 OK | __ |
| 6. Bad Login | 401 Unauth | __ |
| 7. Bad Password | 400 Bad Req | __ |
| 8. Refresh | 200 OK | __ |
| 9. Logout | 200 OK | __ |
| 10. Mobile UI | Works | __ |

---

## Next Steps

After ALL tests pass:

1. Commit changes: `git add . && git commit -m "feat: Auth system testing complete"`
2. Fill [TESTING_PLAN.md](TESTING_PLAN.md) sign-off section
3. Plan Week 3: Lots Module Implementation
4. Review [ANALYTICS_INTELLIGENCE_ARCHITECTURE.md](ANALYTICS_INTELLIGENCE_ARCHITECTURE.md) for future features

---

**Total Testing Time: ~90 minutes**

**Ready?** Start with Terminal 1 & Terminal 2 above, then come back to this guide for copy-paste commands! 🚀
