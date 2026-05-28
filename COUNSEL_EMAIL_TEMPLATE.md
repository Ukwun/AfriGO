# EMAIL TEMPLATE - SEND TO LEGAL COUNSEL
## Use this exact format to send documents for review

---

### EMAIL SUBJECT:
```
URGENT: AfriGo Legal Documents Review (3 docs, 48-hour turnaround)
```

---

### EMAIL BODY:

```
Dear [COUNSEL NAME/FIRM],

I hope this message finds you well. 

I'm reaching out on behalf of AfriGo Inc. as we prepare to launch our agricultural 
e-commerce platform serving 500+ farmers and buyers in East Africa. 

We need your legal review and sign-off on three critical documents before we can 
publish them and launch our MVP on May 9, 2026.

DOCUMENTS FOR REVIEW (attached PDF files):
1. LEGAL_PRIVACY_POLICY.md
   - 14 sections covering GDPR, CCPA, Kenya Data Protection Act (2019)
   - Addresses: data collection, usage, user rights, retention, security
   - Current status: 95% complete

2. LEGAL_TERMS_OF_SERVICE.md
   - 20 sections covering user obligations, payment, disputes, liability
   - Addresses: account creation, prohibited conduct, escrow payments, arbitration
   - Current status: 100% complete

3. COMPLIANCE_COUNTRY_MATRIX.md
   - Regulatory requirements for 8 target countries
   - Addresses: money transmission licensing, KYC/AML, tax, data localization
   - Current status: 100% complete

TIMELINE:
- Submitted: [DATE AT TIME] EAT
- Review needed by: Wednesday, April 17 @ 5:00 PM EAT (48 hours)
- Publication planned: Thursday, April 18, 2026
- MVP Launch: Friday, May 9, 2026 (500 users)

KEY QUESTIONS FOR YOUR REVIEW:

1. PRIVACY POLICY
   - Does our data handling comply with GDPR Article 5-22 (Kenya-focused)?
   - Is our user right implementation (deletion, portability, access) sufficient?
   - Do we need additional CCPA language for US-based users?
   - Are our data retention schedules (6 years for transactions) appropriate?

2. TERMS OF SERVICE
   - Is our dispute resolution process (negotiation → mediation → arbitration) enforceable?
   - Are our liability caps ($X = 12-month fees) legally sound?
   - Is our chargeback fraud penalty / account suspension enforceable?
   - Should we add additional clauses for government compliance?

3. COMPLIANCE FRAMEWORK
   - Are our country-specific requirements (KYC thresholds, licensing) accurate?
   - Do we need separate legal review for Kenya vs Uganda vs other countries?
   - Should we prepare company incorporation documentation?

PLATFORM CONTEXT:
- Platform: Agricultural marketplace (farmers sell, buyers purchase)
- Users: Smallholder farmers, agricultural cooperatives, buyers, processors
- USP: Escrow-based payments, quality testing, export documentation, trust scoring
- Primary markets: Kenya, Uganda, Tanzania, Ethiopia, Ghana, Nigeria
- MVP Launch: 500 farmers + 200 buyers (May 9, 2026)

FEES & TERMS:
- Platform fee: 2-3% of transaction value
- Payment processing: 1.5% (Flutterwave)
- Escrow: Buyer pays AfriGo first, released to seller after buyer confirmation
- Minimum dispute resolution: 30 days negotiation, then mediation, then arbitration

DESIRED DELIVERABLES:
After your review, we would appreciate:

1. Mark-ups/comments directly on documents highlighting recommended changes
2. Written response addressing the 3 key questions above
3. Go/No-Go decision on each document (can we publish as-is?)
4. Any critical compliance gaps we should address immediately
5. Recommended next steps for ongoing legal compliance

CONTACT INFO:
- Name: [YOUR NAME]
- Phone: [YOUR PHONE]
- Email: [YOUR EMAIL]
- Available: Monday-Friday 8 AM - 6 PM EAT

If you have any clarification questions before starting the review, please reach out 
immediately. We're available for a quick call if needed to discuss the business model 
in more detail.

Thank you for your urgent attention to this matter. We're excited to have your 
guidance as we launch this important platform serving African farmers.

Best regards,

[YOUR NAME]
[YOUR TITLE]
AfriGo Inc.

---

Phone: +254 700 XXXXX
Email: legal@afrigo.app
Office: [YOUR OFFICE ADDRESS]
```

---

## INSTRUCTIONS FOR SENDING

### Step 1: Prepare Attachments
```bash
# Convert markdown to PDF for cleaner delivery
# Option A: Use markdown viewer that exports to PDF
# Option B: Use online converter like Pandoc

pandoc LEGAL_PRIVACY_POLICY.md -o LEGAL_PRIVACY_POLICY.pdf
pandoc LEGAL_TERMS_OF_SERVICE.md -o LEGAL_TERMS_OF_SERVICE.pdf
pandoc COMPLIANCE_COUNTRY_MATRIX.md -o COMPLIANCE_COUNTRY_MATRIX.pdf
```

### Step 2: Send Email
- [ ] Copy email body above into Gmail/Outlook
- [ ] Substitute [BRACKETED SECTIONS] with real information
- [ ] Attach all three PDF files
- [ ] Set importance: HIGH
- [ ] Request read receipt
- [ ] Click SEND

### Step 3: Follow Up
- [ ] Record email sent time: ___:___
- [ ] Add "Waiting for counsel response" to calendar
- [ ] Create reminder for Wednesday 4 PM (if no response)
- [ ] Have backup counsel contact ready

---

## IF NO RESPONSE BY WEDNESDAY 4 PM

**Escalation Plan (if counsel is slow):**

1. **Call at 4:30 PM:** "Hi [Name], I sent legal documents Monday for 48-hour review. 
   Can you confirm you received them and give me timeline for feedback?"

2. **If >24 hours response time:** Contact backup counsel
   - Backup Counsel #1: [CONTACT]
   - Backup Counsel #2: [CONTACT]
   - (Have 2 backups identified before Monday)

3. **If counsel can't review by Wednesday:** 
   - Ask for partial approval (approve what's ready)
   - Defer non-critical sections to Week 10
   - Get emergency approval for Terms (most critical)

4. **Worst case (no counsel by Thursday):**
   - In-house legal review by non-lawyer (product/exec team)
   - Document that counsel review is "in progress"
   - Publish "Draft" version with prominent "Legal Review in Progress" banner
   - Plan full review for Week 10

---

## COUNSEL CONTACT LOG

| Date | Contact | Method | Topic | Response | Next |
|------|---------|--------|-------|----------|------|
| 4/15 | [Name] | Email | Submit 3 docs | Pending | Follow up Wed 4 PM |
| | | | | | |
| | | | | | |

---

## EXPECTED RESPONSES & TIMELINE

**BEST CASE** (Counsel responds Wednesday 10 AM):
- Documents approved with minor notes
- Implementation time: 2-3 hours Thursday morning
- Thursday PM: Publish documents
- Friday: Go live ✅

**NORMAL CASE** (Counsel responds Wednesday 3 PM):
- Documents approved with some notes
- Implementation time: 4-5 hours Thursday
- Friday morning: Publish documents
- Friday: Go live (slightly tight) ✅

**WORST CASE** (Counsel responds Thursday morning):
- Critical changes needed
- Work through Thursday + Friday
- May delay MVP launch 1-2 weeks
- But: Much better than legal liability ⚠️

---

**Remember: Legal compliance is NOT negotiable.**
**It's better to delay launch than launch with legal exposure.**
**When in doubt,ASK COUNSEL.**
