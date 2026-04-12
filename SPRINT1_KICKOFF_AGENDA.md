# Sprint 1 Kickoff Meeting - Monday 9:00 AM

Complete agenda and instructions for kicking off the first sprint.

---

## Pre-Meeting (Friday)

### Send Team Email

```
Subject: Sprint 1 Kicks Off Monday 9 AM 🚀

Hi Team,

Hope you had a great weekend! The AfriGo Platform backend and mobile foundations are ready, and we're starting Sprint 1 on Monday.

📋 Please Review:
1. DATABASE_SETUP_GUIDE.md — How to run PostgreSQL locally
2. GITHUB_SETUP_GUIDE.md — How to set up GitHub access
3. WEEK0_VERIFICATION_CHECKLIST.md — Verify your environment
4. ENVIRONMENT_VARIABLES_GUIDE.md — Understand all config vars

🎯 By Monday Morning:
- Install Node.js 20+ ✓
- Install Flutter 3.35.6+ ✓
- Install Docker & Docker Compose ✓
- Clone the repository (link will be shared Friday EOD) ✓
- Run: npm install (backend) + flutter pub get (mobile) ✓
- Verify everything compiles ✓

⏰ Monday 9:00 AM: Sprint 1 Kickoff (30 minutes)
⏰ Daily Standup: 9:30 AM every weekday (15 minutes)

Questions? Slack me before Friday EOD.

Excited to ship this together! 🌍

[Your Name]
```

---

## Meeting Agenda (9:00 AM - 9:30 AM)

### Part 1: Overview (5 min)

**Facilitator speaks:**

> "Good morning, team! Welcome to AfriGo Sprint 1. In the next two weeks, we're building authentication, KYC verification, and the first iteration of the lot listing system.
>
> This is a well-architected platform:
> - Clean Architecture on the mobile side
> - Microservices-ready NestJS backend
> - PostgreSQL for ACID compliance
> - Firebase for real-time sync
>
> Week 0 setup is complete. You all have:
> - Backend boilerplate in place
> - Mobile Clean Architecture template
> - Docker PostgreSQL ready
> - CI/CD pipelines configured
>
> Your job in Sprint 1: Implement features, not infrastructure. Lean on the architecture we've set up."

### Part 2: Architecture Overview (8 min)

**Show code snippets & explain:**

1. **Backend (NestJS):**
   ```typescript
   // src/modules/auth/auth.service.ts
   // - JWT token generation
   // - Firebase Auth integration
   // - Password hashing with Bcrypt
   ```
   
   *"The auth module follows NestJS best practices. You'll implement provider methods; middleware is ready."*

2. **Mobile (Flutter):**
   ```dart
   // lib/presentation/screens/auth/login_screen.dart
   // - Go Router navigation
   // - Riverpod state management
   // - Firebase integration
   ```
   
   *"Mobile uses Clean Architecture. Presentation is separated from logic. Firebase Auth is pre-configured."*

3. **Database (PostgreSQL):**
   ```sql
   -- migrations/001-schema.sql
   -- 13 tables, all relationships defined
   -- Indexes optimized for common queries
   ```
   
   *"Database is ready. Run migrations with Docker. You don't need to create schema; it's automated."*

### Part 3: Sprint 1 Goals (5 min)

**Share this checklist:**

```
Sprint 1 Goals (Jan 13 - Jan 24)

📱 Mobile:
  ☐ Week 1:
    ✓ Auth screens (login, register, forgot password)
    ✓ Firebase Auth integration (email/phone OTP)
    ✓ User profile screen with KYC upload
    ✓ Local storage (Hive) for offline support
  
  ☐ Week 2:
    ✓ KYC verification flow with document upload
    ✓ Dashboard switcher (buyer/seller view)
    ✓ Real-time auth state management (Riverpod)
    ✓ Error handling & retries (mobile-specific)

🔧 Backend:
  ☐ Week 1:
    ✓ Auth module (registration, login, email verification)
    ✓ JWT token generation & refresh
    ✓ KYC service (document upload to S3)
    ✓ User repository & database queries
    ✓ API tests (unit + integration)
  
  ☐ Week 2:
    ✓ Lots module (READ: get lots, search, filter)
    ✓ Lot events (immutable audit log)
    ✓ Dashboard API (stats, recent activity)
    ✓ Sentry error tracking
    ✓ Email notifications (SendGrid)
    ✓ Docker build & registry push

DevOps:
  ☐ Week 1:
    ✓ Set up staging server (AWS or DigitalOcean)
    ✓ Configure GitHub secrets
    ✓ Test CI/CD pipelines locally
  
  ☐ Week 2:
    ✓ Set up database backups
    ✓ Configure monitoring (Sentry, CloudWatch)
    ✓ Deploy to staging automatically
```

