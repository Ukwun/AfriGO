# AfriGo Database Setup Guide

## Overview

AfriGo uses **PostgreSQL 15** for all persistent data storage. The database is designed for:
- **ACID Compliance:** All financial transactions are guaranteed
- **Immutable Audit Logs:** Every lot event is recorded permanently
- **High Concurrency:** Supports 50,000+ concurrent users
- **Full-Text Search:** Fast commodity and product searching
- **Real-time Subscriptions:** Firebase Realtime DB + PostgreSQL for hybrid real-time

## Quick Start (Using Docker)

### Prerequisites
- Docker & Docker Compose installed
- 2 GB RAM available
- 5 GB disk space

### Setup

1. **Start PostgreSQL & PgAdmin:**
   ```bash
   cd c:\afrigo
   docker-compose up -d
   ```

2. **Verify containers are running:**
   ```bash
   docker ps
   ```

3. **Access PgAdmin (UI):**
   - URL: http://localhost:5050
   - Email: admin@afrigo.local
   - Password: admin_password_123

4. **Verify database with psql:**
   ```bash
   # Once PostgreSQL is running
   docker exec -it afrigo_postgres_dev psql -U afrigo_dev -d afrigo_dev
   
   # List tables
   \dt
   
   # Exit
   \q
   ```

5. **Verify migrations applied:**
   ```bash
   docker exec -it afrigo_postgres_dev psql -U afrigo_dev -d afrigo_dev \
     -c "SELECT table_name FROM information_schema.tables WHERE table_schema='public';"
   ```

### Stop Services
```bash
docker-compose down
```

### Clean Everything (Fresh DB)
```bash
docker-compose down -v
docker-compose up -d
```

---

## Manual PostgreSQL Setup (Without Docker)

### Step 1: Install PostgreSQL

**On macOS (Homebrew):**
```bash
brew install postgresql@15
brew services start postgresql@15
```

**On Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib postgresql-15-dev
sudo systemctl start postgresql
```

**On Windows:**
- Download: https://www.postgresql.org/download/windows/
- Run installer
- Set password for `postgres` user
- Choose port 5432 (default)
- Install pgAdmin4 (optional but recommended)

### Step 2: Create Databases & Users

```bash
# Connect as postgres superuser
psql -U postgres

# Copy-paste the contents of init-db.sql
\i init-db.sql

# Verify databases created
\l

# Verify users created
\du

# Exit
\q
```

### Step 3: Apply Schema Migrations

```bash
# Connect as afrigo_app user
psql -U afrigo_app -h localhost -d afrigo_dev

# Load migrations
\i migrations/001-schema.sql

# List all tables
\dt

# Verify views created
\dv

# Exit
\q
```

### Step 4: Seed Development Data (Optional)

```bash
psql -U afrigo_app -h localhost -d afrigo_dev -f migrations/002-seed-data.sql
```

---

## Database Structure

### Core Entities (13 Tables)

#### 1. **Users & Authentication**
- `users` — User profiles, KYC status
- `user_roles` — Role assignments (buyer, seller, member)
- `user_verification_tokens` — Email/phone/password reset tokens

#### 2. **Lots** (Core Event Entity)
- `lots` — Agricultural commodity lots
- `lot_events` — Immutable event log (created, published, updated, shipped, etc.)

#### 3. **Marketplace**
- `rfqs` — Request for Quotes from buyers
- `bids` — Seller bids on RFQs

#### 4. **Contracts & E-Signatures**
- `contracts` — Purchase agreements
- `contract_signatures` — Digital signatures (timestamp, IP, device)

#### 5. **Payments & Escrow**
- `payment_ledger` — All transactions (immutable, no updates)
- `escrow_accounts` — Buyer funds held safely

#### 6. **Logistics**
- `shipments` — Shipment tracking
- `shipment_events` — Real-time location updates

#### 7. **Documents**
- `documents` — Stored on S3 (bill of lading, invoices, certificates)
- `dossiers` — Collections of documents per contract

#### 8. **Zone Services**
- `zone_registrations` — Business registration per country
- `forex_rates` — Currency conversion rates

#### 9. **Quality & Compliance**
- `quality_inspections` — Lab test results
- `compliance_checks` — Sanitary, customs, financial checks

#### 10. **Communication**
- `conversations` — Direct messages between users
- `messages` — Chat history
- `notifications` — In-app alerts
- `activity_logs` — Audit trail of user actions

#### 11. **Ratings & Reviews**
- `ratings` — Seller ratings from buyers

---

## Connection Strings

### Development
```
postgresql://afrigo_app:app_password_123@localhost:5432/afrigo_dev
```

### Testing
```
postgresql://afrigo_app:app_password_123@localhost:5432/afrigo_test
```

### Backend (.env)
```bash
DATABASE_URL=postgresql://afrigo_app:app_password_123@localhost:5432/afrigo_dev
DATABASE_TEST_URL=postgresql://afrigo_app:app_password_123@localhost:5432/afrigo_test
```

### Node.js Connection (TypeORM)
```typescript
const datasource = new DataSource({
  type: 'postgres',
  host: process.env.DATABASE_HOST || 'localhost',
  port: parseInt(process.env.DATABASE_PORT || '5432'),
  username: process.env.DATABASE_USER || 'afrigo_app',
  password: process.env.DATABASE_PASSWORD || 'app_password_123',
  database: process.env.DATABASE_NAME || 'afrigo_dev',
  synchronize: false,
  logging: process.env.DATABASE_LOG_QUERIES === 'true',
  entities: ['src/**/*.entity.ts'],
  migrations: ['src/migrations/*.ts'],
});
```

---

## Key Design Decisions

### 1. **Immutable Audit Trail**
- `lot_events` table stores EVERY state change
- Never UPDATE lot data; INSERT new event instead
- Permanent compliance record

### 2. **Idempotent Payments**
- `payment_ledger.idempotency_key` UNIQUE constraint
- Prevents double-charging on network retries
- Matches Flutterwave webhook idempotency

### 3. **Role-Based Access Control**
- Multiple roles per user (`user_roles` table)
- Each role has different dashboard & permissions
- Buyer, Seller, Member, Wholesale, AXE (trade facilitator), Admin

### 4. **Firebase + PostgreSQL Hybrid**
- **PostgreSQL:** Transactional data (lots, contracts, payments)
- **Firebase Realtime:** Only 3 features (shipment location, payment status, contract updates)
- Reduces Firebase costs & complexity

### 5. **Document Storage**
- Files stored on AWS S3 (not database)
- Database stores metadata + S3 references
- Includes integrity checking (SHA-256 hashes)

### 6. **Custody Chain Tracking**
- Shipment events track every stop
- Location, timestamp, photos for traceability
- Core competitive advantage

---

## Performance Tuning

### Indexes Created
```sql
-- Commonly filtered columns
idx_lots_status
idx_lots_seller_id
idx_contracts_status
idx_payment_ledger_status

