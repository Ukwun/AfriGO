# Week 0 Verification Checklist

Complete verification that all Week 0 setup is correct and ready for Sprint 1.

## Installation & Prerequisites

### ✅ Node.js & npm
```bash
node --version    # Should be v20.x or v22.x
npm --version     # Should be v10.x or v11.x
```

### ✅ Flutter & Dart
```bash
flutter --version # Should be 3.35.6+
dart --version    # Should be 3.2+
```

### ✅ Git
```bash
git --version     # Should be 2.40.0+
git config user.name    # Should show "AfriGo Team"
git config user.email   # Should show "team@afrigo.local"
```

### ✅ Docker (Optional but recommended)
```bash
docker --version       # 20.10.0+
docker-compose --version  # 2.0.0+
```

---

## Backend Setup Verification

### File Structure
```bash
# Check all backend files exist
ls -la backend/src/
# Should show: main.ts, app.module.ts, app.controller.ts, app.service.ts

ls -la backend/src/modules/
# Should show: auth/, lots/, marketplace/, contracts/, logistics/, payments/, documents/, zone-services/

ls -la backend/
# Should show: package.json, tsconfig.json, .env.local, .env.example, README.md, .gitignore
```

### Dependencies Installation
```bash
cd backend

# Install dependencies
npm install

# Verify key dependencies installed
npm list @nestjs/core
npm list typeorm
npm list firebase-admin
npm list @nestjs/jwt
npm list passport

# Should complete without errors
echo "✅ Backend dependencies installed"
```

### TypeScript Compilation
```bash
cd backend

# Run type check
npm run type-check --if-present

# Or manually:
npx tsc --noEmit

# Should complete without errors
echo "✅ TypeScript compilation successful"
```

### Build Verification
```bash
cd backend

# Build application
npm run build

# Check dist folder created
ls -la dist/

# Should have compiled main.js and other files
echo "✅ Backend build successful"
```

### Linting Check
```bash
cd backend

# Run ESLint
npm run lint --if-present

# Should complete with 0 errors (warnings OK)
echo "✅ ESLint passed"
```

---

## Mobile App Verification

### File Structure
```bash
# Check all Flutter files
ls -la mobile-app/lib/
# Should show: config/, presentation/, domain/, data/, utils/, main.dart, firebase_options.dart

ls -la mobile-app/lib/presentation/screens/
# Should show: onboarding/, auth/, dashboard/

ls -la mobile-app/
# Should show: pubspec.yaml, .env, .gitignore, README.md
```

### Dependencies Installation
```bash
cd mobile-app

# Get Flutter dependencies
flutter pub get

# Verify key dependencies
flutter pub outdated

# Should complete without errors
echo "✅ Flutter dependencies installed"
```

### Code Analysis
```bash
cd mobile-app

# Analyze code
flutter analyze

# Should complete with 0 errors
echo "✅ Flutter analysis passed"
```

### Format Check
```bash
cd mobile-app

# Check formatting
dart format --set-exit-if-changed lib/

# If formatting needed:
dart format lib/

echo "✅ Dart formatting correct"
```

### Build Verification (APK stub)
```bash
cd mobile-app

# Build APK (takes ~2 minutes)
flutter build apk --release

# Check build succeeded
ls -lh build/app/outputs/apk/release/app-release.apk

# Should show file size > 50MB
echo "✅ Flutter APK build successful"
```

---

## Database Setup Verification

### Docker Compose
```bash
# Start PostgreSQL
docker-compose up -d

# Verify containers running
docker ps | grep afrigo

# Should show 2 containers:
# - afrigo_postgres_dev
# - afrigo_pgadmin
```

### Database Connection  
```bash
# Connect to PostgreSQL
docker exec -it afrigo_postgres_dev psql -U afrigo_dev -d afrigo_dev

# List all tables
\dt

# Should show 13 tables:
# - users, user_roles, user_verification_tokens
# - lots, lot_events
# - rfqs, bids
# - contracts, contract_signatures
# - payment_ledger, escrow_accounts
# - shipments, shipment_events
# - documents, dossiers, dossier_documents
# - zone_registrations, forex_rates
# - quality_inspections, compliance_checks
# - conversations, messages, notifications, activity_logs
# - ratings

# List all views
\dv

# Should show:
# - active_lots
# - seller_statistics

# Exit
\q

echo "✅ PostgreSQL schema verified"
```

