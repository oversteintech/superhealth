# SuperHealth architecture

## Layers

```
lib/
  main.dart
  app/                 # bootstrap, theme, l10n, navigation, membership, platform
  core/                # reserved for Drift / sync (parity with SuperGarage)
  data/                # repositories, mock data, API client, providers
  domain/              # entities + repository ports
  features/            # feature-first UI + controllers
```

## Startup

1. `main` → `AfterFramework.ensureConfigured()` + crash zone
2. `SuperHealthColdStart` shows Overstein splash
3. Load SharedPreferences + StringCatalog
4. `ProviderContainer` with bootstrap + After overrides
5. Warm: feature flags, remote config, analytics
6. `AuthGate` → login / onboarding / `MainShell`

## Navigation

Imperative Material navigation (SuperGarage pattern):

- `AuthGate` state machine
- `MainShell` + `MainTab` Riverpod notifier
- Pushed routes for notifications, settings, membership

## DI

Riverpod providers. After ports overridden in `createSuperHealthAfterOverrides`.

## Offline

`connectivity_plus` drives an offline banner. Mock repository acts as the local cache for the skeleton.

## Membership

`MembershipController` maps to `AfterUserPlan` / `AfterEntitlement` and overrides `afterEntitlementProvider`.