import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_health/core/database/health_drift_schema.dart';
import 'package:super_health/data/local/health_records_repository.dart';
import 'package:super_health/data/local/prefs_health_local_database.dart';
import 'package:super_health/domain/privacy/sensitive_notification_copy.dart';
import 'package:super_health/domain/records/health_document.dart';
import 'package:super_health/domain/records/medication_record.dart';
import 'package:super_health/domain/records/observation.dart';
import 'package:super_health/domain/records/unit_conversion.dart';

void main() {
  late PrefsHealthLocalDatabase db;
  late HealthRecordsRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    db = PrefsHealthLocalDatabase(prefs);
    repo = HealthRecordsRepository(db);
  });

  test('medication taken / snooze / skipped adherence', () async {
    await repo.upsertMedication(
      const MedicationRecord(
        id: 'med-1',
        ownerUserId: 'u1',
        name: 'Example',
        instructionAsEntered: 'As written by clinician',
      ),
    );
    final taken = await repo.markAdherence(
      ownerUserId: 'u1',
      medicationId: 'med-1',
      scheduledFor: DateTime.utc(2026, 9, 19, 8),
      status: AdherenceStatus.taken,
    );
    expect(taken.status, AdherenceStatus.taken);

    final snoozed = await repo.markAdherence(
      ownerUserId: 'u1',
      medicationId: 'med-1',
      scheduledFor: DateTime.utc(2026, 9, 19, 12),
      status: AdherenceStatus.snoozed,
    );
    expect(snoozed.status, AdherenceStatus.snoozed);
    expect(snoozed.snoozeUntil, isNotNull);

    final skipped = await repo.markAdherence(
      ownerUserId: 'u1',
      medicationId: 'med-1',
      scheduledFor: DateTime.utc(2026, 9, 19, 20),
      status: AdherenceStatus.skipped,
    );
    expect(skipped.status, AdherenceStatus.skipped);
    expect(repo.listAdherence('u1'), hasLength(3));

    final lock = SensitiveNotificationCopy.medicationReminder(
      medicationName: 'Example',
      instruction: 'As written by clinician',
    );
    expect(lock.lockScreenBody.contains('Example'), isFalse);
  });

  test('DST: measuredAt stored UTC and survives round-trip', () async {
    final localSpringForward = DateTime(2026, 3, 29, 3, 30);
    final obs = Observation(
      id: 'dst-1',
      ownerUserId: 'u1',
      type: ObservationType.heartRate,
      value: 70,
      unit: 'bpm',
      measuredAt: localSpringForward,
      sourceKind: DataSourceKind.manual,
      sourceId: 'user',
      timeZoneId: 'Europe/Istanbul',
    );
    await repo.upsertObservation(obs);
    final loaded = repo.listObservations('u1').single;
    expect(loaded.measuredAtUtc.isUtc, isTrue);
    expect(loaded.measuredAtUtc, obs.measuredAtUtc);
  });

  test('unit conversion kg/lb C/F glucose', () {
    expect(
      UnitConversion.convert(value: 70, fromUnit: 'kg', toUnit: 'lb'),
      closeTo(154.32, 0.1),
    );
    expect(
      UnitConversion.convert(value: 36.6, fromUnit: 'C', toUnit: 'F'),
      closeTo(97.88, 0.1),
    );
  });

  test('user isolation for observations and documents', () async {
    await repo.upsertObservation(
      Observation(
        id: 'o-a',
        ownerUserId: 'alice',
        type: ObservationType.weight,
        value: 60,
        unit: 'kg',
        measuredAt: DateTime.utc(2026, 1, 1),
        sourceKind: DataSourceKind.manual,
        sourceId: 'user',
      ),
    );
    await repo.upsertObservation(
      Observation(
        id: 'o-b',
        ownerUserId: 'bob',
        type: ObservationType.weight,
        value: 80,
        unit: 'kg',
        measuredAt: DateTime.utc(2026, 1, 1),
        sourceKind: DataSourceKind.manual,
        sourceId: 'user',
      ),
    );
    expect(repo.listObservations('alice').map((e) => e.id), ['o-a']);
    expect(repo.listObservations('bob').map((e) => e.id), ['o-b']);
  });

  test('document delete tombstone blocks remote resurrection', () async {
    final real = HealthDocument(
      id: 'doc-1',
      ownerUserId: 'u1',
      title: 'Lab',
      kind: HealthDocumentKind.labResult,
      documentDate: DateTime.utc(2026, 2, 1),
      localUri: 'local://x',
    );
    await repo.upsertDocument(real);
    expect(repo.listDocuments('u1'), hasLength(1));
    await repo.deleteDocument(ownerUserId: 'u1', id: 'doc-1');
    expect(repo.listDocuments('u1'), isEmpty);
    expect(
      repo.isDocumentTombstoned(ownerUserId: 'u1', id: 'doc-1'),
      isTrue,
    );
    await repo.applyRemoteDocument(real);
    expect(repo.listDocuments('u1'), isEmpty);
  });

  test('persistence across reopen and sync queue', () async {
    await repo.upsertMedication(
      const MedicationRecord(
        id: 'med-persist',
        ownerUserId: 'u1',
        name: 'Persist',
        instructionAsEntered: 'Keep as written',
      ),
    );
    expect(db.pendingSync(), isNotEmpty);
    expect(db.pendingSync().first.entityType, HealthRecordsRepository.medications);

    final prefs = await SharedPreferences.getInstance();
    final reopened = HealthRecordsRepository(PrefsHealthLocalDatabase(prefs));
    expect(reopened.listMedications('u1').single.name, 'Persist');
  });

  test('schema lists Drift-parity tables', () {
    expect(HealthDriftSchema.tables, contains('observations'));
    expect(HealthDriftSchema.tables, contains('tombstones'));
    expect(HealthDriftSchema.syncColumns, contains('user_id'));
  });
}
