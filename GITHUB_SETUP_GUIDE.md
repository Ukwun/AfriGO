# GitHub Repository Setup Guide

Complete instructions for pushing the AfriGo platform to GitHub and configuring CI/CD.

## Prerequisites

- GitHub account with organization (or personal account)
- Git installed (`git --version`)
- GitHub CLI (optional but recommended)
- Repository already created on GitHub

## Quick Setup (5 minutes)

### Step 1: Create Repository on GitHub

1. Go to https://github.com/new
2. **Repository name:** `afrigo` (or `afrigo-platform`)
3. **Description:** "Pan-African Digital Trade Operating System"
4. **Visibility:** Private (for now; make public at launch)
5. **Initialize:** Uncheck "Add a README" (we have one)
6. **Click:** "Create repository"

### Step 2: Add Remote & Push

```bash
cd c:\afrigo

# Add GitHub remote
git remote add origin https://github.com/YOUR_ORG/afrigo.git

# Rename branch if needed (GitHub defaults to 'main')
git branch -M main

# Push initial commit
git push -u origin main
```

### Step 3: Create `develop` Branch

```bash
# Create develop branch locally
git checkout -b develop

# Push to GitHub
git push -u origin develop
```

### Step 4: Protect Main Branch

1. Go to GitHub repository → Settings → Branches
2. **Add rule** for `main`:
   - ✅ Require pull request reviews (1 minimum)
   - ✅ Require status checks to pass before merging
   - ✅ Require branches to be up to date
   - ✅ Require code reviews from code owners
   - ✅ Dismiss stale pull request approvals
   - ✅ Restrict who can push to matching branches

3. **Add rule** for `develop` (same as above, but less strict):
   - ✅ Require pull request reviews (1 minimum)
   - ☐ Don't require status checks (optional for faster dev)

---

## Configure GitHub Secrets

Go to **Settings → Secrets and variables → Actions** and add these secrets:

### Database Secrets

| Secret | Value | Notes |
|--------|-------|-------|
| `DATABASE_URL_PROD` | `postgresql://user:pass@prod-db:5432/afrigo_prod` | Production database URL |
| `DATABASE_URL_STAGING` | `postgresql://user:pass@staging-db:5432/afrigo_staging` | Staging database |

### JWT Secrets

| Secret | Value | Generate With |
|--------|-------|---|
| `JWT_SECRET_PROD` | 32+ char random string | `openssl rand -base64 32` |
| `JWT_SECRET_STAGING` | 32+ char random string | `openssl rand -base64 32` |

### Firebase Credentials

| Secret | Obtain From |
|--------|-------------|
| `FIREBASE_PRIVATE_KEY_PROD` | Firebase Console → Service Accounts → Private key |
| `FIREBASE_PRIVATE_KEY_STAGING` | Firebase Console → Service Accounts → Private key |

**Format private key properly:**
```bash
# Firebase gives multi-line key, convert to single line
# Replace actual newlines with \n

# Example:
-----BEGIN PRIVATE KEY-----
MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKIwggSeAgEAAoIBAQC...
...
-----END PRIVATE KEY-----

# Becomes:
-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKIwggSeAgEAAoIBAQC...\n-----END PRIVATE KEY-----\n
```

### AWS S3 Secrets

| Secret | Obtain From | Notes |
|--------|-------------|-------|
| `AWS_ACCESS_KEY_ID` | AWS IAM → Users → Your User → Security credentials | Create new access key if needed |
| `AWS_SECRET_ACCESS_KEY` | AWS IAM → Users → Your User → Security credentials | Only shown once; save securely |
| `AWS_REGION` | Manual | e.g., `us-west-2` |
| `AWS_S3_BUCKET_PROD` | AWS S3 → Bucket name | e.g., `afrigo-prod-documents` |

### Payment Secrets

| Secret | Obtain From |
|--------|-------------|
| `FLUTTERWAVE_SECRET_KEY_PROD` | Flutterwave Dashboard → Settings → API keys |
| `FLUTTERWAVE_PUBLIC_KEY_PROD` | Flutterwave Dashboard → Settings → API keys |
| `FLUTTERWAVE_WEBHOOK_SECRET` | Flutterwave Dashboard → Webhooks → Secret |

