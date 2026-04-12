# CI/CD Pipeline Setup - GitHub Actions + Deployment

> **Goal:** Automated testing, building, and deployment on every push/PR  
> **Primary Platform:** GitHub Actions  
> **Deployment Targets:** Staging (every push) → Production (with approval)

---

## 🏗️ PIPELINE ARCHITECTURE

```
Code Push to GitHub
        ↓
GitHub Actions Triggered
        ├─ Lint (ESLint, Dart Analysis)
        ├─ Unit Tests
        ├─ Integration Tests
        ├─ Build (backend + frontend)
        └─ Security Scan (OWASP)
        ↓
    All Passed?
        ├─ YES → Build Docker images → Push to Registry
        │        Deploy to Staging
        │        Run Smoke Tests
        └─ NO → Notify team, STOP
```

---

## 📝 GITHUB ACTIONS WORKFLOWS

### **1. Backend CI/CD (.github/workflows/backend.yml)**

```yaml
name: Backend CI/CD

on:
  push:
    branches: [main, develop]
    paths:
      - 'backend/**'
      - '.github/workflows/backend.yml'
  pull_request:
    branches: [main, develop]
    paths:
      - 'backend/**'

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          
      - name: Install dependencies
        working-directory: backend
        run: npm ci
        
      - name: Run ESLint
        working-directory: backend
        run: npm run lint
        
      - name: Type check (TypeScript)
        working-directory: backend
        run: npm run type-check

  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          
      - name: Install dependencies
        working-directory: backend
        run: npm ci
        
      - name: Run unit tests
        working-directory: backend
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/test_db
        run: npm run test -- --coverage
        
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./backend/coverage/coverage-final.json
          flags: backend
          fail_ci_if_error: false

  build:
    runs-on: ubuntu-latest
    needs: [lint, test]
    if: success()
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          
      - name: Install dependencies
        working-directory: backend
        run: npm ci
        
      - name: Build
        working-directory: backend
        run: npm run build
        
      - name: Setup Docker Buildx
        uses: docker/setup-buildx-action@v2
        
      - name: Login to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
          
      - name: Build and push Docker image
        uses: docker/build-push-action@v4
        with:
          context: backend
          push: ${{ github.event_name == 'push' && github.ref == 'refs/heads/main' }}
          tags: |
            ${{ secrets.DOCKER_REGISTRY }}/afrigo-backend:latest
            ${{ secrets.DOCKER_REGISTRY }}/afrigo-backend:${{ github.sha }}
          cache-from: type=registry,ref=${{ secrets.DOCKER_REGISTRY }}/afrigo-backend:buildcache
          cache-to: type=registry,ref=${{ secrets.DOCKER_REGISTRY }}/afrigo-backend:buildcache,mode=max

  security:
    runs-on: ubuntu-latest
    needs: [build]
    if: success()
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Run Snyk security scan
        uses: snyk/actions/node@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          args: --severity-threshold=high

  deploy-staging:
    runs-on: ubuntu-latest
    needs: [build, security]
    if: github.event_name == 'push' && github.ref == 'refs/heads/develop'
    environment:
      name: staging
      url: https://api-staging.afrigo.app
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy to staging
        env:
          DEPLOY_KEY: ${{ secrets.DEPLOY_KEY_STAGING }}
          DEPLOY_HOST: ${{ secrets.DEPLOY_HOST_STAGING }}
        run: |
          mkdir -p ~/.ssh
          echo "$DEPLOY_KEY" > ~/.ssh/deploy_key
          chmod 600 ~/.ssh/deploy_key
          ssh -i ~/.ssh/deploy_key -o StrictHostKeyChecking=no $DEPLOY_HOST "cd /app && git pull && npm install && npm run build && pm2 restart afrigo-backend"
          
      - name: Run smoke tests
        run: npm run test:smoke -- --baseUrl=https://api-staging.afrigo.app

  deploy-production:
    runs-on: ubuntu-latest
    needs: [deploy-staging]
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    environment:
      name: production
      url: https://api.afrigo.app
    
    steps:
      - name: Wait for approval
        run: echo "Waiting for manual approval..."
        
      - uses: actions/checkout@v4
      
      - name: Deploy to production
        env:
          DEPLOY_KEY: ${{ secrets.DEPLOY_KEY_PROD }}
          DEPLOY_HOST: ${{ secrets.DEPLOY_HOST_PROD }}
        run: |
          mkdir -p ~/.ssh
          echo "$DEPLOY_KEY" > ~/.ssh/deploy_key
          chmod 600 ~/.ssh/deploy_key
          ssh -i ~/.ssh/deploy_key -o StrictHostKeyChecking=no $DEPLOY_HOST "cd /app && git pull && npm install && npm run build && pm2 restart afrigo-backend"
          
      - name: Notify Slack
        uses: slackapi/slack-github-action@v1
        with:
          payload: |
            {
              "text": "✅ AfriGo Backend deployed to production",
              "blocks": [
                {
                  "type": "section",
                  "text": {
                    "type": "mrkdwn",
                    "text": "*✅ Backend Deployed to Production*\nCommit: ${{ github.sha }}\nAuthor: ${{ github.actor }}"
                  }
                }
              ]
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
          SLACK_WEBHOOK_TYPE: INCOMING_WEBHOOK
```

