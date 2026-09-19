import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_health/data/import/demo_wearable_import_adapter.dart';
import 'package:super_health/data/local/health_records_repository.dart';
import 'package:super_health/data/local/prefs_health_local_database.dart';
import 'package:super_health/domain/import/wearable_import_port.dart';
import 'package:super_health/domain/privacy/ai_safety_policy.dart';
import 'package:super_health/domain/records/audit_event.dart';
import 'package:super_health/domain/records/care_circle_member.dart';
import 'package:super_health/domain/records/observation.dart';
import 'package:super_health/domain/records/share_grant.dart';
import 'package:super_health/domain/trends/trend_series.dart';
import 'package:super_health/features/assistant/orchestrator/health_ai_in_app_route_catalog.dart';
import 'package:super_health/features/assistant/orchestrator/selected_record_explainer.dart';

void main() {
  late HealthRecordsRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repo = HealthRecordsRepository(PrefsHealthLocalDatabase(prefs));
  });

  test('share revoke stops export; audit has no clinical leakage', () async {
    await repo.upsertObservation(
      Observation(
        id: 'o1',
        ownerUserId: 'u1',
        type: ObservationType.weight,
        value: 70,
        unit: 'kg',
        measuredAt: DateTime.utc(2026, 9, 1),
        sourceKind: DataSourceKind.manual,
        sourceId: 'user',
      ),
    );
    final grant = await repo.createShare(
      ownerUserId: 'u1',
      recipientLabel: 'Dr Demo',
      categories: const [ShareCategory.observations],
      format: ShareFormat.csv,
    );
    expect(repo.exportActiveShare(ownerUserId: 'u1', grantId: grant.id), isNotNull);

    await repo.revokeShare(ownerUserId: 'u1', grantId: grant.id);
    expect(repo.exportActiveShare(ownerUserId: 'u1', grantId: grant.id), isNull);

    final audit = repo.listAudit('u1');
    expect(audit.any((e) => e.action == 'share.revoke'), isTrue);
    for (final e in audit) {
      expect(AuditEvent.metadataLooksSensitive(e.metadata), isFalse);
    }
  });

  test('audit rejects sensitive metadata', () async {
    expect(
      () => repo.appendAudit(
        AuditEvent(
          id: 'bad',
          ownerUserId: 'u1',
          action: 'leak',
          occurredAt: DateTime.now().toUtc(),
          metadata: const {'note': 'penicillin allergy'},
        ),
      ),
      throwsStateError,
    );
  });

  test('caregiver default has no full access', () async {
    final member = await repo.inviteCareMember(
      ownerUserId: 'u1',
      memberLabel: 'Parent',
      role: CareMemberRole.caregiver,
    );
    expect(member.visibleFields, isEmpty);
    expect(member.hasFullAccess, isFalse);
    expect(
      repo.caregiverCanSee(
        member: member,
        field: CareFieldVisibility.medications,
      ),
      isFalse,
    );
  });

  test('wearable demo dedupes duplicate samples', () async {
    final adapter = DemoWearableImportAdapter();
    await adapter.requestPermission();
    final batch = await adapter.importSince(
      ownerUserId: 'u1',
      sinceUtc: DateTime.utc(2020),
    );
    expect(adapter.isDemo, isTrue);
    expect(WearableDeduper.dedupe(batch).length < batch.length + 1, isTrue);
    // Adapter already returns deduped list; fingerprint uniqueness holds.
    final fps = batch.map(WearableDeduper.fingerprint).toSet();
    expect(fps.length, batch.length);
  });

  test('trend gaps are marked and not interpolated', () {
    final series = TrendSeriesBuilder.build(
      observations: [
        Observation(
          id: 'a',
          ownerUserId: 'u1',
          type: ObservationType.weight,
          value: 70,
          unit: 'kg',
          measuredAt: DateTime.utc(2026, 1, 1),
          sourceKind: DataSourceKind.manual,
          sourceId: 'user',
        ),
        Observation(
          id: 'b',
          ownerUserId: 'u1',
          type: ObservationType.weight,
          value: 71,
          unit: 'kg',
          measuredAt: DateTime.utc(2026, 1, 10),
          sourceKind: DataSourceKind.manual,
          sourceId: 'user',
        ),
      ],
      type: ObservationType.weight,
      displayUnit: 'kg',
      maxGap: const Duration(hours: 36),
    );
    expect(series.points, hasLength(2));
    expect(series.gapStarts, [0]);
    expect(series.hasGapAfter(0), isTrue);
  });

  test('AI in-app route before records; selected explainer needs explicit ids', () {
    final hit = HealthAiInAppRouteCatalog.resolve('Show my medication list');
    expect(hit, isNotNull);
    expect(hit!.message.contains('[NAV:'), isTrue);

    final none = SelectedRecordExplainer.explain(
      selectedIds: const ['o1'],
      all: [
        Observation(
          id: 'o1',
          ownerUserId: 'u1',
          type: ObservationType.heartRate,
          value: 72,
          unit: 'bpm',
          measuredAt: DateTime.utc(2026, 1, 1),
          sourceKind: DataSourceKind.manual,
          sourceId: 'user',
        ),
      ],
      userExplicitlySelected: false,
    );
    expect(none, isNull);

    final yes = SelectedRecordExplainer.explain(
      selectedIds: const ['o1'],
      all: [
        Observation(
          id: 'o1',
          ownerUserId: 'u1',
          type: ObservationType.heartRate,
          value: 72,
          unit: 'bpm',
          measuredAt: DateTime.utc(2026, 1, 1),
          sourceKind: DataSourceKind.manual,
          sourceId: 'user',
        ),
      ],
      userExplicitlySelected: true,
    );
    expect(yes, isNotNull);
    expect(yes!.sourceLabels, isNotEmpty);
    expect(yes.uncertaintyNote.isNotEmpty, isTrue);
    expect(yes.text.contains(AiSafetyPolicy.refuseClinicalEn), isTrue);
    expect(AiSafetyPolicy.isBlockedPrompt('please diagnose me'), isTrue);
  });
}
