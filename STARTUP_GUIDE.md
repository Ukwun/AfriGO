# AfriGo Development - STARTUP GUIDE

> **Status:** 🟢 Ready for Execution  
> **Phase:** 1 (MVP - 14 weeks)  
> **Team Size:** 5-6 engineers  
> **First Sprint:** Sprint 1 (Week 1) - Auth Foundation

---

## 📚 COMPLETE DOCUMENTATION CREATED

All architectural decisions, design systems, and execution plans have been documented:

```
c:\afrigo\
├── project-docs/
│   ├── 01_PRD_SUMMARY.md ..................... Executive overview
│   ├── 02_DATABASE_SCHEMA.md ................. Full PostgreSQL + Firebase schema
│   ├── 03_PHASE1_SPRINT_BREAKDOWN.md ........ 14-week detailed execution plan
│   └── 04_CI_CD_PIPELINE.md ................. GitHub Actions automation
│
├── backend/
│   ├── 01_API_ARCHITECTURE.md ............... NestJS project structure + all endpoints
│   └── (boilerplate to be created)
│
├── mobile-app/
│   ├── 01_PROJECT_STRUCTURE.md .............. Flutter Clean Architecture
│   └── (boilerplate to be created)
│
└── design-system/
    ├── 01_ANIMATION_SYSTEM.md ............... "Alive" animation spec (with Dart code)
    └── 02_DESIGN_TOKENS.md .................. Colors, typography, buttons, spacing
```

---

## 🚀 NEXT STEPS (IMMEDIATE - Week 0)

### **Step 1: Team Kickoff (2 hours)**

**All teams present:**
- [ ] Review PRD_SUMMARY.md (30 min)
- [ ] Walkthrough architecture (20 min)
- [ ] Confirm sprint 1 assignments (10 min)

**Output:** Everyone knows their role

---

### **Step 2: Backend Team Setup (4 hours)**

**Backend Lead + 1-2 engineers:**

```bash
# 1. Create Node.js project structure
cd c:\afrigo\backend
npm init -y
npm install --save-dev typescript ts-node @types/node

# 2. Install NestJS CLI
npm install -g @nestjs/cli
nest new . --package-manager npm

# 3. Install critical dependencies (from API_ARCHITECTURE.md)
npm install \
  @nestjs/core @nestjs/common @nestjs/jwt @nestjs/passport \
  firebase-admin \
  typeorm pg \
  @nestjs/typeorm \
  class-validator class-transformer \
  dotenv \
  joi

npm install --save-dev \
  @types/jest jest \
  @nestjs/testing \
  jest-mock-extended

# 4. Create folder structure (see API_ARCHITECTURE.md)
mkdir -p src/modules/{auth,lots,marketplace,contracts,logistics,payments,documents,zone-services}
mkdir -p src/{common,database,firebase,config}

# 5. Initialize git
git init
git add .
git commit -m "chore: initial NestJS setup"
```

**Deliverable:** Backend folder structure ready, Firebase Admin SDK imported

---

### **Step 3: Mobile Team Setup (4 hours)**

**Mobile Lead + 1-2 engineers:**

```bash
# 1. Create Flutter project
cd c:\afrigo\mobile-app
flutter create . --org com.afrigo --project-name afrigo_app

# 2. Install dependencies (from pubspec.yaml)
flutter pub add \
  riverpod flutter_riverpod \
  go_router \
  dio \
  firebase_core firebase_auth firebase_database firebase_messaging \
  hive hive_flutter shared_preferences \
  flutter_animate \
  formz intl uuid logger

flutter pub add --dev \
  build_runner riverpod_generator json_serializable

# 3. Create folder structure (see PROJECT_STRUCTURE.md)
mkdir -p lib/{config/{routes,theme,constants},data/{datasources,models,repositories}}
mkdir -p lib/{domain/{entities,repositories,usecases}}
mkdir -p lib/{presentation/{providers,screens,widgets/common,widgets/buttons,widgets/forms}}
mkdir -p lib/utils

# 4. Initialize git
git init
git add .
git commit -m "chore: initial Flutter setup"
```

**Deliverable:** Flutter project structure ready, Riverpod configured

---

### **Step 4: Database Setup (2 hours)**

**Database Architect:**

```sql
-- Create PostgreSQL database

CREATE DATABASE afrigo_dev;
CREATE DATABASE afrigo_test;

-- User for app
CREATE USER afrigo_user WITH PASSWORD 'secure_password';
ALTER ROLE afrigo_user CREATEDB;
GRANT ALL PRIVILEGES ON DATABASE afrigo_dev TO afrigo_user;
GRANT ALL PRIVILEGES ON DATABASE afrigo_test TO afrigo_user;
```

**Then:** Run migrations (see 02_DATABASE_SCHEMA.md)

