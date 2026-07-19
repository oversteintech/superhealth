# SuperHealth

**Status:** Scaffold · next Super App after SuperGarage  
**Company:** AfterArtificial  
**Platform:** [After Framework](https://www.afterframework.com)  
**Engineering:** Overstein Labs

## Intent

Personal health Super App on After Framework — vertical features only; shared auth, AI, premium, design system, networking come from `after_core` + `after_design_system`.

## Bootstrap (when development starts)

1. Depend on After packages (from SuperGarage `packages/` until `oversteintech/supercore` is extracted).
2. Set `AppPlatformManifest` (unique package / bundle IDs, store flavors).
3. Create composition root mirroring SuperGarage `lib/app/platform/after_framework.dart`.
4. Override After Riverpod providers with product adapters.
5. Ship features under `lib/features/` only.
6. Follow [Platform Standard](https://www.afterframework.com/standard) checklist.

## Do not

- Fork auth / networking / premium kits
- Rebuild design tokens from scratch
- Skip server-verified entitlements or HTTPS Dio policy

## Related

| Resource | URL |
|----------|-----|
| Products | https://www.afterartificial.com |
| Framework | https://www.afterframework.com |
| Labs | https://www.overstein.com |
| Reference app | SuperGarage (`oversteintech/supergarage`) |
| Shared packages | `oversteintech/supercore` (target) |
