# SuperHealth

**AfterArtificial Super App** for personal health management.

Powered by **After Framework** Â· Built by **Overstein Labs**

| | |
|---|---|
| Package | `com.overstein.superhealth` |
| App ID | `super_health` |
| Pub name | `super_health` |
| Domain | Health Management |
| Flagship reference | [SuperGarage](https://github.com/oversteintech/supergarage) |

## Brand hierarchy

```
Ayhan Uzundal
  â†’ AfterArtificial          (product company / Super Apps)
      â†’ SuperHealth
  â†’ Powered by After Framework
  â†’ Built by Overstein Labs
```

## Architecture

SuperHealth follows the After Framework Super App contract used by SuperGarage:

- Composition root: `lib/app/platform/after_framework.dart`
- Cold start: Overstein splash â†’ prefs / strings â†’ AuthGate â†’ MainShell
- Vertical code only under `lib/features/`
- Shared ports from `after_core` (auth, analytics, flags, remote config, secure storage, HTTP, entitlements, AI vault)
- UI from `after_design_system`
- State: Riverpod
- Feature-first folders with domain / data / presentation layers

### Features (production skeleton)

Splash Â· Onboarding Â· Authentication Â· Dashboard Â· Vitals Â· AI Assistant Â· Search Â· Notifications Â· Profile Â· Settings Â· Membership Â· Medications Â· Appointments Â· Wellness

### Branding

Launcher icon: unique **S+** monogram (family style with SuperGarage SG). Assets live under `assets/branding/` and Android/iOS launcher icons are generated via `dart run flutter_launcher_icons`.

Cross-cutting: Localization Â· Theme Â· Offline banner Â· Analytics Â· Crash reporting Â· Remote config Â· Feature flags Â· Secure storage Â· Navigation Â· DI Â· Networking Â· Logging Â· Error handling

Business data is realistic **mock** data via `MockHealthRepository` â€” swap for live APIs without changing screens.

## Repository layout

```
HANTURAI/
  supercore/          # after_core + after_design_system
  superhealth/        # this app
```

## Getting started

```bash
cd superhealth
flutter pub get
flutter run
```

Demo sign-in (prefs-backed auth accepts any email):

- Email: `member@afterartificial.com`
- Password: any non-empty value

### Sign in as Super Admin

Sign in with **Google** using `ayhanuzundal@gmail.com` (or any allowlisted
`overstein.com` admin address). Membership auto-elevates to `SUPER ADMIN`
(`AfterUserPlan.superadmin`) with every `AfterPlanFeature` unlocked. The
allowlist lives in `AfterSuperAdmin.emails` (after_core).

> Google Sign-In requires the Google Cloud OAuth client to be configured for
> `com.overstein.superhealth` (or the current package id if not yet migrated)
> plus the correct SHA-1 fingerprint. Tests pass `mockGoogleEmailForTests`
> to `PrefsGoogleAuthRepository` /
> `AfterFramework.createSuperHealthAfterOverrides` to bypass the plugin.

## Tests

```bash
flutter test
flutter analyze
```

## Documentation

- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
- [docs/AFTER_FRAMEWORK.md](docs/AFTER_FRAMEWORK.md)
- [docs/FEATURES.md](docs/FEATURES.md)
- SuperCore: [STANDARD_APIS.md](../supercore/STANDARD_APIS.md)

## CI

GitHub Actions checks out `oversteintech/supercore` as a sibling and runs format, analyze, test, and a debug APK build.