**Deliverable:** PostgreSQL ready, tables created, seeds loaded

---

### **Step 5: Environment Variables Setup (1 hour)**

**Backend (.env.local)**
```env
# Database
DATABASE_URL=postgresql://afrigo_user:password@localhost:5432/afrigo_dev
DATABASE_TEST_URL=postgresql://afrigo_user:password@localhost:5432/afrigo_test

# Firebase
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY_ID=your-key-id
FIREBASE_PRIVATE_KEY=your-key
FIREBASE_CLIENT_EMAIL=your-email
FIREBASE_CLIENT_ID=your-client-id
FIREBASE_AUTH_URI=https://accounts.google.com/o/oauth2/auth
FIREBASE_TOKEN_URI=https://oauth2.googleapis.com/token

# API
NODE_ENV=development
API_PORT=3000
JWT_SECRET=your-very-secure-secret-key
JWT_EXPIRATION_HOURS=1
REFRESH_TOKEN_SECRET=another-secure-secret
REFRESH_TOKEN_EXPIRATION_DAYS=7

# AWS S3 (for document uploads)
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=your-key
AWS_SECRET_ACCESS_KEY=your-secret
S3_BUCKET_NAME=afrigo-documents

# Payment Gateway
FLUTTERWAVE_SANDBOX_KEY=your-sandbox-key
FLUTTERWAVE_SECRET_KEY=your-secret-key
```

**Mobile (.env)**
```env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_APP_ID=your-app-id
API_BASE_URL=http://localhost:3000
API_BASE_URL_PROD=https://api.afrigo.app
LOG_LEVEL=debug
```

**Deliverable:** All environment variables set, no secrets in code

---

### **Step 6: GitHub Setup (1 hour)**

**DevOps Lead:**

```bash
# Create main repo
git init --initial-branch=main
git add -A
git commit -m "feat: initial project structure"

# Push to GitHub
git remote add origin https://github.com/afrigo/afrigo-platform.git
git push -u origin main

# Create develop branch
git checkout -b develop
git push -u origin develop

# Add GitHub Secrets (see 04_CI_CD_PIPELINE.md)
# - DOCKER_USERNAME
# - DOCKER_PASSWORD
# - FIREBASE_SERVICE_ACCOUNT
# - DEPLOY_KEY_STAGING
# - DEPLOY_HOST_STAGING
# - SNYK_TOKEN

# Add GitHub Actions workflows
# Copy .github/workflows/backend.yml
# Copy .github/workflows/mobile.yml

git commit -am "chore: add CI/CD workflows"
git push
```

**Deliverable:** GitHub repo ready, CI/CD pipelines active

---

### **Step 7: Verification Check (30 min)**

**All teams:**

- [ ] Backend compiles without errors
- [ ] Mobile app builds without errors
- [ ] Database migrations run cleanly
- [ ] Environment variables loaded
- [ ] GitHub CI/CD shows green (at least linting passed)
- [ ] All team members can pull latest code

**If everything ✅:** Ready to start Sprint 1!

---

## 📅 SPRINT 1 KICKOFF (Week 1 - Monday)

**Meeting: 9 AM (2 hours)**

### **Agenda:**

1. **Story Walkthrough** (45 min)
   - Backend lead walks through Auth endpoints (20 min)
   - Mobile lead walks through UI screens (20 min)
   - Database architect explains schema (5 min)

2. **Technical Deep Dive** (45 min)
   - Firebase Auth integration walkthrough (15 min)
   - JWT token flow (15 min)
   - API client setup in Flutter (15 min)

3. **Team Assignments** (15 min)
   - Who picks up which story?
   - Dependencies and blockers identified?

4. **Daily Standup Time Lock** (5 min)
   - 9:30 AM daily
   - 15 minutes max

---

## 🎯 SPRINT 1 SUCCESS CRITERIA

By end of Friday (Week 1):

**Backend:**
- [ ] `POST /auth/register` works (create user + org in DB)
- [ ] `POST /auth/login` returns JWT token
- [ ] `POST /auth/refresh` exchanges refresh token for new access token
- [ ] All endpoints have request/response validation
- [ ] Unit tests cover happy path + error cases
- [ ] API docs generated (Swagger)

**Mobile:**
- [ ] Login screen UI complete (design tokens applied)
- [ ] Register screen UI complete
- [ ] API client can hit all 3 endpoints above
- [ ] Loading states visible
- [ ] Error alerts show on failures
- [ ] Tests pass (at least UI tests)

**DevOps:**
- [ ] GitHub Actions backend workflow runs + passes
- [ ] GitHub Actions mobile workflow runs + passes
- [ ] Docker images build successfully

---

## 📊 QUICK REFERENCE DOCS

