import '../../domain/entities/app_notification.dart';
import '../../domain/entities/doctor_visit.dart';
import '../../domain/entities/emergency_card.dart';
import '../../domain/entities/health_insight.dart';
import '../../domain/entities/health_profile.dart';
import '../../domain/entities/heart_rate_sample.dart';
import '../../domain/entities/lab_result.dart';
import '../../domain/entities/medical_record.dart';
import '../../domain/entities/medication.dart';
import '../../domain/entities/nutrition_entry.dart';
import '../../domain/entities/sleep_session.dart';
import '../../domain/entities/vaccination.dart';
import '../../domain/entities/vital_reading.dart';
import '../../domain/entities/weight_entry.dart';
import '../../domain/repositories/health_repository.dart';
import '../mock/mock_health_data.dart';

class MockHealthRepository implements HealthRepository {
  final List<AppNotification> _notifications =
      List.of(MockHealthData.notifications());

  @override
  Future<HealthProfile> getProfile() async => MockHealthData.profile;

  @override
  Future<List<VitalReading>> getVitals() async => MockHealthData.vitals();

  @override
  Future<List<Medication>> getMedications() async =>
      MockHealthData.medications();

  @override
  Future<List<DoctorVisit>> getDoctorVisits() async =>
      MockHealthData.doctorVisits();

  @override
  Future<List<MedicalRecord>> getMedicalRecords() async =>
      MockHealthData.medicalRecords();

  @override
  Future<List<LabResult>> getLabResults() async => MockHealthData.labResults();

  @override
  Future<List<Vaccination>> getVaccinations() async =>
      MockHealthData.vaccinations();

  @override
  Future<List<HeartRateSample>> getHeartRateSamples() async =>
      MockHealthData.heartRate();

  @override
  Future<List<WeightEntry>> getWeightEntries() async => MockHealthData.weight();

  @override
  Future<List<SleepSession>> getSleepSessions() async => MockHealthData.sleep();

  @override
  Future<List<NutritionEntry>> getNutritionEntries() async =>
      MockHealthData.nutrition();

  @override
  Future<EmergencyCard> getEmergencyCard() async => MockHealthData.emergencyCard;

  @override
  Future<List<HealthInsight>> getInsights() async => MockHealthData.insights();

  @override
  Future<List<AppNotification>> getNotifications() async =>
      List.unmodifiable(_notifications);

  @override
  Future<void> markNotificationRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index >= 0) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  @override
  Future<List<Object>> search(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final results = <Object>[];
    for (final m in MockHealthData.medications()) {
      if (m.name.toLowerCase().contains(q)) results.add(m);
    }
    for (final v in MockHealthData.doctorVisits()) {
      if (v.reason.toLowerCase().contains(q) ||
          v.clinician.toLowerCase().contains(q)) {
        results.add(v);
      }
    }
    for (final r in MockHealthData.medicalRecords()) {
      if (r.title.toLowerCase().contains(q) ||
          r.category.toLowerCase().contains(q)) {
        results.add(r);
      }
    }
    for (final l in MockHealthData.labResults()) {
      if (l.testName.toLowerCase().contains(q)) results.add(l);
    }
    for (final vac in MockHealthData.vaccinations()) {
      if (vac.name.toLowerCase().contains(q)) results.add(vac);
    }
    for (final meal in MockHealthData.nutrition()) {
      if (meal.description.toLowerCase().contains(q) ||
          meal.meal.toLowerCase().contains(q)) {
        results.add(meal);
      }
    }
    for (final i in MockHealthData.insights()) {
      if (i.title.toLowerCase().contains(q)) results.add(i);
    }
    return results;
  }

  @override
  Future<List<String>> assistantReplies(String prompt) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    final lower = prompt.toLowerCase();
    if (lower.contains('sleep')) {
      return const [
        'Your latest sleep session was about 7.4 hours with a quality score of 82.',
        'A consistent bedtime window usually helps more than weekend catch-up.',
        'This is general wellness guidance — not a medical diagnosis.',
      ];
    }
    if (lower.contains('heart') || lower.contains('pulse')) {
      return const [
        'Your most recent resting heart rate reading is around 72 bpm.',
        'That sits in a typical calm range for many adults at rest.',
        'Contact a clinician if you notice chest pain, dizziness, or sudden changes.',
      ];
    }
    if (lower.contains('lab') || lower.contains('cholesterol')) {
      return const [
        'Your LDL cholesterol is flagged high in the latest mock lab panel.',
        'Bring the result to your clinician before changing any treatment.',
        'I cannot diagnose or prescribe — SuperHealth Mate is for orientation only.',
      ];
    }
    if (lower.contains('vaccin') || lower.contains('aşı') || lower.contains('asi')) {
      return const [
        'Your seasonal influenza dose is logged for this year.',
        'Tetanus booster next-due is tracked on your Vaccinations screen.',
        'Always confirm immunization plans with a licensed clinician.',
      ];
    }
    if (lower.contains('emergency')) {
      return const [
        'Your Emergency Card includes blood type A+, penicillin allergy, and Mehmet Yılmaz as contact.',
        'Keep the card updated before travel or procedures.',
      ];
    }
    return [
      'I am SuperHealth Mate — I can help review medications, visits, labs, sleep, and nutrition.',
      'You asked: "$prompt"',
      'I am not a doctor. For diagnosis or emergencies, seek professional care.',
    ];
  }
}