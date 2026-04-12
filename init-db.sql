-- AfriGo Platform - Database Initialization
-- Initial setup: Create databases and superuser

-- Create the application database
CREATE DATABASE afrigo_dev
  ENCODING 'UTF8'
  LC_COLLATE 'C'
  LC_CTYPE 'C'
  TEMPLATE template0;

CREATE DATABASE afrigo_test
  ENCODING 'UTF8'
  LC_COLLATE 'C'
  LC_CTYPE 'C'
  TEMPLATE template0;

-- Connect to main database
\c afrigo_dev

-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";  -- For full-text search

-- Create app user with proper permissions
CREATE ROLE afrigo_app WITH LOGIN PASSWORD 'app_password_123' CREATEDB;
GRANT CONNECT ON DATABASE afrigo_dev TO afrigo_app;
GRANT USAGE ON SCHEMA public TO afrigo_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO afrigo_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO afrigo_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO afrigo_app;

GRANT ALL ON SCHEMA public TO afrigo_app;

-- Switch to test database
\c afrigo_test

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

GRANT CONNECT ON DATABASE afrigo_test TO afrigo_app;
GRANT USAGE ON SCHEMA public TO afrigo_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO afrigo_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO afrigo_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO afrigo_app;

GRANT ALL ON SCHEMA public TO afrigo_app;

-- Switch back to dev
\c afrigo_dev