---

### **2. Frontend CI/CD (.github/workflows/mobile.yml)**

```yaml
name: Mobile App CI/CD

on:
  push:
    branches: [main, develop]
    paths:
      - 'mobile_app/**'
      - '.github/workflows/mobile.yml'
  pull_request:
    branches: [main, develop]
    paths:
      - 'mobile_app/**'

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22.0'
          
      - name: Get dependencies
        working-directory: mobile_app
        run: flutter pub get
        
      - name: Analyze code
        working-directory: mobile_app
        run: flutter analyze
        
      - name: Format check
        working-directory: mobile_app
        run: dart format --set-exit-if-changed .

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22.0'
          
      - name: Get dependencies
        working-directory: mobile_app
        run: flutter pub get
        
      - name: Run unit tests
        working-directory: mobile_app
        run: flutter test --coverage
        
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./mobile_app/coverage/lcov.info
          flags: mobile

  build-android:
    runs-on: ubuntu-latest
    needs: [analyze, test]
    if: success()
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22.0'
          
      - name: Setup Java
        uses: actions/setup-java@v3
        with:
          distribution: 'temurin'
          java-version: '11'
          
      - name: Get dependencies
        working-directory: mobile_app
        run: flutter pub get
        
      - name: Build APK
        working-directory: mobile_app
        run: flutter build apk --release
        
      - name: Upload APK artifact
        uses: actions/upload-artifact@v3
        with:
          name: app-release.apk
          path: mobile_app/build/app/outputs/flutter-apk/app-release.apk

  build-ios:
    runs-on: macos-latest
    needs: [analyze, test]
    if: success()
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22.0'
          
      - name: Get dependencies
        working-directory: mobile_app
        run: flutter pub get
        
      - name: Build iOS
        working-directory: mobile_app
        run: flutter build ios --release --no-codesign
        
      - name: Upload iOS artifact
        uses: actions/upload-artifact@v3
        with:
          name: app-ios
          path: mobile_app/build/ios/iphoneos/Runner.app

  deploy-beta:
    runs-on: macos-latest
    needs: [build-android, build-ios]
    if: github.event_name == 'push' && github.ref == 'refs/heads/develop'
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Download APK
        uses: actions/download-artifact@v3
        with:
          name: app-release.apk
          
      - name: Download iOS
        uses: actions/download-artifact@v3
        with:
          name: app-ios
          
      - name: Deploy to Firebase App Distribution (Android)
        uses: wzieba/Firebase-Distribution-Github-Action@v1
        with:
          appId: ${{ secrets.FIREBASE_APP_ID_ANDROID }}
          serviceCredentialsFile: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}
          groups: testers
          file: app-release.apk
          
      - name: Deploy to TestFlight (iOS)
        uses: apple-actions/upload-testflight-build@v1
        with:
          app-path: app-ios
          issuer-id: ${{ secrets.APPSTORE_ISSUER_ID }}
          api-key-id: ${{ secrets.APPSTORE_API_KEY_ID }}
          api-private-key: ${{ secrets.APPSTORE_API_PRIVATE_KEY }}
```

