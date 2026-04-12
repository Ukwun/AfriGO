# AfriGo Staging Deployment Guide

## Overview

This guide covers deploying the AfriGo agricultural marketplace to a staging environment. The staging environment allows for comprehensive testing before production launch.

## Project Status

- **Overall Completion:** 83% (10/12 todos completed)
- **Modules Completed:** 
  - ✅ Authentication (Email/Password, JWT, Role-based access)
  - ✅ Lots Management (Create, List, Search, Filters)
  - ✅ Trading System (Offers, Quotes, Order Management)
  - ✅ Messaging System (Real-time chat, Conversations)
  - ✅ Payment Integration (Stripe, Escrow, Refunds)
  - ✅ Dashboard & Analytics (20+ metrics)
  - ✅ Admin Panel
  - ✅ Search & Filtering

- **Remaining:** Staging Deployment & Production Testing

## Architecture Overview

### Backend Stack
- **Framework:** NestJS 10 with TypeScript
- **Database:** PostgreSQL with TypeORM migrations
- **Cache:** Redis (optional, for session/cache)
- **Queue:** Bull (for async jobs - email, notifications)
- **Storage:** AWS S3 (for images)
- **Authentication:** JWT with refresh tokens
- **Payments:** Stripe (PCI-safe)
- **Monitoring:** Sentry for error tracking

### Frontend (Mobile)
- **Framework:** Flutter 3.x with Dart
- **State Management:** Riverpod
- **HTTP Client:** Dio with JWT interceptors
- **Routing:** GoRouter

### Deployment Platform
- **Backend:** Docker + Docker Compose
- **Database:** PostgreSQL container
- **Frontend:** Google Play Store (later) / TestFlight
- **Environment:** AWS EC2 or Heroku

## Pre-Staging Checklist

### Backend

- [ ] Environment variables configured (see `.env.staging`)
- [ ] Database migrations tested locally
- [ ] Stripe webhook endpoints configured
- [ ] All API endpoints documented
- [ ] Error logging configured with Sentry
- [ ] CORS properly configured
- [ ] Rate limiting implemented
- [ ] JWT secret keys generated
- [ ] Database backups strategy in place
- [ ] API documentation generated (Swagger/OpenAPI)

### Mobile

- [ ] Android APK built and tested
- [ ] iOS IPA built and tested
- [ ] API endpoints point to staging server
- [ ] JWT token refresh working reliably
- [ ] Error handling and offline mode working
- [ ] Images loading correctly
- [ ] Push notifications configured
- [ ] Analytics events tracking

### Infrastructure

- [ ] Docker images built
- [ ] Docker Compose configuration ready
- [ ] Database initialization scripts prepared
- [ ] SSL/TLS certificates obtained
- [ ] Domain DNS configured
- [ ] Logging and monitoring set up
- [ ] Backup strategy documented
- [ ] Disaster recovery plan

## Step 1: Environment Setup

### Create Staging Environment File

```bash
# backend/.env.staging
NODE_ENV=staging
PORT=3000
DATABASE_HOST=postgres
DATABASE_PORT=5432
DATABASE_NAME=afrigo_staging
DATABASE_USER=afrigo_user
DATABASE_PASSWORD=secure_password_here
JWT_SECRET=your_jwt_secret_key_here
JWT_REFRESH_SECRET=your_refresh_secret_here
STRIPE_SECRET_KEY=sk_test_your_key
STRIPE_PUBLISHABLE_KEY=pk_test_your_key
STRIPE_WEBHOOK_SECRET=whsec_your_secret
SENTRY_DSN=your_sentry_dsn
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
AWS_S3_BUCKET=afrigo-staging
REDIS_HOST=redis
REDIS_PORT=6379
MAIL_HOST=smtp.sendgrid.net
MAIL_USER=apikey
MAIL_PASSWORD=your_sendgrid_api_key
MAIL_FROM=noreply@staging.afrigo.com
LOG_LEVEL=info
```

## Step 2: Docker Setup

### Create Dockerfile for Backend

```dockerfile
# backend/Dockerfile
FROM node:18-alpine

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy application code
COPY dist /app/dist

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

USER nodejs

EXPOSE 3000

CMD ["node", "dist/main.js"]
```

