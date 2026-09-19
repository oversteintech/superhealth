import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_health/data/local/user_scoped_observation_store.dart';
import 'package:super_health/domain/privacy/ai_safety_policy.dart';
import 'package:super_health/domain/privacy/health_score_policy.dart';
import 'package:super_health/domain/privacy/sensitive_notification_copy.dart';
import 'package:super_health/domain/records/observation.dart';
import 'package:super_health/domain/records/unit_conversion.dart';

void main() {
  Observation obs({
    required String id,
    required String user,
    DateTime? at,
  }) {
    return Observation(
      id: id,
      ownerUserId: user,
      type: ObservationType.weight,
      value: 70,
      unit: 'kg',
      measuredAt: at ?? DateTime.utc(2026, 3, 29, 1, 30),
      sourceKind: DataSourceKind.manual,
      sourceId: 'user-entry',
      timeZoneId: 'Europe/Istanbul',
    );
  }

  test('unit conversion round-trips', () {
    final lb = UnitConversion.convert(value: 70, fromUnit: 'kg', toUnit: 'lb');
    expect(
      UnitConversion.convert(value: lb, fromUnit: 'lb', toUnit: 'kg'),
      closeTo(70, 0.0001),
    );
    final f = UnitConversion.convert(value: 36.6, fromUnit: 'C', toUnit: 'F');
    expect(
      UnitConversion.convert(value: f, fromUnit: 'F', toUnit: 'C'),
      closeTo(36.6, 0.0001),
    );
    final mg = UnitConversion.convert(
      value: 5.5,
      fromUnit: 'mmol/L',
      toUnit: 'mg/dL',
    );
    expect(
      UnitConversion.convert(value: mg, fromUnit: 'mg/dL', toUnit: 'mmol/L'),
      closeTo(5.5, 0.0001),
    );
  });

  test('DST instant is stored in UTC', () {
    final local = DateTime(2026, 3, 29, 3, 30);
    final stored = Observation(
      id: 'dst',
      ownerUserId: 'a',
      type: ObservationType.heartRate,
      value: 72,
      unit: 'bpm',
      measuredAt: local,
      sourceKind: DataSourceKind.wearable,
      sourceId: 'watch-demo',
    );
    expect(stored.measuredAtUtc.isUtc, isTrue);
    final json = Observation.fromJson(stored.toJson());
    expect(json.measuredAtUtc, stored.measuredAtUtc);
  });

  test('users cannot read each other observations; tombstones persist', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = UserScopedObservationStore(prefs);
    await store.upsert(obs(id: 'w1', user: 'user-a'));
    await store.upsert(obs(id: 'w2', user: 'user-b'));
    expect(store.listForUser('user-a').map((e) => e.id), ['w1']);
    expect(store.listForUser('user-b').map((e) => e.id), ['w2']);

    await store.delete(ownerUserId: 'user-a', id: 'w1');
    expect(store.listForUser('user-a'), isEmpty);
    expect(store.isTombstoned(ownerUserId: 'user-a', id: 'w1'), isTrue);

    await store.applyRemote(obs(id: 'w1', user: 'user-a'));
    expect(store.listForUser('user-a'), isEmpty);

    final prefs2 = await SharedPreferences.getInstance();
    final reopened = UserScopedObservationStore(prefs2);
    expect(reopened.listForUser('user-b').single.id, 'w2');
    expect(reopened.isTombstoned(ownerUserId: 'user-a', id: 'w1'), isTrue);
  });

  test('AI payload has no records unless explicitly selected', () {
    final hidden = AiSafetyPolicy.buildPayload(userMessage: 'Summarize my labs');
    expect(hidden.recordIds, isEmpty);
    expect(hidden.blocked, isFalse);

    final selected = AiSafetyPolicy.buildPayload(
      userMessage: 'Explain this note',
      selectedRecordIds: ['obs-1'],
      userExplicitlySelectedRecords: true,
    );
    expect(selected.recordIds, ['obs-1']);
    expect(selected.toAnalyticsFields()['record_count'], 1);

    final clinical = AiSafetyPolicy.buildPayload(
      userMessage: 'Diagnose this rash and prescribe a dose',
    );
    expect(clinical.blocked, isTrue);
    expect(clinical.recordIds, isEmpty);
  });

  test('missing observations do not become a health score', () {
    expect(HealthScorePolicy.scoreFromObservations(const []), isNull);
    expect(
      () => HealthScorePolicy.scoreFromObservations([obs(id: '1', user: 'a')]),
      throwsStateError,
    );
  });

  test('medication reminder hides sensitive body on lock screen', () {
    final copy = SensitiveNotificationCopy.medicationReminder(
      medicationName: 'Example tablet',
      instruction: 'Take with food as written by clinician',
    );
    expect(copy.lockScreenBody.contains('Example'), isFalse);
    expect(copy.body.contains('Example tablet'), isTrue);
  });
}
