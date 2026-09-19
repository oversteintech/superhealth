import 'package:flutter_test/flutter_test.dart';
import 'package:super_health/data/repositories/mock_health_repository.dart';
import 'package:super_health/domain/entities/lab_result.dart';
import 'package:super_health/domain/entities/medication.dart';
import 'package:super_health/domain/entities/vaccination.dart';

void main() {
  test('mock repository covers core health surfaces', () async {
    final repo = MockHealthRepository();
    expect((await repo.getProfile()).displayName, isNotEmpty);
    expect(await repo.getMedications(), isNotEmpty);
    expect(await repo.getDoctorVisits(), isNotEmpty);
    expect(await repo.getMedicalRecords(), isNotEmpty);
    expect(await repo.getLabResults(), isNotEmpty);
    expect(await repo.getVaccinations(), isNotEmpty);
    expect(await repo.getHeartRateSamples(), isNotEmpty);
    expect(await repo.getWeightEntries(), isNotEmpty);
    expect(await repo.getSleepSessions(), isNotEmpty);
    expect(await repo.getNutritionEntries(), isNotEmpty);
    expect((await repo.getEmergencyCard()).bloodType, 'A+');

    final results = await repo.search('vitamin');
    expect(results.whereType<Medication>(), isNotEmpty);

    final labs = await repo.search('cholesterol');
    expect(labs.whereType<LabResult>(), isNotEmpty);

    final vax = await repo.search('influenza');
    expect(vax.whereType<Vaccination>(), isNotEmpty);

    final replies = await repo.assistantReplies('How is my sleep?');
    expect(replies, isNotEmpty);
    expect(replies.join(' ').toLowerCase().contains('7.4'), isFalse);
    expect((await repo.getEmergencyCard()).enabled, isFalse);

    expect(await repo.search(''), isEmpty);
    expect(await repo.search('checkup'), isNotEmpty);
    expect(await repo.search('breakfast'), isNotEmpty);
    expect(await repo.search('hydration'), isNotEmpty);
    expect((await repo.assistantReplies('heart pulse')).join(' '), contains('Heart'));
    expect((await repo.assistantReplies('lab cholesterol')).join(' '), contains('Lab'));
    expect((await repo.assistantReplies('vaccination aşı')).join(' '), contains('influenza'));
    expect((await repo.assistantReplies('emergency')).join(' '), contains('Emergency'));
    expect((await repo.assistantReplies('hello')).join(' '), contains('SuperHealth Mate'));

    final notes = await repo.getNotifications();
    expect(notes, isNotEmpty);
    await repo.markNotificationRead(notes.first.id);
    final after = await repo.getNotifications();
    expect(after.firstWhere((n) => n.id == notes.first.id).isRead, isTrue);
    await repo.markNotificationRead('missing-id');
  });
}