### Create Docker Compose Configuration

```yaml
# docker-compose.staging.yml
version: '3.9'

services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: ${DATABASE_NAME}
      POSTGRES_USER: ${DATABASE_USER}
      POSTGRES_PASSWORD: ${DATABASE_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DATABASE_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  backend:
    build:
      context: .
      dockerfile: backend/Dockerfile
    environment:
      NODE_ENV: staging
      DATABASE_HOST: postgres
      DATABASE_PORT: 5432
      DATABASE_NAME: ${DATABASE_NAME}
      DATABASE_USER: ${DATABASE_USER}
      DATABASE_PASSWORD: ${DATABASE_PASSWORD}
      REDIS_HOST: redis
      REDIS_PORT: 6379
      JWT_SECRET: ${JWT_SECRET}
      STRIPE_SECRET_KEY: ${STRIPE_SECRET_KEY}
    ports:
      - "3000:3000"
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    volumes:
      - ./backend/logs:/app/logs

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
    depends_on:
      - backend

volumes:
  postgres_data:
```

## Step 3: Database Migrations

### Run Migrations

```bash
# Apply pending migrations
npm run migration:run

# Verify migrations
npm run migration:show

# Create seed data
npm run seed:staging
```

### Create Database Seed Script

```typescript
// backend/scripts/seed-staging.ts
import { DataSource } from 'typeorm';
import { AppDataSource } from '../src/database/data-source';

async function seedDatabase() {
  if (!AppDataSource.isInitialized) {
    await AppDataSource.initialize();
  }

  const userRepository = AppDataSource.getRepository('User');
  
  // Create test users
  const testUsers = [
    {
      id: 'user-test-buyer',
      email: 'buyer@staging.afrigo.com',
      password: 'hashed_password',
      role: 'buyer',
      verified: true,
    },
    {
      id: 'user-test-seller',
      email: 'seller@staging.afrigo.com',
      password: 'hashed_password',
      role: 'seller',
      verified: true,
    },
    {
      id: 'user-test-admin',
      email: 'admin@staging.afrigo.com',
      password: 'hashed_password',
      role: 'admin',
      verified: true,
    },
  ];

  for (const user of testUsers) {
    await userRepository.save(user);
  }

  console.log('Database seeded successfully');
  await AppDataSource.destroy();
}

seedDatabase().catch(console.error);
```

## Step 4: Build and Deploy

### Build Backend

```bash
# Install dependencies
npm ci

# Run tests
npm run test:coverage

# Build application
npm run build

# Create Docker image
docker build -f backend/Dockerfile -t afrigo-backend:staging .
```

### Deploy with Docker Compose

```bash
# Start all services
docker-compose -f docker-compose.staging.yml up -d

# Check service status
docker-compose -f docker-compose.staging.yml ps

# View logs
docker-compose -f docker-compose.staging.yml logs -f backend

# Run migrations on fresh database
docker-compose -f docker-compose.staging.yml exec backend npm run migration:run

# Seed test data
docker-compose -f docker-compose.staging.yml exec backend npm run seed:staging
```

## Step 5: Configuration Verification

### Verify API Health

```bash
# Test API endpoint
curl -X GET http://staging.afrigo.com/api/health

# Expected response
{
  "status": "ok",
  "timestamp": "2024-01-15T10:30:00Z",
  "environment": "staging"
}
```

### Verify Database Connection

```bash
# Check database connectivity
docker-compose -f docker-compose.staging.yml exec postgres psql -U afrigo_user -d afrigo_staging -c "SELECT 1"
```

### Verify Authentication

```bash
# Test registration
curl -X POST http://staging.afrigo.com/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@staging.afrigo.com",
    "password": "Test@123456",
    "firstName": "Test",
    "lastName": "User"
  }'

# Test login
curl -X POST http://staging.afrigo.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@staging.afrigo.com",
    "password": "Test@123456"
  }'
```

## Step 6: Mobile App Configuration

### Update API Endpoint

