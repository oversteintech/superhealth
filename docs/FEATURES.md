# SuperHealth core features

Domain: **Personal health diary** (not diagnosis / treatment / medical device)

## Always free (no paywall)

| Feature | Path |
|---------|------|
| Timeline | `features/timeline/` |
| Measurements | `features/observations/` |
| Routines | `features/habits/` |
| Medication + adherence | `features/medications/` |
| Appointments | `features/appointments/` |
| Document vault | `features/documents/` |
| Profile | `features/profile/` |
| Trends (gaps not filled) | `features/trends/` |
| Sharing CSV/PDF + revoke | `features/sharing/` |
| Wearable import (Demo) | `features/wearable/` |
| Emergency card (default off) | `features/profile/` + emergency |
| Privacy / export / delete | `features/privacy/` |
| Health AI (limited, selected records) | `features/assistant/` |

## Plan-gated (Silver / Gold / Business)

| Capability | Free | Silver | Gold | Business |
|------------|------|--------|------|----------|
| Personal records | ✓ | ✓ | ✓ | ✓ |
| Premium themes | | ✓ | ✓ | ✓ |
| PDF export extras | | ✓ | ✓ | ✓ |
| Unlimited Mate | | | ✓ | ✓ |
| Care circle invites | | | ✓ | ✓ |
| Full cloud sync | | | ✓ | ✓ |
| Org / fleet dashboard | | | | ✓ |

Legacy Family CRUD kit screens remain under `features/family_crud/` for Garage parity.
