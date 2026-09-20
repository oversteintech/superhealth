# SuperHealth — Compliance report (skeleton)

## Fixed (family skeleton)

- Bundle / package: `com.overstein.*`
- After Framework composition + family chrome shell
- Feature CRUD via `after_consumer` Family kit
- Home dashboard uses `sortFamilyDashboardSections`
- Locales: `AfterSupportedLocales` (≥20) with English stub assets where applicable
- Membership: `AfterUserPlan` / `FamilyMembershipController` (store IAP ports swappable)

## Accepted deferrals

- Real Play/App Store IAP (NoOp / prefs plan switch)
- Firebase Auth/Firestore/Crashlytics production projects
- Drift / remote repositories
- Full professional translations (English stubs OK)
- APK install / store flavors

## Notes

Generated for SuperGarage family parity gate. Update when shipping beyond mock.

## Product plan (2026-09-19)

- `docs/PRODUCT_PLAN.md` — P0/P1/P2, rıza matrisi, AI sınırı.
- First safe slice: timeline, user-scoped observations + tombstones, AI does not receive records by default, emergency card off, no composite health score.
- Not a medical device / diagnostic product.

## P0 personal records (2026-09-19)

- Domain: profile, observation, habit, symptom, medication+adherence, appointment, document, emergency card.
- Local DB: `HealthDriftSchema` + `PrefsHealthLocalDatabase` (Garage sync columns / tombstones / offline queue). Full `@DriftDatabase` codegen deferred until native CI assets unblock (same table names).
- Features: measurements, routines, meds taken/snooze/skip, appointments, document vault, consent onboarding, emergency enable + lock-screen consent.
- No BMI/health-score on dashboard; sensitive notification body redacted.

## P1 trends / sharing / import (2026-09-19)

- Trends: gap markers, no interpolation; source on each point.
- ShareGrant CSV/PDF-text with expiry + revoke + audit (no clinical values in audit metadata).
- CareCircleMember default empty field allow-list.
- `WearableImportPort` + Demo adapter (labeled Demo); fingerprint dedupe.
- Mate: `HealthAiInAppRouteCatalog` first; `SelectedRecordExplainer` only with explicit ids.

## P3 membership / privacy / publish (2026-09-19)

- `HealthEntitlementMatrix`: Free keeps personal records; Silver/Gold/Business map After plans; care circle Gold+.
- Privacy lock PIN, notification body hide, screenshot prefer, clear-on-signout, consent versioning, export/delete, access log UI.
- Analytics sanitizer; `docs/LEGAL_PUBLISH_CHECKLIST.md` + `docs/STORE_DATA_DECLARATION.md` (no certification claims).
- Cloud storage clarity banner — optional sync, not a clinical archive.

## Garage-parity family chrome (2026-07-20)

- Login / registration: shared `FamilyLoginScreen` + `FamilyRegistrationWizardScreen` (`after_consumer`)
- Themes: full Garage pack via `AfterThemeStyle` + `AfterPremiumAppShell` (`after_design_system`)
- Settings / Profile: shared `FamilySettingsScreen` / `FamilyProfileScreen` with plugin slots

## Google Auth + Cloud Sync (2026-07-20)

- Auth: `PrefsGoogleAuthRepository` via `familyPrefsGoogleAuthOverride` (real Google Sign-In; CI uses `mockGoogleEmailForTests`)
- Sync: `AfterUserBlobSyncPort` + `FamilyCloudSyncController`; default `PrefsAfterUserBlobSync`; AuthGate wraps `FamilySessionEffects`
- Settings: Sync now + 20-locale language picker (`AfterSupportedLocales`, full `assets/l10n/*.json` parity with `en`, contract test in `test/app/l10n/`)
- Quality: `flutter test --coverage` + `dart tool/check_coverage.dart 80` in CI; smoke suite `test/smoke/`
- Ops: see supercore `docs/GOOGLE_AND_SYNC_SETUP.md` for OAuth / Firebase cutover

## Firebase Auth + Firestore blob (after_firebase)

- Wired `after_firebase` composition-root adapters via `AfterFirebaseBootstrap`
- Placeholder `firebase_options.dart` + `google-services.json.placeholder` until ops registers the app
- Cold start calls `ensureInitialized` with `preferLocalFallback` while options are placeholder (Prefs auth + Prefs blob)
- Real Firebase Auth / Firestore cutover: replace options + JSON; see supercore `docs/GOOGLE_AND_SYNC_SETUP.md`
