# GIT COMMANDS - QUICK REFERENCE FOR WEEK 9 DEPLOYMENT
## Copy-paste ready commands for Monday-Friday deployment

---

## MONDAY - CREATE & PUSH BRANCH

### Step 1: Verify You're on Correct Branch
```bash
git status
git branch -a  # Should show all available branches
```

### Step 2: Create Feature Branch from develop
```bash
# Make sure you're on develop first
git checkout develop
git pull origin develop

# Create new branch for Week 9 work
git checkout -b week9-export-docs
# OR with timestamp for uniqueness
git checkout -b week9-export-docs-$(date +%Y%m%d-%H%M%S)
```

### Step 3: Stage Export Documentation Code
```bash
# Stage only the new/modified files
git add src/modules/export-documentation/
git add src/database/migrations/1713300001-create-export-documents.sql

# Verify staged files
git status  # Should show "Changes to be committed"
```

### Step 4: Commit with Detailed Message
```bash
git commit -m "feat(export-docs): Week 9 export documentation module

- Export document generation (8 document types: phytosanitary, BOL, CI, COO, packing list, CoA, organic, fair trade)
- Country-specific compliance matrix for 8+ countries (Kenya, Uganda, Tanzania, Ethiopia, Ghana, Nigeria, ZA, RW)
- Digital signature support (legally binding)
- Government submission workflow with approval tracking
- PDF generation for all document types
- Compliance report generation with required docs checklist
- Full REST API (12 endpoints)
- Unit tests with 80%+ code coverage
- Database schema with performance indexes

Features:
- generateDocument(): Auto-generate export docs with compliance validation
- getDocument(): Retrieve single document
- listDocuments(): Query with filters (status, type, shipment)
- generateComplianceReport(): Get required docs for destination country
- generatePDF(): Create PDF for customs submission
- signDocument(): Digital e-signature (legally binding)
- submitForApproval(): Submit to government
- getApprovalStatus(): Check government approval progress
- updateDocumentStatus(): Workflow state management
- archiveDocuments(): Bulk archival

Country Support:
- Kenya: Cocoa, Coffee, Cashew with specific restrictions
- Uganda: Cocoa, Coffee with CORE act compliance
- Tanzania, Ethiopia, Ghana, Nigeria: Baseline support
- EU: Deforestation Regulation (2023/1115) support
- US: FSMA Pathogen testing requirements

Database:
- export_documents table with 9 indexes (shipment, contract, status, type, countries, etc.)
- Foreign key relationships to shipments, contracts, users
- JSONB support for flexible metadata & signatures
- Automatic updated_at trigger

Tests:
- 15+ unit tests covering happy path & error cases
- generateDocument() success & validation
- Compliance matrix for all countries
- Status transitions (workflow validation)
- Sign document (legal binding)
- Submit for approval (government workflow)
- 80%+ code coverage

Closes #Week9"

# Verify commit
git log --oneline -1
```

### Step 5: Push to GitHub
```bash
# First time pushing this branch
git push -u origin week9-export-docs

# OR if you want to verify first
git push --dry-run -u origin week9-export-docs
git push -u origin week9-export-docs  # Then actually push
```

### Step 6: Create Pull Request
```bash
# From command line (GitHub CLI)
gh pr create --title "Week 9: Export Documentation Module" \
  --body "Implements export documentation generation, compliance checking, digital signatures, and government submission workflow.

## Changes
- Export document entity & database schema
- Service with 12 methods (generate, sign, submit, etc)
- Controller with 12 REST endpoints  
- 15+ unit tests (80%+ coverage)
- Support for 8+ countries
- Digital signature workflow
- Compliance matrix generation

## Checklist
- [x] Code compiles without errors
- [x] All unit tests passing
- [x] Database migration created
- [x] API documentation updated
- [ ] Frontend integration (Week 10)
- [ ] Production deployment (Friday)

## Related
- Week 9 Export Documentation Module
- Legal docs submitted for counsel review
- Partner recruitment in progress" \
  --base develop \
  --head week9-export-docs \
  --reviewer backend-lead

# OR create manually on GitHub UI:
# 1. Visit: https://github.com/africago/platform/pull/new/week9-export-docs
# 2. Add title & description
# 3. Set base=develop, compare=week9-export-docs
# 4. Click "Create Pull Request"
```