```dart
// mobile-app/lib/services/api_service.dart
class ApiService {
  static const String _baseUrl = 'https://api.staging.afrigo.com';
  
  // Rest of implementation
}
```

### Build APK for Testing

```bash
cd mobile-app

# Build APK (debug mode for testing)
flutter build apk --debug

# Build release APK
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Build IPA for TestFlight

```bash
# Build iOS app
flutter build ios --release

# Upload to TestFlight (requires Apple Developer account)
xcodebuild -workspace ios/Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -derivedDataPath ios/build
```

## Step 7: Stripe Webhook Configuration

### Configure Webhook Endpoints

1. Log into Stripe Dashboard
2. Go to Developers > Webhooks
3. Add endpoint: `https://staging.afrigo.com/api/webhooks/stripe`
4. Select events: `payment_intent.succeeded`, `payment_intent.payment_failed`, `charge.refunded`, `charge.dispute.created`
5. Copy webhook signing secret and add to `.env.staging`: 
   ```
   STRIPE_WEBHOOK_SECRET=whsec_test_...
   ```

### Test Webhook Delivery

```bash
# Use Stripe CLI to forward webhooks to local development
# stripe listen --forward-to localhost:3000/api/webhooks/stripe

# Test payment event
stripe trigger payment_intent.succeeded
```

## Step 8: Monitoring and Logging

### Configure Sentry

```typescript
// backend/src/main.ts
import * as Sentry from '@sentry/node';

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
  tracesSampleRate: 0.1,
});

// Attach to Express/NestJS
app.use(Sentry.Handlers.requestHandler());
app.use(Sentry.Handlers.errorHandler());
```

### Set Up Logging

```typescript
// backend/src/common/logging/custom-logger.ts
import { Logger, Injectable } from '@nestjs/common';

@Injectable()
export class CustomLogger extends Logger {
  log(message: string, context?: string) {
    console.log(
      `[${new Date().toISOString()}] [${context}] ${message}`,
    );
  }

  error(message: string, trace?: string, context?: string) {
    console.error(
      `[${new Date().toISOString()}] [${context}] ERROR: ${message}`,
      trace,
    );
  }
}
```

## Step 9: Testing Procedures

### Manual Testing Checklist

#### User Management
- [ ] Register new user (buyer, seller, member)
- [ ] Email verification working
- [ ] Login/Logout
- [ ] Password reset
- [ ] Profile update
- [ ] Role switching

#### Lots Module
- [ ] Create lot with images
- [ ] List lots with filtering
- [ ] Search functionality
- [ ] Lot details view
- [ ] Favorite lots

#### Trading System
- [ ] Create quote for lot
- [ ] Send offer
- [ ] Accept/Reject offer
- [ ] Create order
- [ ] Order status updates

#### Messaging
- [ ] Send message
- [ ] Receive message
- [ ] Conversation management
- [ ] Message search
- [ ] Unread count

#### Payment Processing
- [ ] Create test payment (Stripe test card)
- [ ] Payment confirmation
- [ ] Refund processing
- [ ] Receipt generation
- [ ] Escrow status tracking

### Automated Testing

```bash
# Run unit tests
npm run test

# Run integration tests
npm run test:integration

# Generate coverage report
npm run test:coverage

# Run API load test
npm run test:load
```

## Step 10: Performance Verification

### Database Query Performance

```sql
-- Check slow queries
SELECT query, calls, total_time, mean_time
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 10;
```

### API Response Time Monitoring

```bash
# Monitor endpoint response times
curl -w "@curl-format.txt" -o /dev/null -s http://staging.afrigo.com/api/lots

# Create curl-format.txt
cat > curl-format.txt << 'EOF'
    time_namelookup:  %{time_namelookup}\n
    time_connect:     %{time_connect}\n
    time_appconnect:  %{time_appconnect}\n
    time_pretransfer: %{time_pretransfer}\n
    time_starttransfer: %{time_starttransfer}\n
    -----
    time_total:       %{time_total}\n
EOF
```

## Step 11: Security Hardening

### SSL/TLS Configuration

```bash
# Generate self-signed certificate for staging
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx/ssl/private.key \
  -out nginx/ssl/certificate.crt
```

