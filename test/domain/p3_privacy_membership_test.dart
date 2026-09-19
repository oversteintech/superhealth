import 'package:after_core/after_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_health/app/platform/adapters/product_analytics.dart';
import 'package:super_health/data/local/health_records_repository.dart';
import 'package:super_health/data/local/prefs_health_local_database.dart';
import 'package:super_health/domain/entities/health_feature.dart';
import 'package:super_health/domain/membership/health_entitlement_matrix.dart';
import 'package:super_health/domain/privacy/ai_safety_policy.dart';
import 'package:super_health/domain/privacy/consent_registry.dart';
import 'package:super_health/domain/privacy/data_lifecycle_service.dart';
import 'package:super_health/domain/privacy/privacy_preferences.dart';
import 'package:super_health/domain/privacy/sensitive_payload_filter.dart';
import 'package:super_health/domain/records/consent_grant.dart';
import 'package:super_health/domain/records/observation.dart';

void main() {
  test('personal health features stay free on every plan', () {
    for (final plan in AfterUserPlan.values) {
      for (final id in HealthEntitlementMatrix.freePersonalRecords) {
        expect(
          HealthEntitlementMatrix.canOpenFeature(plan: plan, id: id),
          isTrue,
          reason: '$id must stay open on $plan',
        );
      }
    }
    expect(
      HealthEntitlementMatrix.canOpenFeature(
        plan: AfterUserPlan.free,
        id: HealthFeatureId.caregivers,
      ),
      isFalse,
    );
    expect(
      HealthEntitlementMatrix.canOpenFeature(
        plan: AfterUserPlan.superPlan,
        id: HealthFeatureId.caregivers,
      ),
      isTrue,
    );
    final gold = HealthEntitlementMatrix.entitlementFor(AfterUserPlan.superPlan);
    expect(gold.canUse(AfterPlanFeature.aiUnlimited), isTrue);
    expect(
      HealthEntitlementMatrix.entitlementFor(AfterUserPlan.free)
          .canUse(AfterPlanFeature.aiUnlimited),
      isFalse,
    );
  });

  test('analytics and AI payloads drop clinical content', () async {
    final analytics = ProductAnalytics(const ConsoleAfterLogger());
    await analytics.logEvent(
      'share.create',
      parameters: {
        'plan': 'free',
        'note': 'penicillin allergy',
        'glucose': '180 mg/dl',
        'format': 'csv',
      },
    );
    final event = analytics.events.single;
    expect(event.containsKey('note'), isFalse);
    expect(event.containsKey('glucose'), isFalse);
    expect(event['format'], 'csv');
    expect(event['plan'], 'free');

    expect(
      SensitivePayloadFilter.containsSensitive({
        'body': 'Take penicillin dose',
      }),
      isTrue,
    );
    final ai = AiSafetyPolicy.buildPayload(
      userMessage: 'hello',
      selectedRecordIds: const ['x'],
      userExplicitlySelectedRecords: true,
    ).toAnalyticsFields();
    expect(SensitivePayloadFilter.containsSensitive(ai), isFalse);
  });

  test('consent versioning and privacy prefs persist', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final registry = ConsentRegistry(prefs);
    final privacy = PrivacyPreferences(prefs);

    expect(
      registry.isGrantedCurrent(
        ownerUserId: 'u1',
        purpose: ConsentPurpose.localHealthStore,
      ),
      isFalse,
    );
    await registry.record(
      ownerUserId: 'u1',
      purpose: ConsentPurpose.localHealthStore,
      granted: true,
    );
    expect(
      registry.isGrantedCurrent(
        ownerUserId: 'u1',
        purpose: ConsentPurpose.localHealthStore,
      ),
      isTrue,
    );
    expect(
      registry.latest(
        ownerUserId: 'u1',
        purpose: ConsentPurpose.localHealthStore,
      )?.version,
      ConsentVersions.current,
    );

    await privacy.setLockEnabled(true);
    await privacy.setHideNotificationBody(true);
    await privacy.setRemindersEnabled(true);
    expect(privacy.lockEnabled, isTrue);
    expect(privacy.hideNotificationBody, isTrue);
    expect(privacy.remindersEnabled, isTrue);
  });

  test('export then delete all local health data', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = HealthRecordsRepository(PrefsHealthLocalDatabase(prefs));
    final lifecycle = DataLifecycleService(prefs: prefs, records: repo);

    await repo.upsertObservation(
      Observation(
        id: 'wipe-1',
        ownerUserId: 'u1',
        type: ObservationType.weight,
        value: 70,
        unit: 'kg',
        measuredAt: DateTime.utc(2026, 1, 1),
        sourceKind: DataSourceKind.manual,
        sourceId: 'user',
      ),
    );
    final json = lifecycle.exportJson('u1');
    expect(json.contains('wipe-1'), isTrue);
    expect(json.contains('not a medical record certification'), isTrue);

    await lifecycle.deleteAllLocalData('u1');
    expect(repo.listObservations('u1'), isEmpty);
    expect(prefs.getString('super_health.lifecycle.last_wipe'), isNotNull);
  });
}
