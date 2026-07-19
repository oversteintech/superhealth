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

  /// Standard After overrides — add auth/analytics/push adapters as the app grows.
  static List<Override> createSuperHealthAfterOverrides(
    SharedPreferences preferences,
  ) {
    ensureConfigured();
    return AfterStandardOverrides.create(
      preferences: preferences,
      userAgent: 'SuperHealth/0.1.0',
    );
  }
}
