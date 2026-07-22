# After Framework compliance — SuperHealth

| Requirement | Status |
|-------------|--------|
| Depend on `after_core` + `after_design_system` | Yes |
| Unique `AppPlatformManifest` | `com.afterartificial.superhealth` |
| Composition root `createSuperHealthAfterOverrides` | Yes |
| `PlatformConfig.current` before runApp | Yes |
| Auth behind After port | `MockAuthRepository` (swap for Firebase/Supabase) |
| Analytics behind After port | `ProductAnalytics` |
| Feature flags | `PrefsAfterFeatureFlags` |
| Remote config | `CachedAfterRemoteConfig` |
| Secure storage | After secure storage facade |
| HTTPS Dio policy | After standard overrides |
| Theme from `AfterThemeData` | `SuperHealthTheme` |
| Vertical features under `lib/features/` | Yes |
| Smoke tests | `test/after_framework_smoke_test.dart` |
| CI format / analyze / test | `.github/workflows/ci.yml` |

Do not invent parallel platform kits. Extend SuperCore ports instead.