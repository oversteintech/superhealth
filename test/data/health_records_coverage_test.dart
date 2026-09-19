import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_health/data/local/health_records_repository.dart';
import 'package:super_health/data/local/prefs_health_local_database.dart';
import 'package:super_health/domain/records/care_appointment.dart';
import 'package:super_health/domain/records/care_circle_member.dart';
import 'package:super_health/domain/records/emergency_card_record.dart';
import 'package:super_health/domain/records/habit_record.dart';
import 'package:super_health/domain/records/health_profile_record.dart';
import 'package:super_health/domain/records/medication_record.dart';
import 'package:super_health/domain/records/observation.dart';
import 'package:super_health/domain/records/share_grant.dart';
import 'package:super_health/domain/records/symptom_entry.dart';
import 'package:super_health/domain/sharing/share_export_builder.dart';

void main() {
  late HealthRecordsRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repo = HealthRecordsRepository(PrefsHealthLocalDatabase(prefs));
  });

  test('profile, symptoms, habits, appointments, emergency CRUD', () async {
    await repo.saveProfile(
      const HealthProfile(
        id: 'p1',
        ownerUserId: 'u1',
        displayName: 'Ayhan',
        birthYear: 1990,
        heightCm: 180,
      ),
    );
    expect(repo.profileFor('u1')!.displayName, 'Ayhan');
    expect(repo.profileFor('other'), isNull);

    await repo.upsertSymptom(
      SymptomEntry(
        id: 's1',
        ownerUserId: 'u1',
        label: 'Fatigue',
        occurredAt: DateTime.utc(2026, 9, 18),
        severity: 3,
      ),
    );
    expect(repo.listSymptoms('u1').single.label, 'Fatigue');

    await repo.upsertHabit(
      const HabitGoal(
        id: 'g1',
        ownerUserId: 'u1',
        title: 'Walk',
        targetPerDay: 30,
        unitLabel: 'min',
      ),
    );
    await repo.upsertHabit(
      const HabitGoal(
        id: 'g-inactive',
        ownerUserId: 'u1',
        title: 'Hidden',
        targetPerDay: 1,
        unitLabel: 'x',
        active: false,
      ),
    );
    expect(repo.listHabits('u1').map((e) => e.id), ['g1']);

    await repo.logHabit(
      HabitLog(
        id: 'l1',
        ownerUserId: 'u1',
        goalId: 'g1',
        dayKey: '2026-09-19',
        value: 20,
        loggedAt: DateTime.utc(2026, 9, 19, 10),
      ),
    );
    expect(repo.habitLogsForDay('u1', '2026-09-19'), hasLength(1));
    expect(repo.habitLogsForDay('u1', '2026-09-18'), isEmpty);

    await repo.upsertAppointment(
      CareAppointment(
        id: 'a1',
        ownerUserId: 'u1',
        title: 'Dentist',
        startsAt: DateTime.utc(2026, 10, 2, 14),
        clinicianName: 'Dr Demo',
      ),
    );
    expect(repo.listAppointments('u1').single.title, 'Dentist');

    await repo.saveEmergencyCard(
      EmergencyCardRecord(
        id: 'e1',
        ownerUserId: 'u1',
        updatedAt: DateTime.utc(2026, 9, 19),
        enabled: true,
        displayName: 'Ayhan',
      ),
    );
    expect(repo.emergencyCardFor('u1')!.enabled, isTrue);
    expect(repo.emergencyCardFor('other'), isNull);
  });

  test('latest adherence helper and observation delete', () async {
    await repo.upsertObservation(
      Observation(
        id: 'o-del',
        ownerUserId: 'u1',
        type: ObservationType.steps,
        value: 1000,
        unit: 'steps',
        measuredAt: DateTime.utc(2026, 9, 1),
        sourceKind: DataSourceKind.manual,
        sourceId: 'user',
      ),
    );
    await repo.deleteObservation(ownerUserId: 'u1', id: 'o-del');
    expect(repo.listObservations('u1'), isEmpty);

    await repo.markAdherence(
      ownerUserId: 'u1',
      medicationId: 'med-x',
      scheduledFor: DateTime.utc(2026, 9, 19, 8),
      status: AdherenceStatus.taken,
    );
    expect(repo.latestAdherenceFor('u1', 'med-x')!.status, AdherenceStatus.taken);
    expect(repo.latestAdherenceFor('u1', 'missing'), isNull);
  });

  test('share export pdf path and empty categories', () async {
    await repo.upsertObservation(
      Observation(
        id: 'o1',
        ownerUserId: 'u1',
        type: ObservationType.weight,
        value: 70,
        unit: 'kg',
        measuredAt: DateTime.utc(2026, 9, 10),
        sourceKind: DataSourceKind.manual,
        sourceId: 'user',
      ),
    );
    final pdf = await repo.createShare(
      ownerUserId: 'u1',
      recipientLabel: 'Clinic',
      categories: const [ShareCategory.observations],
      format: ShareFormat.pdfText,
      fromDate: DateTime.utc(2026, 9, 1),
      toDate: DateTime.utc(2026, 9, 30),
      recordIds: const ['o1'],
    );
    final exported = repo.exportActiveShare(ownerUserId: 'u1', grantId: pdf.id)!;
    expect(exported.format, ShareFormat.pdfText);
    expect(exported.body, contains('Disclaimer'));
    expect(exported.body, contains('70'));

    final emptyCat = await repo.createShare(
      ownerUserId: 'u1',
      recipientLabel: 'Other',
      categories: const [ShareCategory.medications],
      format: ShareFormat.csv,
    );
    final emptyExport =
        repo.exportActiveShare(ownerUserId: 'u1', grantId: emptyCat.id)!;
    expect(emptyExport.body, contains('id,type,value'));
    expect(emptyExport.body.split('\n').where((l) => l.startsWith('o1')), isEmpty);

    expect(
      () => repo.revokeShare(ownerUserId: 'u1', grantId: 'missing'),
      throwsStateError,
    );
    expect(
      repo.exportActiveShare(ownerUserId: 'u1', grantId: 'missing'),
      isNull,
    );
  });

  test('care circle invite revoke and visibility', () async {
    final member = await repo.inviteCareMember(
      ownerUserId: 'u1',
      memberLabel: 'Parent',
      role: CareMemberRole.caregiver,
      visibleFields: const [CareFieldVisibility.observations],
    );
    expect(repo.listCareMembers('u1'), hasLength(1));
    expect(
      repo.caregiverCanSee(
        member: member,
        field: CareFieldVisibility.observations,
      ),
      isTrue,
    );
    expect(
      repo.caregiverCanSee(
        member: member,
        field: CareFieldVisibility.medications,
      ),
      isFalse,
    );

    final revoked = await repo.revokeCareMember(
      ownerUserId: 'u1',
      memberId: member.id,
    );
    expect(revoked.isActive, isFalse);
    expect(repo.listCareMembers('u1'), isEmpty);
    expect(
      repo.caregiverCanSee(
        member: revoked,
        field: CareFieldVisibility.observations,
      ),
      isFalse,
    );
    expect(
      () => repo.revokeCareMember(ownerUserId: 'u1', memberId: 'missing'),
      throwsStateError,
    );
  });

  test('ShareExportBuilder filters by date and record ids', () {
    final grant = ShareGrant(
      id: 'g',
      ownerUserId: 'u1',
      recipientLabel: 'Dr',
      categories: const [ShareCategory.observations],
      createdAt: DateTime.utc(2026, 9, 1),
      expiresAt: DateTime.utc(2026, 12, 1),
      format: ShareFormat.csv,
      fromDate: DateTime.utc(2026, 9, 5),
      toDate: DateTime.utc(2026, 9, 15),
      recordIds: const ['keep'],
    );
    final result = ShareExportBuilder.build(
      grant: grant,
      observations: [
        Observation(
          id: 'keep',
          ownerUserId: 'u1',
          type: ObservationType.weight,
          value: 70,
          unit: 'kg',
          measuredAt: DateTime.utc(2026, 9, 10),
          sourceKind: DataSourceKind.manual,
          sourceId: 'user',
        ),
        Observation(
          id: 'early',
          ownerUserId: 'u1',
          type: ObservationType.weight,
          value: 71,
          unit: 'kg',
          measuredAt: DateTime.utc(2026, 9, 1),
          sourceKind: DataSourceKind.manual,
          sourceId: 'user',
        ),
        Observation(
          id: 'other',
          ownerUserId: 'u1',
          type: ObservationType.weight,
          value: 72,
          unit: 'kg',
          measuredAt: DateTime.utc(2026, 9, 10),
          sourceKind: DataSourceKind.manual,
          sourceId: 'user',
        ),
      ],
    );
    expect(result.body, contains('keep'));
    expect(result.body.contains('early'), isFalse);
    expect(result.body.contains('other'), isFalse);
  });
}