-- Composite indexes for speed
idx_lots_status_created  -- WHERE status='published' ORDER BY created_at
idx_contracts_status_updated

-- Full-text search
idx_lots_commodity_trgm
idx_rfqs_commodity_trgm
```

### Query Optimization
1. Always use indexes in WHERE clauses
2. Avoid `SELECT *` in production (specify columns)
3. Use EXPLAIN ANALYZE for slow queries
4. Paginate results (limit 50 per page max)
5. Cache frequently accessed data in Redis (later phase)

### Connection Pooling
- Backend: Use TypeORM DataSource (built-in pool)
- Max connections: 20 per replica
- Idle timeout: 30 seconds
- Config in `.env`:
  ```
  DATABASE_POOL_SIZE=20
  DATABASE_POOL_IDLE_TIMEOUT=30
  ```

---

## Backups & Recovery

### Manual Backup
```bash
# Full database dump
pg_dump -U afrigo_app -h localhost afrigo_dev > backup_dev.sql

# Compressed backup
pg_dump -U afrigo_app -h localhost -Fc afrigo_dev > backup_dev.dump
```

### Restore from Backup
```bash
# From SQL dump
psql -U afrigo_app -h localhost afrigo_dev < backup_dev.sql

# From compressed dump
pg_restore -U afrigo_app -h localhost -d afrigo_dev backup_dev.dump
```

### Automated Backups (Production)
```bash
# Using pg_dump in cron (every 6 hours)
0 */6 * * * pg_dump -U afrigo_app -h db.afrigo.io afrigo_prod | gzip > /backups/afrigo_$(date +\%Y\%m\%d_\%H%M%S).sql.gz
```

---

## Troubleshooting

### Issue: "Connection refused on localhost:5432"
```bash
# Verify PostgreSQL is running
docker ps | grep postgres
# or on native install
sudo systemctl status postgresql
```

### Issue: "Password authentication failed"
```bash
# Check PostgreSQL logs
docker logs afrigo_postgres_dev
# or
tail -f /var/log/postgresql/postgresql.log
```

### Issue: "Role does not exist"
```bash
# Recreate user (Docker, after container stop)
docker-compose down -v
docker-compose up -d
```

### Issue: "Tables not created"
```bash
# Re-run migrations
docker exec -it afrigo_postgres_dev \
  psql -U afrigo_dev -d afrigo_dev -f /docker-entrypoint-initdb.d/02-schema.sql
```

### Issue: "Slow queries"
```sql
-- Find slow queries
SELECT query, calls, total_time, mean_time 
FROM pg_stat_statements 
WHERE mean_time > 100 
ORDER BY mean_time DESC;

-- Enable query logging
ALTER SYSTEM SET log_min_duration_statement = 100;
SELECT pg_reload_conf();
```

---

## Production Deployment

### Managed PostgreSQL Services (Recommended)
- **AWS RDS** — Fully managed, automated backups, multi-AZ
- **DigitalOcean Managed Databases** — Simpler, cheaper
- **Render** — Simple PostgreSQL hosting
- **Supabase** — PostgreSQL + Firebase Realtime alternative

### Connection (Prod)
```bash
DATABASE_URL=postgresql://user:password@prod-db.region.rds.amazonaws.com:5432/afrigo_prod?sslmode=require
```

### SSL/TLS Required
```bash
sslmode=require  # Always for production
```

### Monitoring
- CloudWatch (AWS) or equivalent
- Set alerts for CPU > 70%, Disk > 85%
- Monitor connection pool exhaustion
- Track query performance degradation

---

## Team Access

### Development
| Role | Connection | Access |
|------|-----------|--------|
| Backend Engineer | localhost:5432 | Full (run migrations) |
| Mobile Engineer | Tunneled (ssh proxy) | Read + insert/update own data |
| DevOps | Docker container | Manage backups & scaling |

### Testing
- Use `afrigo_test` database
- Run cleanup between test suites
- Never modify test DB schema manually (migrations only)

### Production
- Only DevOps team has access
- All changes via migrations + deployment pipelines
- Read-only replicas for analytics queries

---

## Next Steps

1. **Run Docker setup:** `docker-compose up -d`
2. **Verify migrations:** `\dt` in psql (list tables)
3. **Seed data:** `psql -f migrations/002-seed-data.sql` (when ready)
4. **Backend integration:** Update `.env` with `DATABASE_URL`
5. **Test connectivity:** `npm run test:db` (in backend)

---

**Last Updated:** January 2025
**Maintained by:** DevOps Team
