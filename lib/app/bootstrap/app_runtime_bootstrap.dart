import 'package:after_core/after_core.dart';
import 'package:after_firebase/after_firebase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/src/internals.dart' show Override;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../config/feature_flag_keys.dart';
import '../config/remote_config_keys.dart';
import '../l10n/app_strings.dart';
import '../l10n/string_catalog.dart';
import '../platform/crash_reporting.dart';
import '../platform/firebase_options.dart';

class BootstrapSnapshot {
  const BootstrapSnapshot({
    required this.preferences,
    required this.catalog,
  });

  final SharedPreferences preferences;
  final StringCatalog catalog;
}

abstract final class AppRuntimeBootstrap {
  static Future<BootstrapSnapshot> load() async {
    await AfterFirebaseBootstrap.ensureInitialized(
      options: DefaultFirebaseOptions.currentPlatform,
      preferLocalFallback: DefaultFirebaseOptions.isPlaceholder,
    );

    final preferences = await SharedPreferences.getInstance();
    final catalog = await StringCatalog.load();
    final savedLocale = preferences.getString('superhealth.locale');
    if (savedLocale != null) {
      catalog.setLocale(savedLocale);
    }
    return BootstrapSnapshot(preferences: preferences, catalog: catalog);
  }

  static List<Override> overrides(BootstrapSnapshot snapshot) {
    return [
      stringCatalogProvider.overrideWithValue(snapshot.catalog),
    ];
  }

  static Future<void> warm(ProviderContainer container) async {
    final logger = container.read(afterLoggerProvider);
    CrashReporting.install(logger);

    final flags = container.read(afterFeatureFlagsProvider);
    if (flags is PrefsAfterFeatureFlags) {
      await flags.setLocalBool(FeatureFlagKeys.aiAssistant, true);
      await flags.setLocalBool(FeatureFlagKeys.vitalsCharts, true);
      await flags.setLocalBool(FeatureFlagKeys.medicationReminders, true);
      await flags.setLocalBool(FeatureFlagKeys.premiumUpsell, true);
      await flags.setLocalBool(FeatureFlagKeys.offlineSync, true);
    }

    final remote = container.read(afterRemoteConfigProvider);
    if (remote is CachedAfterRemoteConfig) {
      await remote.hydrateFromJson({
        RemoteConfigKeys.welcomeMessage: 'Your health, calmly organized.',
        RemoteConfigKeys.aiSystemPrompt:
            'You are SuperHealth Mate, a careful health assistant. '
            'You never diagnose. Encourage professional care when needed.',
        RemoteConfigKeys.maintenanceMode: false,
        RemoteConfigKeys.minSupportedBuild: AppConfig.versionCode,
      });
    }

    final analytics = container.read(afterAnalyticsProvider);
    await analytics.logEvent('app_warm_complete');
    logger.i('SuperHealth warm bootstrap complete');
  }
}