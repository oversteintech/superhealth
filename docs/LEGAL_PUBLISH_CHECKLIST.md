# Super Health — legal / product publish checklist

**Status:** Requires legal + product sign-off before any store claim.  
**This app is not certified medical device / EHR / diagnostic software.** Do not claim CE MDR, FDA, ISO 13485, or similar without a completed regulatory pathway.

## A. Health data & privacy (every launch market)

| # | Obligation | Owner | Status |
|---|------------|-------|--------|
| A1 | Privacy policy describes categories stored, purposes, retention, export/delete | Legal + Product | **Pending approval** |
| A2 | In-app consent versioning (`ConsentVersions.current`) matches published policy | Engineering + Legal | Implemented skeleton — **Pending approval** |
| A3 | Sensitive notification bodies hidden by default | Engineering | Implemented |
| A4 | Analytics/AI payloads sanitized (no clinical free text) | Engineering | Implemented + tested |
| A5 | Cloud vs on-device storage clearly disclosed | Product | In-app clarity banner — **Pending approval** |
| A6 | Data export + delete all local health data | Engineering | Implemented |
| A7 | Emergency card lock-screen fields separate consent | Engineering | Implemented |

## B. Medical software / device regulation

| # | Question | Decision rule |
|---|----------|---------------|
| B1 | Does the app provide diagnosis, treatment, dosage calculation, or triage? | **Must remain No** for current product |
| B2 | Are reference ranges presented as personal medical thresholds? | **Must remain No** |
| B3 | Is a composite “health score” marketed as clinical? | **Must remain No** |
| B4 | Wearable import claimed as medical-grade? | **Demo only** until validated adapter + labeling review |
| B5 | Local market medical device / SaMD classification needed? | **Legal decision per country** before claiming clinical use |

## C. Children’s data

| # | Obligation | Status |
|---|------------|--------|
| C1 | Default single-user adult assumption for P0/P1 | Documented |
| C2 | Care circle dependent-child role requires guardian consent UX + legal text | **Pending legal** |
| C3 | Age gate / parental consent for under-13 / under-16 (market-dependent) | **Pending legal** |
| C4 | No behavioral ads targeting children | Product policy — **Pending approval** |

## D. Store / region

| # | Item | Status |
|---|------|--------|
| D1 | App Store / Play health data questionnaire (`STORE_DATA_DECLARATION.md`) | Draft — **Pending ops** |
| D2 | Turkey KVKK disclosures if processing TR users | **Pending legal** |
| D3 | EU GDPR / UK GDPR DPIA if required by processing scale | **Pending legal** |
| D4 | US state privacy / HIPAA: only if covered entity / BA relationship | **Not claimed** |

## Sign-off

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Product | | | |
| Legal | | | |
| Engineering | | | |

Unverified certification claims are forbidden in copy, screenshots, and store listings.
