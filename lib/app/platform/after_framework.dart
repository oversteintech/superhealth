import 'package:after_core/after_core.dart';
import 'package:riverpod/src/internals.dart' show Override;
import 'package:shared_preferences/shared_preferences.dart';

import 'manifest.dart';

/// After Framework composition root for SuperHealth.
abstract final class AfterFramework {
  static var _configured = false;

  static void ensureConfigured() {
    if (_configured) return;
    PlatformConfig.current = superHealthManifest;
    _configured = true;
  }

  /// Minimal overrides — replace stubs with Firebase/store adapters as the app grows.
  static List<Override> createSuperHealthAfterOverrides(
    SharedPreferences preferences,
  ) {
    ensureConfigured();
    return [
      afterSharedPreferencesProvider.overrideWithValue(preferences),
      afterHttpPolicyProvider.overrideWithValue(
        const AfterHttpPolicy(
          requireHttps: true,
          userAgent: 'SuperHealth/0.1.0',
        ),
      ),
      afterFeatureFlagsProvider.overrideWith((ref) {
        return PrefsAfterFeatureFlags(
          SharedPreferencesAfterStore(preferences),
        );
      }),
      afterRemoteConfigProvider.overrideWith((ref) {
        return CachedAfterRemoteConfig(
          SharedPreferencesAfterStore(preferences),
        );
      }),
      afterLocalNotificationsProvider.overrideWith(
        (ref) => FlutterAfterLocalNotifications(),
      ),
      afterAiCredentialVaultProvider.overrideWith((ref) {
        return AfterAiCredentialVault(ref.watch(afterSecureStorageProvider));
      }),
      afterLoggerProvider.overrideWithValue(const ConsoleAfterLogger()),
    ];
  }
}
