# Environment Variables Guide

Complete reference for all environment variables used across the AfriGo platform.

## Overview

Environment variables are organized by service:
- **Backend API** (`backend/.env.local`)
- **Mobile App** (`mobile-app/.env`)
- **DevOps/Deployment** (GitHub Actions secrets)

---

## Backend Environment Variables

### Database Configuration

| Variable | Required | Example | Notes |
|----------|----------|---------|-------|
| `DATABASE_HOST` | Yes | `localhost` | PostgreSQL server hostname |
| `DATABASE_PORT` | Yes | `5432` | PostgreSQL port |
| `DATABASE_USER` | Yes | `afrigo_app` | DB username |
| `DATABASE_PASSWORD` | Yes | `app_password_123` | DB password (change in prod!) |
| `DATABASE_NAME` | Yes | `afrigo_dev` | Database name |
| `DATABASE_URL` | Yes | See below | Full connection string |
| `DATABASE_TEST_URL` | Yes | See below | Test database URL |
| `DATABASE_POOL_SIZE` | No | `20` | Max connections |
| `DATABASE_POOL_IDLE_TIMEOUT` | No | `30` | Idle connection timeout (seconds) |
| `DATABASE_LOG_QUERIES` | No | `false` | Log all queries (dev only!) |

**DATABASE_URL Format:**
```
postgresql://username:password@host:port/database_name
```

**Example:**
```
postgresql://afrigo_app:app_password_123@localhost:5432/afrigo_dev
```

### API & Server Configuration

| Variable | Required | Example | Notes |
|----------|----------|---------|-------|
| `API_PORT` | No | `3000` | Server port |
| `API_HOST` | No | `0.0.0.0` | Bind all interfaces |
| `API_ENV` | No | `development` | Environment (development/staging/production) |
| `API_LOG_LEVEL` | No | `info` | Log level (debug/info/warn/error) |
| `API_RATE_LIMIT` | No | `100` | Requests per minute |
| `CORS_ORIGINS` | Yes | See below | Comma-separated allowed origins |

**CORS_ORIGINS Examples:**
```bash
# Development
CORS_ORIGINS=http://localhost:3000,http://localhost:5173,http://192.168.1.100:5173

# Production
CORS_ORIGINS=https://app.afrigo.io,https://admin.afrigo.io
```

### JWT & Authentication

| Variable | Required | Format | Notes |
|----------|----------|--------|-------|
| `JWT_SECRET` | Yes | 32+ chars | Secret signing key |
| `JWT_EXPIRATION` | No | `24h` | Token lifespan (24h recommended) |
| `JWT_REFRESH_SECRET` | Yes | 32+ chars | Refresh token secret |
| `JWT_REFRESH_EXPIRATION` | No | `7d` | Refresh token lifespan |

**Generate Secure Keys:**
```bash
# Linux/macOS
openssl rand -base64 32

# Node.js
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

### Firebase Configuration

| Variable | Required | Obtains From | Notes |
|----------|----------|-------------|-------|
| `FIREBASE_PROJECT_ID` | Yes | Firebase Console | Project ID |
| `FIREBASE_PRIVATE_KEY` | Yes | Service Account JSON | Multi-line key (escape newlines) |
| `FIREBASE_CLIENT_EMAIL` | Yes | Service Account JSON | Service account email |
| `FIREBASE_DATABASE_URL` | Yes | Realtime Database | Includes protocol and region |
| `FIREBASE_STORAGE_BUCKET` | Yes | Storage settings | Bucket name.appspot.com |
| `FIREBASE_AUTH_ENABLED` | No | Manual | true/false for Auth module |

**Example Service Account JSON:**
```json
{
  "type": "service_account",
  "project_id": "afrigo-dev",
  "private_key_id": "key_id",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----",
  "client_email": "firebase-adminsdk-xyz@afrigo-dev.iam.gserviceaccount.com",
  "client_id": "123456789",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/..."
}
```

**How to add Firebase key to .env:**
```bash
# Replace newlines with \n for single-line format
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKIwggSeAgEAAoIBAQCx...\n-----END PRIVATE KEY-----\n"
```

### AWS S3 Configuration

| Variable | Required | Obtains From | Notes |
|----------|----------|-------------|-------|
| `AWS_REGION` | Yes | AWS Console | e.g., `us-west-2` |
| `AWS_ACCESS_KEY_ID` | Yes | IAM User | Access key ID |
| `AWS_SECRET_ACCESS_KEY` | Yes | IAM User | Secret access key |
| `AWS_S3_BUCKET` | Yes | S3 Bucket name | Bucket name (no https://) |
| `AWS_S3_ACL` | No | Manual | `private` or `public-read` |

**IAM Policy for S3 Bucket:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::afrigo-dev-documents/*"
    }
  ]
}
```

### Flutterwave Payment Configuration

