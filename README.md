# SuperHealth

**Status:** Scaffold on After Framework  
**Company:** AfterArtificial  
**Packages:** [`oversteintech/supercore`](https://github.com/oversteintech/supercore)  
**Docs:** [afterframework.com/start](https://www.afterframework.com/start)

Personal health Super App — vertical features under `lib/features/`. Shared auth, AI, premium, networking, and design system come from After Framework.

## Layout

```text
HANTURAI/
  supercore/
  superhealth/   # this repo
  supergarage/   # flagship reference
```

## Run

```bash
flutter pub get
flutter test
flutter run
```

## Composition root

- `lib/app/platform/manifest.dart` — `AppPlatformManifest`
- `lib/app/platform/after_framework.dart` — provider overrides
- `lib/main.dart` — cold start + `ProviderScope`

## Next

- [ ] Auth adapter (Firebase / Supabase)
- [ ] Entitlements bridge
- [ ] Health feature modules
- [ ] Store flavors + listings