### Security Headers

```nginx
# nginx/nginx.conf
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Content-Security-Policy "default-src 'self'" always;
```

### Database Security

- [ ] Enable SSL connections for PostgreSQL
- [ ] Set up database user with minimal privileges
- [ ] Configure connection pooling with PgBouncer
- [ ] Enable query logging for auditing
- [ ] Set up automated backups

## Step 12: Backup and Recovery

### Database Backup

```bash
# Manual backup
docker-compose -f docker-compose.staging.yml exec postgres \
  pg_dump -U afrigo_user afrigo_staging > backup-$(date +%Y%m%d-%H%M%S).sql

# Automated daily backups
# Add to crontab:
# 0 2 * * * docker-compose -f docker-compose.staging.yml exec postgres pg_dump -U afrigo_user afrigo_staging > /backups/afrigo-$(date +\%Y\%m\%d).sql
```

### Recovery Procedure

```bash
# Restore from backup
docker-compose -f docker-compose.staging.yml exec -T postgres \
  psql -U afrigo_user afrigo_staging < backup-20240115-020000.sql
```

## Step 13: Team Access

### Create Test Accounts

| Role | Email | Password | Purpose |
|------|-------|----------|---------|
| Admin | admin@staging.afrigo.com | GeneratedSecurely | System administration |
| Seller | seller@staging.afrigo.com | GeneratedSecurely | Testing lot management |
| Buyer | buyer@staging.afrigo.com | GeneratedSecurely | Testing purchasing flow |
| Support | support@staging.afrigo.com | GeneratedSecurely | Testing support features |

## Staging Environment URLs

- **API Base**: `https://api.staging.afrigo.com`
- **Web Dashboard**: `https://staging.afrigo.com`
- **Admin Panel**: `https://admin.staging.afrigo.com`
- **API Docs**: `https://api.staging.afrigo.com/api/docs`

## Troubleshooting

### Common Issues

**Issue**: Database connection timeout
```bash
# Solution: Check postgres container
docker-compose -f docker-compose.staging.yml logs postgres
docker-compose -f docker-compose.staging.yml ps postgres
```

**Issue**: API endpoints returning 503
```bash
# Solution: Check backend logs
docker-compose -f docker-compose.staging.yml logs backend
```

**Issue**: Webhook not receiving events
```bash
# Solution: Verify endpoint and signature
docker-compose -f docker-compose.staging.yml logs backend | grep webhook
```

## Rollback Procedure

```bash
# Stop all services
docker-compose -f docker-compose.staging.yml stop

# Remove containers (keep data)
docker-compose -f docker-compose.staging.yml rm

# Checkout previous commit
git checkout <previous-commit>

# Rebuild and redeploy
docker-compose -f docker-compose.staging.yml up -d
```

## Sign-Off Checklist

- [ ] All unit tests passing (100% coverage on critical paths)
- [ ] All integration tests passing
- [ ] Database migrations successful
- [ ] API endpoints responding with correct status codes
- [ ] Authentication and authorization working
- [ ] Payment system integrated and tested with Stripe
- [ ] Webhooks receiving and processing events
- [ ] Mobile app connecting successfully
- [ ] All critical user flows tested manually
- [ ] Performance baseline established
- [ ] Security assessment completed
- [ ] Backup and recovery tested
- [ ] Team able to access and test

## Next Steps

1. **Complete Staging Testing** (1-2 weeks)
   - QA team comprehensive testing
   - Performance optimization
   - Security hardening

2. **Production Preparation** (1 week)
   - Generate production environment files
   - Set up production database
   - Configure production Stripe keys
   - Prepare deployment automation

3. **Production Launch** (1-2 days)
   - Final testing on production database
   - Deploy to production
   - Monitor for issues
   - Communicate with stakeholders

## Support

For deployment issues or questions:
- Check logs: `docker-compose logs -f`
- Review migration status: `npm run migration:show`
- Verify environment variables: `docker-compose config | grep STRIPE`
- Test API health: `curl http://localhost:3000/api/health`

---

**Document Version**: 1.0
**Last Updated**: January 2024
**Status**: Ready for Staging Deployment