| Variable | Required | Obtains From | Notes |
|----------|----------|-------------|-------|
| `FLUTTERWAVE_PUBLIC_KEY` | Yes | Flutterwave Dashboard | Public key for frontend |
| `FLUTTERWAVE_SECRET_KEY` | Yes | Flutterwave Dashboard | Secret key (backend only!) |
| `FLUTTERWAVE_WEBHOOK_SECRET` | Yes | Flutterwave Dashboard | Webhook signature verification |
| `FLUTTERWAVE_WEBHOOK_URL` | Yes | Manual | Full webhook endpoint URL |

**Example:**
```
FLUTTERWAVE_PUBLIC_KEY=FLWPUBK_TEST_1234567890abcdef123456
FLUTTERWAVE_SECRET_KEY=FLWSECK_TEST_1234567890abcdef123456
FLUTTERWAVE_WEBHOOK_SECRET=whsec_test_1234567890abcdef
FLUTTERWAVE_WEBHOOK_URL=https://api.afrigo.local/webhooks/flutterwave
```

### Sentry Error Monitoring

| Variable | Required | Obtains From | Notes |
|----------|----------|-------------|-------|
| `SENTRY_DSN` | No | Sentry Project settings | Data source name (URL) |
| `SENTRY_ENVIRONMENT` | No | Manual | development/staging/production |
| `SENTRY_TRACES_SAMPLE_RATE` | No | Manual | 0.0-1.0 (sampling rate) |

**Example:**
```
SENTRY_DSN=https://examplePublicKey@o0.ingest.sentry.io/123456
SENTRY_ENVIRONMENT=production
SENTRY_TRACES_SAMPLE_RATE=0.1  # Sample 10% of transactions
```

### Email & SMS Configuration

| Variable | Required | Obtains From | Notes |
|----------|----------|-------------|-------|
| `SENDGRID_API_KEY` | Yes | SendGrid Account | API key from settings |
| `SENDGRID_FROM_EMAIL` | Yes | Manual | Verified sender email |
| `TWILIO_ACCOUNT_SID` | No | Twilio Console | Account SID |
| `TWILIO_AUTH_TOKEN` | No | Twilio Console | Auth token |
| `TWILIO_PHONE_NUMBER` | No | Twilio Console | Verified phone number |

### Monitoring & Logging

| Variable | Required | Example | Notes |
|----------|----------|---------|-------|
| `LOG_FORMAT` | No | `json` | json or text |
| `LOG_LEVEL` | No | `info` | trace/debug/info/warn/error |
| `METRICS_ENABLED` | No | `true` | Enable Prometheus metrics |
| `METRICS_PORT` | No | `9090` | Metrics server port |

---

## Mobile App Environment Variables

### Backend & API Configuration

| Variable | Required | Example | Notes |
|----------|----------|---------|-------|
| `BACKEND_URL` | Yes | `http://localhost:3000` | API server hostname |
| `BACKEND_API_TIMEOUT_MS` | No | `30000` | Request timeout |
| `BACKEND_RETRY_COUNT` | No | `3` | Automatic retry count |

### Firebase Configuration

| Variable | Required | Obtains From | Notes |
|----------|----------|-------------|-------|
| `FIREBASE_PROJECT_ID` | Yes | Firebase Console | Same as backend |
| `FIREBASE_API_KEY` | Yes | Firebase Console | Web API key (different from backend!) |
| `FIREBASE_AUTH_DOMAIN` | Yes | Firebase Console | Auth domain |
| `FIREBASE_DATABASE_URL` | Yes | Firebase Console | Realtime Database URL |
| `FIREBASE_STORAGE_BUCKET` | Yes | Firebase Console | Storage bucket |
| `FIREBASE_MESSAGING_SENDER_ID` | Yes | Firebase Console | Messaging sender ID |
| `FIREBASE_APP_ID` | Yes | Firebase Console | App ID |

### Application Settings

| Variable | Required | Example | Notes |
|----------|----------|---------|-------|
| `APP_NAME` | No | `AfriGo` | App display name |
| `APP_VERSION` | No | `0.1.0` | Semantic version |
| `ENVIRONMENT` | Yes | `development` | development/staging/production |
| `LOG_LEVEL` | No | `info` | Log level |
| `ENABLE_ANALYTICS` | No | `true` | Enable Firebase Analytics |

### Offline & Sync

| Variable | Required | Example | Notes |
|----------|----------|---------|-------|
| `OFFLINE_MODE_ENABLED` | No | `true` | Cache data locally |
| `SYNC_INTERVAL_SECONDS` | No | `60` | Sync every 60 seconds |
| `HIVE_BOX_NAME` | No | `afrigo_app_box` | Local storage box |
| `ENABLE_ENCRYPTION` | No | `true` | Encrypt local storage |

### UI Configuration

