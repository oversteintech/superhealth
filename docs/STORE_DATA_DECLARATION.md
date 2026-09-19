# Super Health — store data safety declaration (draft)

Fill store consoles with these answers. Update when processing changes.  
**Not a certification.** Align with `LEGAL_PUBLISH_CHECKLIST.md` before submission.

## Data collected (user-controlled)

| Type | Collected? | Linked to identity? | Used for tracking? | Notes |
|------|------------|---------------------|--------------------|-------|
| Health | Yes (user-entered / optional import) | Yes (account) | No | On-device first; cloud only with consent + paid sync |
| Sensitive info (allergies on emergency card) | Optional | Yes | No | Default off |
| Contact info | Optional (auth email, emergency contact) | Yes | No | |
| Identifiers | Device / install | Yes | No | Crash / analytics ids — no clinical payload |
| Usage data | Feature flags, screen names | Pseudonymous | No | Sanitized analytics |
| Diagnostics | Crash logs | Pseudonymous | No | Must not include notes/vitals |

## Data not collected

- Precise clinical device streams until a validated adapter ships  
- Government ID / national ID (never required)  
- Payment card PAN (store IAP handles billing)  

## Purposes

- App functionality (personal health diary)  
- Account sync (optional, disclosed)  
- Analytics (product improvement — no sale of health records)  

## User rights

- Export JSON from Privacy & security  
- Delete local health data from Privacy & security  
- Revoke share grants; revoke care invites  

## Third parties

- After Framework / Firebase placeholders until ops cutover — disclose actual processors in the live privacy policy  

## Health declarations

- App does **not** provide medical advice, diagnosis, or treatment  
- Not a regulated medical device in the current skeleton  

Ops must re-validate this table against the live privacy policy URL before each store release.