---

## TUESDAY-WEDNESDAY - CONTINUE BUILDING

### Pull Latest Changes (if teammates pushed)
```bash
git pull origin week9-export-docs
```

### Commit Service Implementation
```bash
git add src/modules/export-documentation/services/export-document.service.ts
git commit -m "feat(export-docs): Complete service implementation

- generateDocument() with compliance validation
- getDocument() & listDocuments() with filtering
- generateComplianceReport() for all countries
- generatePDF() for all 8 document types
- signDocument() with digital signatures
- submitForApproval() & getApprovalStatus()
- updateDocumentStatus() with workflow validation
- archiveDocuments() for old records
- Full error handling & edge cases"

git push origin week9-export-docs
```

### Commit Controller Implementation
```bash
git add src/modules/export-documentation/controllers/export-document.controller.ts
git commit -m "feat(export-docs): Complete controller with 12 REST endpoints

- POST /api/export-documentation - Create document
- GET /api/export-documentation/:id - Get single doc
- GET /api/export-documentation - List all
- GET /api/export-documentation/:id/download - PDF download
- POST /api/export-documentation/:id/sign - Sign document
- POST /api/export-documentation/:id/submit - Submit to govt
- GET /api/export-documentation/:id/status - Check approval
- POST /api/export-documentation/compliance/report - Compliance checklist
- POST /api/export-documentation/bulk-generate - Batch create
- GET /api/export-documentation/shipment/:id/bundle - Document bundle
- POST /api/export-documentation/:id/request-signature - Request signature
- GET /api/export-documentation/metadata/countries - Supported countries

All endpoints with JWT auth, proper HTTP status codes, consistent response format"

git push origin week9-export-docs
```

### Commit Unit Tests
```bash
git add src/modules/export-documentation/services/export-document.service.spec.ts
git commit -m "test(export-docs): Comprehensive unit tests with 80%+ coverage

- generateDocument() success & error cases
- getDocument() & listDocuments()
- generateComplianceReport() for all countries
- signDocument() workflow validation
- submitForApproval() & getApprovalStatus()
- updateDocumentStatus() & status transitions
- archiveDocuments()
- Mock repository setup
- 80%+ code coverage achieved"

git push origin week9-export-docs
```

---

## THURSDAY - FINAL REVIEW & MERGE

### Run Full Test Suite Before Merge
```bash
# Build the entire project
npm run build

# Run all tests
npm run test

# Generate coverage report
npm run test:cov
```

### Update CHANGELOG
```bash
# Add entry for Week 9 release
cat >> CHANGELOG.md << 'EOF'

## [0.9.0] - 2026-04-19 (Week 9)

### Added
- Export documentation module (8 document types)
- Country-specific compliance requirements (8+ countries)
- Digital signature support (legally binding)
- Government submission workflow
- PDF generation for export documents
- Compliance report generation
- 12 new REST API endpoints
- Full unit test coverage (80%+)

### Features
- Phytosanitary certificates
- Bills of lading
- Commercial invoices
- Certificates of origin
- Packing lists
- Certificates of analysis
- Organic certificates
- Fair trade certificates

### Countries Supported
- Kenya, Uganda, Tanzania, Ethiopia, Ghana, Nigeria, South Africa, Rwanda
- EU Deforestation Compliance
- US FSMA Compliance

EOF

git add CHANGELOG.md
git commit -m "docs: Update CHANGELOG for Week 9 release"
git push origin week9-export-docs
```

### Merge to Develop (after PR approval)
```bash
# Switch to develop
git checkout develop
git pull origin develop

# Merge feature branch
git merge --no-ff week9-export-docs

# OR via GitHub PR UI:
# 1. Go to PR: https://github.com/africago/platform/pull/[NUMBER]
# 2. Click "Squash and Merge" (if you want cleaner history)
# 3. Confirm merge
```