### Monitoring & Logging

| Secret | Obtain From | Purpose |
|--------|-------------|---------|
| `SENTRY_DSN` | Sentry → Project settings | Error tracking |
| `SENDGRID_API_KEY` | SendGrid → API Keys | Email service |

### Docker Hub

| Secret | Obtain From | Purpose |
|--------|-------------|---------|
| `DOCKER_USERNAME` | Docker Hub account | Push images to registry |
| `DOCKER_PASSWORD` | Docker Hub account | Token or password |

### Deployment Credentials

| Secret | Value | Purpose |
|--------|-------|---------|
| `DEPLOY_KEY_STAGING` | SSH private key | Deploy to staging server |
| `DEPLOY_KEY_PROD` | SSH private key | Deploy to production server |
| `DEPLOY_HOST_STAGING` | `staging-api.afrigo.io` | Staging server hostname |
| `DEPLOY_HOST_PROD` | `api.afrigo.io` | Production server hostname |

### Firebase Distribution (Mobile Beta)

| Secret | Obtain From | Purpose |
|--------|-------------|---------|
| `FIREBASE_SERVICE_ACCOUNT_JSON` | Firebase Console → Service Accounts → Generate new private key | Deploy to beta testers |
| `FIREBASE_ANDROID_APP_ID` | Firebase Console → Project settings → Android app ID | Identify which app to deploy |

### Web Deployment (Netlify)

| Secret | Obtain From | Purpose |
|--------|-------------|---------|
| `NETLIFY_AUTH_TOKEN_STAGING` | Netlify → User settings → Tokens → New personal token | Deploy staging build |
| `NETLIFY_AUTH_TOKEN_PROD` | Netlify → User settings → Tokens → New personal token | Deploy production build |
| `NETLIFY_SITE_ID_STAGING` | Netlify → Site settings → API ID | Staging site ID |
| `NETLIFY_SITE_ID_PROD` | Netlify → Site settings → API ID | Production site ID |

### Notifications

| Secret | Obtain From | Purpose |
|--------|-------------|---------|
| `SLACK_WEBHOOK_URL` | Slack → Custom Integrations → Incoming Webhooks | CI/CD notifications |

### Security Scanning

| Secret | Obtain From | Purpose |
|--------|-------------|---------|
| `SNYK_TOKEN` | Snyk → Account settings → Authentication Token | Vulnerability scanning |

---

## Add Secrets in Bulk (CLI)

```bash
# Install GitHub CLI
# https://cli.github.com/

# Login to GitHub
gh auth login

# Add secrets (example)
gh secret set DATABASE_URL_PROD --body "postgresql://..."
gh secret set JWT_SECRET_PROD --body "super_secret_32_chars_here"
gh secret set FIREBASE_PRIVATE_KEY_PROD --body "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
```

---

## Verify CI/CD Workflows

### Check Workflow Status

1. Go to GitHub repository → Actions
2. You should see two workflow files:
   - ✅ `backend.yml` (Backend CI/CD)
   - ✅ `mobile.yml` (Mobile CI/CD)

### Manual Trigger (Test)

```bash
# Trigger backend workflow
git commit --allow-empty -m "test: CI/CD workflow"
git push origin main
```

Then watch https://github.com/YOUR_ORG/afrigo/actions

---

## Branch Protection Rules

### `main` Branch
- Requires pull request reviews: ✅ 2 reviewers
- Requires status checks: ✅ Backend tests + Mobile tests
- Requires branches to be up to date: ✅
- Requires code review from code owners: ✅

### `develop` Branch
- Requires pull request reviews: ✅ 1 reviewer
- Requires status checks: ✅ Backend linting (optional tests)
- Auto-merge enabled: ✅ (for weekly releases)

---

## Team Access Levels

| Role | Permission Level |
|------|------------------|
| Backend Engineer | Write (can merge to develop, PR to main) |
| Mobile Engineer | Write (can merge to develop, PR to main) |
| DevOps Engineer | Admin (can merge to main, manage secrets) |
| Product Manager | Maintain (can review PRs, see deployments) |