**"By Friday next week (Jan 17), we want:**
- **Mobile:** Auth fully working, can log in with email
- **Backend:** Auth API endpoints tested, JWT tokens working
- **Database:** Migrations applied, user table populated with test data

**By Friday Jan 24 (end of Sprint 1):**
- **Mobile:** Can log in, see KYC upload screen
- **Backend:** Can manage users, verify KYC documents
- **Deployed:** Staging deployment working end-to-end"

### Part 4: Technical Setup (5 min)

**Walk through checklist:**

```bash
# 1. Clone repository (will send link after this meeting)
git clone https://github.com/YOUR_ORG/afrigo.git
cd afrigo

# 2. Backend setup
cd backend
npm install
cp .env.example .env.local
# [Engineer fills in DATABASE_URL and JWT_SECRET keys]
npm run dev

# 3. Mobile setup (in another terminal)
cd mobile-app
flutter pub get
flutter run -d chrome  # Start web for testing
# or
flutter run  # Start on connected Android device

# 4. Database setup
docker-compose up -d
# Migrations run automatically on startup

# Everything should be compiling and showing no errors
```

**"If anything breaks during setup, post in #afrigo-dev Slack. DevOps will help.*"

### Part 5: Daily Standup Format (2 min)

**"Every day at 9:30 AM for 15 minutes:**

Each person answers 3 questions:
1. ✅ What did I complete yesterday?
2. 🔄 What am I working on today?
3. 🚧 What's blocking me?

Format: Slack thread or in-person (5 people, max 3 min each).

**No long discussions in standup.** Blocking issues → separate meeting after standup.

**Standup time is sacred.** No skipping. Calendar invite will be sent after this meeting."

### Part 6: Success Metrics & Definition of Done (3 min)

**"Here's what 'Done' means:**

For each task:
- ☑️ Code written & peer-reviewed
- ☑️ Unit tests pass (80%+ coverage)
- ☑️ Integrated into main branch
- ☑️ Deployed to staging
- ☑️ Works on mobile AND backend end-to-end
- ☑️ No Sentry errors
- ☑️ Documented (code comments, API docs)

For each day:
- ☑️ Show up to standup
- ☑️ Update Jira/GitHub issues (your status)
- ☑️ Commit & push daily (no 10K-line PRs)
- ☑️ Code review others' PRs same day

We're moving fast but not carelessly. Quality + speed."

### Part 7: Q&A (2 min)

**"Questions before we start?"**

Common answers:
- **"Can I use TypeScript on mobile?"** No, Dart only. But it's very type-safe.
- **"Do I need to understand Firebase?"** Not fully yet. We're using basic Auth + DB. Advanced stuff is Week 2+.
- **"What if I disagree with the architecture?"** Write it down. We can refactor after launch, not during.
- **"How often do we deploy?"** Every Friday to staging. Production after epic reviews.

---

## Post-Meeting (Immediate)

### 1. Send Welcome Slack Message

```
🚀 Sprint 1 Starts Now!

Hi @channel,

Welcome to the first sprint of AfriGo Platform. Here's what you need to know:

📚 Documentation:
- Database Setup: DATABASE_SETUP_GUIDE.md
- Environment Variables: ENVIRONMENT_VARIABLES_GUIDE.md
- GitHub: GITHUB_SETUP_GUIDE.md
- Verification: WEEK0_VERIFICATION_CHECKLIST.md

🎯 Sprint Goals: [Link to Sprint 1 Stories]

💻 Tech Stack:
- Backend: NestJS + TypeScript + PostgreSQL
- Mobile: Flutter + Dart + Riverpod
- Database: Docker PostgreSQL (run locally)
- CI/CD: GitHub Actions (auto-deploy to staging)

⏰ Standup: Tomorrow 9:30 AM daily
📍 Location: [Slack thread or Zoom link]

❓ Questions? Ask in #afrigo-dev

Let's ship! 🌍
```

### 2. Assign Sprint 1 Stories

Go to GitHub/Jira and assign stories to team members:

**Backend:**
1. [FEAT] User registration & email verification (Backend Lead)
2. [FEAT] Login with JWT token (Backend Lead)
3. [FEAT] KYC document upload to S3 (Backend)
4. [FEAT] User profile GET/UPDATE endpoints (Backend)
5. [TEST] Auth unit tests (Backend)
6. [TEST] Auth integration tests with DB (Backend)
7. [DEVOPS] CI/CD pipeline for backend (DevOps)

**Mobile:**
1. [FEAT] Login screen UI + validation (Mobile Lead)
2. [FEAT] Register screen UI + validation (Mobile)
3. [FEAT] Firebase Auth integration (Mobile)
4. [FEAT] KYC document upload flow (Mobile)
5. [FEAT] Local storage with Hive (Mobile)
6. [FEAT] Auth state management (Riverpod) (Mobile)
7. [TEST] Auth integration tests (Mobile)
8. [DEVOPS] CI/CD pipeline for mobile (DevOps)