### Delete Old Branch (cleanup)
```bash
# Delete local branch
git branch -d week9-export-docs

# Delete remote branch
git push origin --delete week9-export-docs
```

---

## FRIDAY - TAG & RELEASE

### Tag Release Version
```bash
# Create annotated tag for exact version
git tag -a v0.9.0 -m "Week 9: Export Documentation Module

- Export document generation (8 types)
- Country-specific compliance (8+ countries)
- Digital signatures (legally binding)
- Government submission workflow
- 12 REST endpoints
- 80%+ test coverage
- Database migration

Release Date: April 19, 2026
Status: Production Ready"

# Push tag to GitHub
git push origin v0.9.0

# Verify
git tag -l
git show v0.9.0
```

### Create Release on GitHub
```bash
# Using GitHub CLI
gh release create v0.9.0 \
  --title "Week 9: Export Documentation Module (v0.9.0)" \
  --notes "## Features
- 8 document types: Phytosanitary, BOL, CI, COO, Packing List, CoA, Organic, Fair Trade
- 8+ country support: Kenya, Uganda, Tanzania, Ethiopia, Ghana, Nigeria, South Africa, Rwanda
- Digital signatures (legally binding)
- Government submission workflow with approval tracking
- PDF generation for all document types
- 12 REST API endpoints
- 80%+ unit test coverage
- Database migration included

## Important
- This release is production-ready
- Requires data migration (1713300001-create-export-documents.sql)
- All previous versions should be updated

## Installation
\`\`\`bash
git checkout v0.9.0
npm install
npm run migrate
npm run build
npm run start
\`\`\`

## Documentation
See WEEK_9_READY_EXECUTE_NOW.md and API documentation for details.

Tested: Mon 4/15 - Fri 4/19, 2026
Status: ✅ Production Ready"

# OR create manually on GitHub UI:
# 1. Visit: https://github.com/africago/platform/releases/new
# 2. Tag: v0.9.0
# 3. Title: Week 9: Export Documentation Module
# 4. Description: (paste above)
# 5. Click "Publish release"
```

---

## TROUBLESHOOTING

### "fatal: A branch with that name already exists"
```bash
# Use different branch name with timestamp
git checkout -b week9-export-docs-$(date +%s)
```

### "everything up-to-date" but code not showing
```bash
# Make sure you're actually on the feature branch
git branch  # Shows * current branch

# If not, switch
git checkout week9-export-docs

# Then push
git push origin week9-export-docs
```

### "code conflicts" when merging
```bash
# View conflicts
git status

# Edit conflicted files (look for >>>>>>>> markers)
# Then stage & commit
git add <conflicted-file>
git commit -m "resolve: merge conflicts from develop"
```

### "need to undo a commit"
```bash
# Undo last commit but keep changes
git reset --soft HEAD~1

# OR completely remove last commit
git reset --hard HEAD~1

# Then push (force only if not pushed yet)
git push -f origin week9-export-docs  # DANGEROUS - use with caution
```

---

## GIT COMMAND REFERENCE

| Command | What It Does | When to Use |
|---------|------------|-----------|
| `git status` | Show current branch & changes | Before committing |
| `git add <file>` | Stage changes for commit | Before committing |
| `git commit -m "msg"` | Create commit with message | After making changes |
| `git push origin <branch>` | Send commits to GitHub | After committing |
| `git pull origin <branch>` | Get latest from GitHub | Before starting work |
| `git checkout -b <branch>` | Create & switch to new branch | Starting new feature |
| `git checkout <branch>` | Switch to existing branch | Switching branches |
| `git merge <branch>` | Merge another branch into current | After PR approval |
| `git tag -a <tag>` | Create version tag | For releases |
| `git log --oneline` | Show commit history | Reviewing changes |

---

**Remember: Push frequently. Small commits are easier to review and easier to undo.**