| Variable | Required | Example | Notes |
|----------|----------|---------|-------|
| `THEME_MODE` | No | `light` | light/dark/system |
| `ENABLE_ANIMATIONS` | No | `true` | Enable UI animations |
| `ANIMATION_DURATION_MS` | No | `280` | Default animation duration |
| `ENABLE_HAPTIC_FEEDBACK` | No | `true` | Vibration on interaction |

---

## GitHub Actions Secrets

All production credentials are stored as GitHub Secrets (never in .env files).

### Required Secrets

| Secret | Purpose | Example |
|--------|---------|---------|
| `DATABASE_URL_PROD` | Prod database | `postgresql://user:pass@host/db` |
| `JWT_SECRET_PROD` | Production JWT | (32+ char random string) |
| `FIREBASE_PRIVATE_KEY_PROD` | Prod Firebase | (multi-line key) |
| `AWS_ACCESS_KEY_ID` | S3 access | (AWS IAM key) |
| `AWS_SECRET_ACCESS_KEY` | S3 secret | (AWS IAM secret) |
| `FLUTTERWAVE_SECRET_KEY_PROD` | Prod payments | (Flutterwave secret) |
| `SENTRY_DSN` | Error monitoring | (Sentry DSN) |
| `SENDGRID_API_KEY` | Email service | (SendGrid key) |
| `DOCKER_USERNAME` | Docker Hub | (Docker username) |
| `DOCKER_PASSWORD` | Docker Hub | (Docker token) |
| `NETLIFY_AUTH_TOKEN` | Mobile app deploy | (Netlify token) |
| `SLACK_WEBHOOK_URL` | Deployment notifications | (Slack webhook) |

**How to add secrets:**
1. Go to Repository Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Name: `DATABASE_URL_PROD`, Value: `postgresql://...`
4. Save

---

## Environment-Specific Values

### Development
```bash
# .env.local
API_ENV=development
FIREBASE_PROJECT_ID=afrigo-dev
FLUTTERWAVE_PUBLIC_KEY=FLWPUBK_TEST_*  # Test keys
DEBUG_MODE=true
DATABASE_LOG_QUERIES=true
```

### Staging
```bash
# .env.staging
API_ENV=staging
FIREBASE_PROJECT_ID=afrigo-staging
FLUTTERWAVE_PUBLIC_KEY=FLWPUBK_TEST_*  # Still test keys
DEBUG_MODE=false
DATABASE_LOG_QUERIES=false
SENTRY_TRACES_SAMPLE_RATE=0.5
```

### Production
```bash
# .env.production (GitHub Secrets only!)
API_ENV=production
FIREBASE_PROJECT_ID=afrigo-production
FLUTTERWAVE_PUBLIC_KEY=FLWPUBK_LIVE_*  # Live keys!
DEBUG_MODE=false
SENTRY_TRACES_SAMPLE_RATE=0.01
SECURE_SECURE_COOKIES=true
```

---

## Security Best Practices

### ✅ DO
- Store production secrets in GitHub Secrets, not .env files
- Rotate API keys every 90 days
- Use separate test and production Firebase projects
- Keep SQLite/Hive encryption ON in production
- Never commit .env files to git

### ❌ DON'T
- Commit .env.local or .env to git
- Share API keys in Slack or email
- Reuse development credentials in production
- Store secrets in code comments
- Log sensitive values (JWT, API keys)

### .gitignore Rules
```bash
# Never commit
.env
.env.local
.env.*.local
.env.production

# Safe to commit
.env.example
.env.template
```

---

## Validation Checklist

Before deploying:

- [ ] All required variables are set
- [ ] No development values in production config
- [ ] Database connectivity verified
- [ ] Firebase Admin SDK authenticated
- [ ] AWS S3 bucket accessible
- [ ] Flutterwave webhook URL correct
- [ ] Sentry DSN configured
- [ ] SendGrid email verified
- [ ] JWT secrets are 32+ characters
- [ ] CORS origins match actual domains
- [ ] API timeouts appropriate for region

---

## Troubleshooting Missing Variables

### Backend fails to start: "DATABASE_URL not set"
```bash
# Check .env.local exists and has DATABASE_URL
cat backend/.env.local | grep DATABASE_URL

# Add if missing
echo "DATABASE_URL=postgresql://..." >> backend/.env.local
```

### Firebase initialization fails
```bash
# Check FIREBASE_PRIVATE_KEY format
# Should NOT have escaped newlines in console output
cat backend/.env.local | grep FIREBASE_PRIVATE_KEY

# Re-format with proper newlines
export FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nMIIEvAI...\n-----END PRIVATE KEY-----\n"
```

### S3 upload fails: "Access Denied"
```bash
# Verify AWS credentials
aws s3 ls s3://afrigo-dev-documents

# Verify IAM policy is correct
# Should allow s3:PutObject on bucket
```

---

**Last Updated:** January 2025
**Maintained by:** DevOps Team
