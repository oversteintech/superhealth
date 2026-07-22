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

## Garage-parity family chrome (2026-07-20)

- Login / registration: shared `FamilyLoginScreen` + `FamilyRegistrationWizardScreen` (`after_consumer`)
- Themes: full Garage pack via `AfterThemeStyle` + `AfterPremiumAppShell` (`after_design_system`)
- Settings / Profile: shared `FamilySettingsScreen` / `FamilyProfileScreen` with plugin slots

## Google Auth + Cloud Sync (2026-07-20)

- Auth: `PrefsGoogleAuthRepository` via `familyPrefsGoogleAuthOverride` (real Google Sign-In; CI uses `mockGoogleEmailForTests`)
- Sync: `AfterUserBlobSyncPort` + `FamilyCloudSyncController`; default `PrefsAfterUserBlobSync`; AuthGate wraps `FamilySessionEffects`
- Settings: Sync now + 20-locale language picker
- Quality: `flutter test --coverage` + `dart tool/check_coverage.dart 50` in CI
- Ops: see supercore `docs/GOOGLE_AND_SYNC_SETUP.md` for OAuth / Firebase cutover

## Firebase Auth + Firestore blob (after_firebase)

- Wired `after_firebase` composition-root adapters via `AfterFirebaseBootstrap`
- Placeholder `firebase_options.dart` + `google-services.json.placeholder` until ops registers the app
- Cold start calls `ensureInitialized` with `preferLocalFallback` while options are placeholder (Prefs auth + Prefs blob)
- Real Firebase Auth / Firestore cutover: replace options + JSON; see supercore `docs/GOOGLE_AND_SYNC_SETUP.md`