### 3. Create GitHub Milestones

```
Milestone: Sprint 1 (Jan 13 - Jan 24)
Due Date: Friday, Jan 24, 2025
Description: Auth module + KYC verification foundation
```

### 4. Schedule Daily Standups

- **Time:** 9:30 AM every weekday
- **Duration:** 15 minutes
- **Format:** Slack thread with custom emoji (📍 for blocking, 🟢 for done, 🟡 for in-progress)
- **Calendar invite:** Send to all engineers

### 5. Create Slack Channels

```
#afrigo-dev           — Engineering discussion
#afrigo-standup       — Daily standup thread
#afrigo-deploys       — Automatic deploy notifications
#afrigo-issues        — Sentry error alerts
#afrigo-random        — Off-topic chat
```

---

## First Week Milestones

### End of Monday (Jan 13)
✓ Everyone has repo cloned
✓ Backend running locally: `npm run dev`
✓ Mobile building locally: `flutter run`
✓ Database running in Docker
✓ First story assigned and started

### End of Tuesday (Jan 14)
✓ First PRs submitted (from feature branches)
✓ Code review started
✓ First CI/CD runs on GitHub Actions

### End of Wednesday (Jan 15)
✓ First features merged to `develop` branch
✓ Deployed to staging automatically
✓ Testing in Slack: "✅ auth working on staging"

### End of Friday (Jan 17)
✓ Mid-sprint demo (optional): Show working auth
✓ Retro: What's working? What's not?
✓ Plan Week 2: Any architecture changes needed?

---

## Team Contacts & Escalation

| Role | Name | Slack | Email |
|------|------|-------|-------|
| Product Lead | — | @pm | pm@afrigo.io |
| Backend Lead | — | @backend | backend@afrigo.io |
| Mobile Lead | — | @mobile | mobile@afrigo.io |
| DevOps Lead | — | @devops | devops@afrigo.io |

**Escalation:**
- Architecture question? → Backend Lead
- Design question? → Product Lead
- DevOps/deployment issue? → DevOps Lead
- Urgent blocker? → Slack @here or schedule call

---

## Working Agreement

### Core Hours
- **9:00 AM - 5:00 PM** (your timezone)
- Standup at 9:30 AM is mandatory
- Async for code review (until next morning)

### Communication
- **Slack:** For quick questions (<5 min)
- **PRs:** For code discussion
- **Video calls:** For complex discussions (schedule in Slack first)
- **GitHub issues:** For tracked "to-dos"

### Code Quality
- No merging without 1 code review
- All tests must pass
- No committing to `main` directly (only via PR)
- Rebase before merging (no merge commits)

### Deployment
- **Staging:** Automatic on every push to `develop`
- **Production:** Manual, requires 2 approvals
- **Rollback:** DevOps can revert last deploy immediately

---

## Launch Timeline (Reminder)

```
Sprint 1 (Jan 13-24):   Auth + KYC foundation
Sprint 2 (Jan 27-Feb 7): Lots + Marketplace features
Sprint 3 (Feb 10-Feb 21): Contracts + E-signatures
Sprint 4 (Feb 24-Mar 7):  Payments + Escrow
Sprint 5 (Mar 10-Mar 21): Logistics + Tracking
Sprint 6 (Mar 24-Apr 4):  Polish + Performance

April 7: 🚀 LAUNCH
```

---

## Resources

| Resource | Link/Contact |
|----------|-------------|
| GitHub Repository | [Will send after kickoff] |
| Figma Designs | [Will send after kickoff] |
| JIRA Board | [Will send after kickoff] |
| Slack Workspace | #afrigo-dev |
| Architecture Docs | `project-docs/*.md` |
| Database Docs | `DATABASE_SETUP_GUIDE.md` |
| API Docs | `backend/01_API_ARCHITECTURE.md` |

---

## Closing Words

> "We're building something special here. A platform that will transform trade across Africa.
>
> The foundation is solid. The architecture is clean. The requirements are clear.
>
> Now it's up to us to execute.
>
> I believe in this team. You were chosen specifically for these roles. You each bring something critical.
>
> Let's ship an amazing product. Let's support each other. Let's celebrate the wins.
>
> Questions? Let's get to work.
>
> Welcome to Sprint 1. 🚀"

---

**Meeting recorded?** Share recording link in Slack
**Notes needed?** Update this doc with outcomes
**Feedback?** Anonymous survey after Sprint 1

---

**Last Updated:** January 2025
**Prepared by:** [Your Name], Product Lead