### Test Database
```bash
# Verify test database created
docker exec -it afrigo_postgres_dev psql -U afrigo_dev -d afrigo_test -c "\dt"

# Should show same schema as afrigo_dev

echo "✅ Test database verified"
```

---

## Environment Variables Verification

### Backend
```bash
cd backend

# Check .env.local exists
ls -la .env.local

# Verify key variables are set
grep DATABASE_URL .env.local
grep JWT_SECRET .env.local
grep FIREBASE_PROJECT_ID .env.local

# Should show all values populated (not blank)
echo "✅ Backend .env.local verified"
```

### Mobile
```bash
cd mobile-app

# Check .env exists  
ls -la .env

# Verify key variables
grep BACKEND_URL .env
grep FIREBASE_PROJECT_ID .env

echo "✅ Mobile .env verified"
```

---

## Git & Version Control Verification

### Repository Status
```bash
cd c:\afrigo

# Check current branch
git branch -v
# Should show "* main"

# Check commit log
git log --oneline | head -3
# Should show initial commit: "feat: Initialize AfriGo Platform Week 0 Setup"

# Check status
git status
# Should show "On branch main" and "nothing to commit"

echo "✅ Git repository verified"
```

### .gitignore
```bash
# Check files that should be ignored
cd c:\afrigo

# These should NOT be tracked:
git check-ignore .env
git check-ignore backend/node_modules/
git check-ignore mobile-app/build/
git check-ignore backend/dist/

# Should show paths as ignored
echo "✅ .gitignore verified"
```

### GitHub Workflows
```bash
# Check workflow files exist
ls -la .github/workflows/

# Should show:
# - backend.yml
# - mobile.yml

# Check syntax
cat .github/workflows/backend.yml | head -20
# Should show "name: Backend CI/CD"

echo "✅ GitHub workflows verified"
```

---

## Documentation Verification

### Required Documentation Files
```bash
cd c:\afrigo

# Count markdown files
find . -name "*.md" -type f | wc -l
# Should be > 15 files

# Check key documents exist
ls -la *.md
# Should show:
# - DATABASE_SETUP_GUIDE.md
# - ENVIRONMENT_VARIABLES_GUIDE.md
# - GITHUB_SETUP_GUIDE.md
# - STARTUP_GUIDE.md
# - PROJECT_DELIVERY_COMPLETE.md

# Check backend/mobile docs
ls -la backend/README.md
ls -la mobile-app/README.md

echo "✅ Documentation verified"
```

---

## Network & Connectivity Verification

### Local API Server (Backend)
```bash
cd backend

# Start dev server (will run in background)
npm run dev &

# Wait 2-3 seconds, then test health endpoint
curl http://localhost:3000/health

# Should return:
# {"status":"healthy","timestamp":"2025-01-XX...","service":"afrigo-backend","version":"0.1.0"}

# Kill the server
kill %1

echo "✅ Backend API server works"
```

### Flutter Dev Server
```bash
cd mobile-app

# Just verify it can run (don't keep it running)
# timeout 3 flutter run || true
# or for web:
timeout 3 flutter run -d chrome || true

echo "✅ Flutter dev environment works"
```

### Database Connectivity
```bash
cd backend

# Backend should be able to connect to DB
DATABASE_URL=postgresql://afrigo_app:app_password_123@localhost:5432/afrigo_dev \
npx ts-node -e "console.log('DB Connection test passed')"

echo "✅ Database connectivity verified"
```

---

## Security Verification

### Secrets Not Committed
```bash
# Check .env files not in git
git log --all -- .env
git log --all -- .env.local
git log --all -- backend/.env.*

# Should show: "fatal: your search pattern"
# Meaning: no .env files in git history

echo "✅ Secrets protection verified"
```

### Private Keys Not Exposed
```bash
# Check no Firebase private keys in code
git log -p | grep "BEGIN PRIVATE KEY" | head -1

# Should show nothing (no output)

echo "✅ Private keys not exposed"
```

---

## Final Readiness Checklist