### **For Backend Engineers:**
- Read: `backend/01_API_ARCHITECTURE.md` (API contracts)
- Read: `project-docs/02_DATABASE_SCHEMA.md` (table structure)
- Reference: `project-docs/01_PRD_SUMMARY.md` (product logic)

### **For Mobile Engineers:**
- Read: `mobile-app/01_PROJECT_STRUCTURE.md` (folder layout)
- Read: `design-system/02_DESIGN_TOKENS.md` (colors, typography)
- Reference: `design-system/01_ANIMATION_SYSTEM.md` (for later sprints)

### **For Database & DevOps:**
- Read: `project-docs/02_DATABASE_SCHEMA.md` (complete schema)
- Read: `project-docs/04_CI_CD_PIPELINE.md` (deployment automation)

### **For Product Manager:**
- Read: `project-docs/01_PRD_SUMMARY.md` (exec overview)
- Read: `project-docs/03_PHASE1_SPRINT_BREAKDOWN.md` (timeline)

---

## 🔥 CRITICAL SUCCESS FACTORS

1. **Architecture adherence** - Follow Clean Architecture (backend) and Clean Architecture (mobile) exactly
2. **Animation quality** - Timeline animations are CORE competitive advantage (Sprint 5)
3. **Real-time foundation** - Firebase Realtime setup correctly early
4. **Database integrity** - Immutable event logs (CRITICAL for lot traceability)
5. **Test coverage** - Aim for 80%+ from day 1
6. **Performance** - APIs < 300ms, 60 FPS animations

---

## 📞 SUPPORT & ESCALATION

**Daily Questions?**
→ Post in Slack #afrigo-dev

**Architecture Questions?**
→ Tag @backend-lead or @mobile-lead

**Blockers?**
→ Mention in standup, escalate if > 2 hours

**Design/Animation Questions?**
→ Check design-system/ docs first, then ask

---

## 🎬 ANIMATION IMPLEMENTATION (Sprint 5 Focus)

**Don't leave this for later.** Start experimenting in Sprint 1:

```dart
// Quick test in mobile app (Week 1)
// lib/presentation/widgets/animations/test_animation.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TestAnimation extends StatefulWidget {
  @override
  State<TestAnimation> createState() => _TestAnimationState();
}

class _TestAnimationState extends State<TestAnimation> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF10B981),
        ),
      )
          .fadeIn(duration: 280.ms, curve: Curves.easeOutCubic)
          .moveUp(duration: 280.ms, begin: 16),
    );
  }
}
```

Test this. Get comfortable with animation patterns early.

---

## ⏭️ AFTER WEEK 0 SETUP

**Sprint 1 starts Monday.**

Team should be shipping:
- Auth endpoints ✅
- KYC document upload form ✅
- Login/Register UI ✅
- Tests ✅

**By end of Sprint 1:** Users can register, verify OTP, see dashboard.

---

## 📞 QUICK LINKS

```
PRD Summary ........................ project-docs/01_PRD_SUMMARY.md
Database Schema .................... project-docs/02_DATABASE_SCHEMA.md
Sprint Breakdown ................... project-docs/03_PHASE1_SPRINT_BREAKDOWN.md
CI/CD Setup ....................... project-docs/04_CI_CD_PIPELINE.md
API Architecture ................... backend/01_API_ARCHITECTURE.md
Flutter Structure .................. mobile-app/01_PROJECT_STRUCTURE.md
Animation System ................... design-system/01_ANIMATION_SYSTEM.md
Design Tokens ...................... design-system/02_DESIGN_TOKENS.md
```

---

## ✅ WEEK 0 COMPLETION CHECKLIST

- [ ] All team members read PRD_SUMMARY.md
- [ ] Backend project initialized + dependencies installed
- [ ] Mobile project initialized + dependencies installed
- [ ] PostgreSQL database created + tables migrated
- [ ] Environment variables configured (both backend + mobile)
- [ ] GitHub repository created + CI/CD workflows added
- [ ] First commit pushed (all workflows passing)
- [ ] Sprint 1 stories created in issue tracker
- [ ] Team kickoff meeting scheduled (Monday 9 AM)
- [ ] Daily standup time locked (9:30 AM)
- [ ] Slack channels created (#afrigo-dev, #afrigo-standup)

**Once all ✅ → Sprint 1 kicks off Monday!**

---

## 🎯 THE GOAL

By end of Week 14:
- ✅ 50,000+ users can authenticate
- ✅ Millions of real live trade events tracked immutably
- ✅ Contracts signed digitally
- ✅ Payments escrowed securely
- ✅ Shipments tracked in real-time
- ✅ Export dossiers generated automatically
- ✅ System handles thousands of concurrent users
- ✅ All animations smooth at 60 FPS
- ✅ Production-grade reliability

**This isn't a prototype. This is a real platform for real people.**

Let's build it. 🚀