---

## 🔐 GITHUB SECRETS CONFIGURATION

Create these secrets in your GitHub repo:

**Docker/Registry:**
- `DOCKER_USERNAME` - Docker Hub username
- `DOCKER_PASSWORD` - Docker Hub token
- `DOCKER_REGISTRY` - Registry URL

**Firebase:**
- `FIREBASE_SERVICE_ACCOUNT` - Firebase service account JSON

**Deployment:**
- `DEPLOY_KEY_STAGING` - SSH private key for staging
- `DEPLOY_HOST_STAGING` - Staging server hostname
- `DEPLOY_KEY_PROD` - SSH private key for production
- `DEPLOY_HOST_PROD` - Production server hostname

**App Store:**
- `APPSTORE_ISSUER_ID` - Apple App Store issuer ID
- `APPSTORE_API_KEY_ID` - App Store Connect API Key ID
- `APPSTORE_API_PRIVATE_KEY` - App Store Connect API private key

**Monitoring:**
- `SLACK_WEBHOOK` - Slack webhook for notifications
- `SNYK_TOKEN` - Snyk security scanning token

---

## 📊 PIPELINE STATUS DASHBOARD

```
Workflow Results (visualized in GitHub)

Backend CI/CD
├─ Lint ................... ✅ 45s
├─ Test ................... ✅ 2m 30s
├─ Build .................. ✅ 3m 15s
├─ Security ............... ✅ 1m 20s
└─ Deploy Staging ......... ✅ 2m

Mobile App CI/CD
├─ Lint ................... ✅ 1m
├─ Test ................... ✅ 3m
├─ Build Android ......... ✅ 8m
├─ Build iOS ............. ✅ 12m
└─ Deploy Beta ........... ✅ 5m

Total Time: ~25 minutes
```

---

## 🚀 DEPLOYMENT CHECKLIST

Before each deployment:

- [ ] All tests passed
- [ ] Security scan clear
- [ ] Code review approved
- [ ] Database migrations tested
- [ ] Environment variables set correctly
- [ ] Backup created
- [ ] Rollback plan in place
- [ ] Monitoring alerts configured
- [ ] Team notified

---

## 📈 MONITORING SETUP

### **Error Tracking (Sentry)**
```yaml
# .env.local
SENTRY_DSN_BACKEND=https://...
SENTRY_DSN_MOBILE=https://...
```

### **Performance Monitoring (DataDog)**
```typescript
// backend/src/main.ts
import { datadogRum } from '@datadog/browser-rum';

datadogRum.init({
  applicationId: process.env.DATADOG_APP_ID,
  clientToken: process.env.DATADOG_CLIENT_TOKEN,
  site: 'datadoghq.com',
});
```

### **Health Checks**
```
GET /health
Response:
{
  "status": "healthy",
  "timestamp": "2024-04-12T10:30:00Z",
  "database": "connected",
  "redis": "connected",
  "external_apis": "all_ok"
}
```

---

## ✅ CI/CD SETUP CHECKLIST

- [ ] GitHub repository created + configured
- [ ] All secrets added to GitHub
- [ ] Backend CI/CD workflow created
- [ ] Mobile App CI/CD workflow created
- [ ] Docker images building successfully
- [ ] Staging environment accessible
- [ ] Production environment ready
- [ ] Monitoring (Sentry, DataDog) configured
- [ ] Slack notifications working
- [ ] Rollback procedures documented