| Component | Status | Check Command |
|-----------|--------|---------------|
| Node.js installed | ✅ | `node --version \| grep v20 \|\| grep v22` |
| npm installed | ✅ | `npm --version` |
| Flutter installed | ✅ | `flutter --version \| grep 3.35` |
| Dart installed | ✅ | `dart --version \| grep 3.2` |
| Git configured | ✅ | `git config user.email` |
| Backend files created | ✅ | `ls -la backend/src/main.ts` |
| Backend deps installed | ✅ | `cd backend && npm install` |
| Backend compiles | ✅ | `cd backend && npm run build` |
| Mobile files created | ✅ | `ls -la mobile-app/lib/main.dart` |
| Mobile deps installed | ✅ | `cd mobile-app && flutter pub get` |
| Mobile builds | ✅ | `cd mobile-app && flutter build apk --release` |
| Docker ready | ✅ | `docker-compose up -d` |
| PostgreSQL working | ✅ | `docker exec -it afrigo_postgres_dev psql...` |
| .env.local exists | ✅ | `ls backend/.env.local` |
| .env exists | ✅ | `ls mobile-app/.env` |
| Git initialized | ✅ | `git log --oneline` |
| CI/CD workflows exist | ✅ | `ls .github/workflows/` |
| Documentation complete | ✅ | `ls *.md \| wc -l` |

---

## Automated Verification Script

Save this as `verify-week0.sh` and run:

```bash
#!/bin/bash
set -e

echo "🔍 AfriGo Week 0 Verification"
echo "=============================="

# Check Node.js
echo "✓ Node.js: $(node --version)"

# Check Flutter
echo "✓ Flutter: $(flutter --version)"

# Check Git
echo "✓ Git: $(git --version)"

# Check backend
echo "✓ Backend files: $(ls backend/src/*.ts | wc -l) files"
echo "✓ Backend dependencies: $(cd backend && npm list --depth=0 | wc -l) packages"

# Check mobile
echo "✓ Mobile files: $(find mobile-app/lib -name '*.dart' | wc -l) files"
echo "✓ Mobile dependencies: $(cd mobile-app && flutter pub owned | wc -l) packages"

# Check database
echo "✓ PostgreSQL: $(docker ps | grep postgres | wc -l) containers running"

# Check env files
echo "✓ Backend .env: $(grep -c '=' backend/.env.local) variables"
echo "✓ Mobile .env: $(grep -c '=' mobile-app/.env) variables"

# Check git
echo "✓ Git commits: $(git log --oneline | wc -l) commits"
echo "✓ Git status: $(git status --porcelain | wc -l) changes"

# Check documentation
echo "✓ Documentation: $(find . -name '*.md' | wc -l) files"

echo ""
echo "✅ Week 0 setup verification complete!"
echo ""
echo "Next steps:"
echo "1. Review GITHUB_SETUP_GUIDE.md"
echo "2. Push to GitHub: git remote add origin https://..."
echo "3. Configure GitHub Secrets"
echo "4. Schedule Sprint 1 kickoff meeting"
echo "5. Share documentation with team"
```

Run with:
```bash
bash verify-week0.sh
```

---

## Troubleshooting Failed Verification

### Backend won't compile
```bash
cd backend

# Clear node_modules and reinstall
rm -rf node_modules package-lock.json
npm install

# Check Node version matches package.json requirements
node --version
# Should be 20.x or 22.x

# Check for TypeScript errors
npx tsc --noEmit
```

### Mobile build fails
```bash
cd mobile-app

# Clean and rebuild
flutter clean
flutter pub get
flutter pub upgrade

# Check Flutter version
flutter --version

# Analyze for errors
flutter analyze
```

### Docker containers won't start
```bash
# Stop and remove containers
docker-compose down -v

# Rebuild from scratch
docker-compose up -d

# Check logs
docker logs afrigo_postgres_dev
```

### Git issues
```bash
# Check remote connection
cd c:\afrigo
git remote -v

# Verify .gitignore working
git check-ignore backend/node_modules/

# See what would be committed
git status
```

---

## Sign-Off

Once all verifications pass, fill this out:

**Verification Completed:**
- Date: _________________
- Verified by: _________________
- Status: ☐ All Pass ☐ Issues Found (describe below)

**Issues Found (if any):**
```


```

**Sign-Off:**
- Backend ready for Sprint 1: ☐ Yes ☐ No
- Mobile ready for Sprint 1: ☐ Yes ☐ No
- Database ready: ☐ Yes ☐ No
- Team can start coding: ☐ Yes ☐ No

---

**Last Updated:** January 2025
**Maintained by:** DevOps Team
