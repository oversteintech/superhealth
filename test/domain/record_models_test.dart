import 'package:flutter_test/flutter_test.dart';
import 'package:super_health/domain/records/care_appointment.dart';
import 'package:super_health/domain/records/emergency_card_record.dart';
import 'package:super_health/domain/records/habit_record.dart';
import 'package:super_health/domain/records/health_profile_record.dart';
import 'package:super_health/domain/records/symptom_entry.dart';

void main() {
  test('CareAppointment json round-trip', () {
    final original = CareAppointment(
      id: 'a1',
      ownerUserId: 'u1',
      title: 'Check-up',
      startsAt: DateTime.utc(2026, 10, 1, 9),
      location: 'Clinic',
      clinicianName: 'Dr Demo',
      notes: 'Bring questions',
      questions: const ['Ask about labs'],
      reminderMinutesBefore: 60,
      exportToCalendar: true,
    );
    final restored = CareAppointment.fromJson(original.toJson());
    expect(restored.id, original.id);
    expect(restored.startsAt, original.startsAt);
    expect(restored.questions, ['Ask about labs']);
    expect(restored.exportToCalendar, isTrue);
    expect(
      CareAppointment.fromJson({
        'id': 'a2',
        'ownerUserId': 'u1',
        'title': 'Minimal',
        'startsAt': '2026-01-01T00:00:00.000Z',
      }).location,
      '',
    );
  });

  test('EmergencyCardRecord json + copyWith', () {
    final card = EmergencyCardRecord(
      id: 'e1',
      ownerUserId: 'u1',
      updatedAt: DateTime.utc(2026, 9, 1),
      enabled: true,
      lockScreenSharingConsent: true,
      displayName: 'Ada',
      bloodType: 'A+',
      allergies: const ['peanuts'],
      importantNotes: const ['ICE only'],
      emergencyContactName: 'Can',
      emergencyContactPhone: '+90',
      editHistory: const ['created'],
    );
    final round = EmergencyCardRecord.fromJson(card.toJson());
    expect(round.enabled, isTrue);
    expect(round.allergies, ['peanuts']);
    final patched = card.copyWith(
      enabled: false,
      displayName: 'Ada Y.',
      updatedAt: DateTime.utc(2026, 9, 2),
    );
    expect(patched.enabled, isFalse);
    expect(patched.displayName, 'Ada Y.');
    expect(patched.bloodType, 'A+');
  });

  test('HabitGoal and HabitLog json round-trip', () {
    const goal = HabitGoal(
      id: 'g1',
      ownerUserId: 'u1',
      title: 'Water',
      targetPerDay: 8,
      unitLabel: 'glasses',
    );
    expect(HabitGoal.fromJson(goal.toJson()).targetPerDay, 8);
    expect(HabitGoal.fromJson(goal.toJson()).active, isTrue);

    final log = HabitLog(
      id: 'l1',
      ownerUserId: 'u1',
      goalId: 'g1',
      dayKey: '2026-09-19',
      value: 3,
      loggedAt: DateTime.utc(2026, 9, 19, 12),
    );
    expect(HabitLog.fromJson(log.toJson()).dayKey, '2026-09-19');
    expect(HabitLog.fromJson(log.toJson()).value, 3);
  });

  test('HealthProfile json, age, and copyWith', () {
    final profile = HealthProfile(
      id: 'p1',
      ownerUserId: 'u1',
      displayName: 'Ayhan',
      birthYear: 1990,
      heightCm: 180,
      preferredUnitSystem: UnitSystem.imperial,
      timeZoneId: 'Europe/Istanbul',
      countryCode: 'TR',
      languageCode: 'tr',
    );
    final round = HealthProfile.fromJson(profile.toJson());
    expect(round.preferredUnitSystem, UnitSystem.imperial);
    expect(round.approximateAgeYears, DateTime.now().year - 1990);
    expect(
      HealthProfile.fromJson({
        'id': 'p2',
        'ownerUserId': 'u1',
        'displayName': 'No year',
      }).approximateAgeYears,
      isNull,
    );
    final patched = profile.copyWith(ageBand: '30-39', displayName: 'A.');
    expect(patched.ageBand, '30-39');
    expect(patched.displayName, 'A.');
    expect(patched.birthYear, 1990);
  });

  test('SymptomEntry json round-trip defaults', () {
    final entry = SymptomEntry(
      id: 's1',
      ownerUserId: 'u1',
      label: 'Headache',
      occurredAt: DateTime.utc(2026, 9, 19, 8),
      severity: 4,
      durationMinutes: 30,
      triggerNote: 'Skipped water',
      freeNote: 'Personal note',
    );
    final round = SymptomEntry.fromJson(entry.toJson());
    expect(round.severity, 4);
    expect(round.freeNote, 'Personal note');
    expect(
      SymptomEntry.fromJson({
        'id': 's2',
        'ownerUserId': 'u1',
        'label': 'Minimal',
        'occurredAt': '2026-01-01T00:00:00.000Z',
      }).severity,
      0,
    );
  });
}