---

## Deployment Strategy

### Development (Local)
```bash
git checkout develop
git pull origin develop
# Make changes, test locally
npm run dev  # backend
flutter run  # mobile
```

### Staging (Auto on develop)
```bash
git push origin develop
# GitHub Actions automatically:
# - Runs tests
# - Builds Docker image
# - Deploys to staging server
# - Notifies Slack
```

### Production (Manual on main)
```bash
git checkout main
git pull origin main
git merge develop  # or create PR first
git push origin main
# GitHub Actions automatically:
# - Runs comprehensive tests
# - Builds production Docker image
# - Deploys to production (with approval)
# - Notifies team on Slack
```

---

## Common Commands

### Daily Development
```bash
# Clone repository
git clone https://github.com/YOUR_ORG/afrigo.git
cd afrigo

# Create feature branch
git checkout develop
git pull origin develop
git checkout -b feat/your-feature

# Make changes, commit
git add .
git commit -m "feat: description of feature"
git push origin feat/your-feature

# Create pull request on GitHub
# → Request review from team
# → Address feedback
# → GitHub Actions tests automatically
# → Merge when approved
```

### Release to Production
```bash
# Create release on main
git checkout main
git pull origin main
git merge develop  # or create PR first

# Tag version
git tag v0.1.0
git push origin main --tags

# GitHub Actions deploys automatically
```

---

## Troubleshooting

### Issue: "Permission denied (publickey)"

**Solution:**
```bash
# Generate SSH key if you don't have one
ssh-keygen -t ed25519 -C "your.email@example.com"

# Add to GitHub: Settings → SSH Keys → New SSH key
cat ~/.ssh/id_ed25519.pub

# Use SSH remote instead of HTTPS
git remote set-url origin git@github.com:YOUR_ORG/afrigo.git
```

### Issue: "fatal: 'origin' does not appear to be a 'git' repository"

**Solution:**
```bash
# Check remotes
git remote -v

# Add remote if missing
git remote add origin https://github.com/YOUR_ORG/afrigo.git
```

### Issue: Workflows not running

**Solution:**
1. Check GitHub Actions are enabled: Settings → Actions → Allow all actions
2. Verify `.github/workflows/` files are properly committed
3. Check workflow syntax: `git show HEAD:.github/workflows/backend.yml`
4. Manually trigger: Actions tab → Select workflow → Run workflow

### Issue: "Secret is not available in GitHub Actions context"

**Solution:**
1. Verify secret name (case-sensitive)
2. Use correct syntax: `${{ secrets.SECRET_NAME }}`
3. Secret must be set in the same repository
4. Secrets don't show in logs; check Actions output carefully

---

## Next Steps

1. **Update Team:** Send repository URL to backend/mobile engineers
2. **Configure environment file** for each engineer:
   - Copy `.env.local.example` to `.env.local`
   - Fill in development values locally
3. **Schedule standup:** Daily 9:30 AM (Monday start)
4. **First PR:** Have each engineer add themselves to `CONTRIBUTORS.md`

---

## Repository Structure

```
afrigo/
├── backend/
│   ├── src/
│   ├── package.json
│   ├── tsconfig.json
│   └── README.md
├── mobile-app/
│   ├── lib/
│   ├── pubspec.yaml
│   └── README.md
├── design-system/
│   ├── 01_ANIMATION_SYSTEM.md
│   └── 02_DESIGN_TOKENS.md
├── project-docs/
│   ├── 01_PRD_SUMMARY.md
│   ├── 02_DATABASE_SCHEMA.md
│   ├── 03_PHASE1_SPRINT_BREAKDOWN.md
│   └── 04_CI_CD_PIPELINE.md
├── migrations/
│   └── 001-schema.sql
├── .github/
│   └── workflows/
│       ├── backend.yml
│       └── mobile.yml
├── docker-compose.yml
├── DATABASE_SETUP_GUIDE.md
├── ENVIRONMENT_VARIABLES_GUIDE.md
└── README.md
```

---

**Last Updated:** January 2025
**Maintained by:** DevOps Team
