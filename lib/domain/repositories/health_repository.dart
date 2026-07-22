import '../entities/app_notification.dart';
import '../entities/doctor_visit.dart';
import '../entities/emergency_card.dart';
import '../entities/health_insight.dart';
import '../entities/health_profile.dart';
import '../entities/heart_rate_sample.dart';
import '../entities/lab_result.dart';
import '../entities/medical_record.dart';
import '../entities/medication.dart';
import '../entities/nutrition_entry.dart';
import '../entities/sleep_session.dart';
import '../entities/vaccination.dart';
import '../entities/vital_reading.dart';
import '../entities/weight_entry.dart';

abstract class HealthRepository {
  Future<HealthProfile> getProfile();
  Future<List<VitalReading>> getVitals();
  Future<List<Medication>> getMedications();
  Future<List<DoctorVisit>> getDoctorVisits();
  Future<List<MedicalRecord>> getMedicalRecords();
  Future<List<LabResult>> getLabResults();
  Future<List<Vaccination>> getVaccinations();
  Future<List<HeartRateSample>> getHeartRateSamples();
  Future<List<WeightEntry>> getWeightEntries();
  Future<List<SleepSession>> getSleepSessions();
  Future<List<NutritionEntry>> getNutritionEntries();
  Future<EmergencyCard> getEmergencyCard();
  Future<List<HealthInsight>> getInsights();
  Future<List<AppNotification>> getNotifications();
  Future<void> markNotificationRead(String id);
  Future<List<Object>> search(String query);
  Future<List<String>> assistantReplies(String prompt);
}