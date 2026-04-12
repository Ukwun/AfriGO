# AfriGo Backend API

Pan-African Digital Trade Operating System - Backend API built with NestJS, PostgreSQL, and Firebase.

## Quick Start

### Prerequisites
- Node.js 20+
- PostgreSQL 15+
- Firebase project with admin credentials

### Installation

```bash
# Install dependencies
npm install

# Setup environment
cp .env.example .env
# Edit .env with your configuration

# Run in development
npm run dev

# Build for production
npm run build

# Start production server
npm run start
```

### Database Migrations

```bash
# Run migrations
npm run migration:run

# Create new migration
npm run migration:create

# Revert migrations
npm run migration:revert
```

### API Documentation

Once the server is running, the API documentation is available at:
- http://localhost:3000/api/docs (Swagger UI)
- http://localhost:3000/health (Health check)

## Project Structure

```
src/
├── modules/         # Feature modules (auth, lots, marketplace, etc.)
├── common/          # Shared utilities (decorators, filters, pipes)
├── config/          # Configuration files
├── database/        # Database migrations
├── firebase/        # Firebase integration
└── main.ts          # Entry point
```

## Testing

```bash
# Run unit tests
npm run test

# Watch mode
npm run test:watch

# Coverage report
npm run test:coverage
```

## Code Quality

```bash
# Lint code
npm run lint

# Format code
npm run format

# Type check
npm run type-check
```

## Architecture

- **Framework:** NestJS
- **Database:** PostgreSQL (TypeORM)
- **Authentication:** Firebase Auth + JWT
- **Real-time:** Firebase Realtime Database + Socket.io
- **Storage:** AWS S3
- **Monitoring:** Sentry

## Sprint 1 Milestones

- [ ] Auth endpoints (register, login, refresh)
- [ ] KYC document upload
- [ ] Dashboard data endpoints
- [ ] Database migrations
- [ ] Unit tests (80%+ coverage)

## Contributing

Follow the architecture defined in `project-docs/01_API_ARCHITECTURE.md`

## License

MIT
