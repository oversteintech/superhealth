import 'package:after_ai/after_ai.dart';
import 'package:after_consumer/after_consumer.dart';
import 'package:after_core/after_core.dart';
import 'package:after_firebase/after_firebase.dart';
import 'package:riverpod/src/internals.dart' show Override;
import 'package:shared_preferences/shared_preferences.dart';

import '../family/family_stores.dart';
import 'adapters/product_analytics.dart';
import 'manifest.dart';

/// After Framework composition root for SuperHealth.
abstract final class AfterFramework {
  static var _configured = false;

  static void ensureConfigured() {
    if (_configured) return;
    PlatformConfig.current = superHealthManifest;
    _configured = true;
  }

  static List<Override> createSuperHealthAfterOverrides(
    SharedPreferences preferences, {
    String? mockGoogleEmailForTests,
  }) {
    ensureConfigured();
    return [
      ...AfterStandardOverrides.create(
        preferences: preferences,
        userAgent: 'SuperHealth/0.1.0',
        includeUserBlobSync: false,
      ),
      ...AfterFirebaseBootstrap.overrides(
        preferences: preferences,
        appId: superHealthManifest.appId,
        mockGoogleEmailForTests: mockGoogleEmailForTests,
      ),
      afterAnalyticsProvider.overrideWith(
        (ref) => ProductAnalytics(ref.watch(afterLoggerProvider)),
      ),
      afterAiProfileProvider.overrideWithValue(
        AfterAiProfile(
          appId: superHealthManifest.appId,
          enabled: const {
            AfterAiCapability.conversation,
            AfterAiCapability.summarization,
            AfterAiCapability.recommendation,
          },
        ),
      ),
      afterEntitlementProvider.overrideWith((ref) {
        return ref.watch(healthMembershipProvider).entitlement;
      }),
    ];
  }
}
