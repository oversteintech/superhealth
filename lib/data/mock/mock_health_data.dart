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

abstract final class MockHealthData {
  static final now = DateTime.now();

  static const profile = HealthProfile(
    id: 'profile-1',
    displayName: 'Ayşe Yılmaz',
    ageYears: 34,
    bloodType: 'A+',
    heightCm: 168,
    weightKg: 62.5,
    conditions: ['Seasonal allergy'],
  );

  static const emergencyCard = EmergencyCard(
    fullName: 'Ayşe Yılmaz',
    bloodType: 'A+',
    emergencyContactName: 'Mehmet Yılmaz',
    emergencyContactPhone: '+90 532 000 00 00',
    allergies: ['Penicillin'],
    conditions: ['Seasonal allergy'],
    medications: ['Vitamin D3', 'Loratadine'],
    notes: 'Prefers Turkish-speaking clinicians.',
    organDonor: true,
  );

  static List<VitalReading> vitals() => [
        VitalReading(
          id: 'v1',
          kind: VitalKind.heartRate,
          value: 72,
          unit: 'bpm',
          recordedAt: now.subtract(const Duration(hours: 1)),
        ),
        VitalReading(
          id: 'v2',
          kind: VitalKind.bloodPressure,
          value: 118,
          secondaryValue: 76,
          unit: 'mmHg',
          recordedAt: now.subtract(const Duration(hours: 2)),
        ),
        VitalReading(
          id: 'v3',
          kind: VitalKind.steps,
          value: 6842,
          unit: 'steps',
          recordedAt: now,
        ),
        VitalReading(
          id: 'v4',
          kind: VitalKind.sleepHours,
          value: 7.4,
          unit: 'h',
          recordedAt: now.subtract(const Duration(hours: 8)),
        ),
        VitalReading(
          id: 'v5',
          kind: VitalKind.spo2,
          value: 98,
          unit: '%',
          recordedAt: now.subtract(const Duration(hours: 3)),
        ),
        VitalReading(
          id: 'v6',
          kind: VitalKind.glucose,
          value: 92,
          unit: 'mg/dL',
          recordedAt: now.subtract(const Duration(hours: 5)),
        ),
      ];

  static List<Medication> medications() => [
        Medication(
          id: 'm1',
          name: 'Vitamin D3',
          dosage: '1000 IU',
          schedule: 'Every morning',
          nextDoseAt: DateTime(now.year, now.month, now.day, 9),
          takenToday: true,
        ),
        Medication(
          id: 'm2',
          name: 'Loratadine',
          dosage: '10 mg',
          schedule: 'As needed',
          nextDoseAt: DateTime(now.year, now.month, now.day, 20),
        ),
        Medication(
          id: 'm3',
          name: 'Omega-3',
          dosage: '1 capsule',
          schedule: 'With dinner',
          nextDoseAt: DateTime(now.year, now.month, now.day, 19),
        ),
      ];

  static List<DoctorVisit> doctorVisits() => [
        DoctorVisit(
          id: 'dv1',
          reason: 'Annual checkup',
          clinician: 'Dr. Elif Kara',
          specialty: 'Internal medicine',
          clinic: 'AfterCare Clinic — Kadıköy',
          startsAt: now.add(const Duration(days: 5, hours: 2)),
          notes: 'Bring latest bloodwork.',
          followUpRequired: false,
        ),
        DoctorVisit(
          id: 'dv2',
          reason: 'Dental cleaning',
          clinician: 'Dr. Can Demir',
          specialty: 'Dentistry',
          clinic: 'Smile Dental',
          startsAt: now.add(const Duration(days: 18)),
        ),
        DoctorVisit(
          id: 'dv3',
          reason: 'Allergy follow-up',
          clinician: 'Dr. Selin Aksoy',
          specialty: 'Allergy & immunology',
          clinic: 'City Allergy Center',
          startsAt: now.subtract(const Duration(days: 40)),
          notes: 'Seasonal symptoms improved.',
          followUpRequired: true,
        ),
      ];

  static List<MedicalRecord> medicalRecords() => [
        MedicalRecord(
          id: 'mr1',
          title: 'Primary care summary 2026',
          category: 'Clinical summary',
          provider: 'AfterCare Clinic',
          recordedAt: now.subtract(const Duration(days: 12)),
          summary: 'Overall healthy adult. Continue allergy management.',
          attachmentLabel: 'PDF · 240 KB',
        ),
        MedicalRecord(
          id: 'mr2',
          title: 'Chest X-ray report',
          category: 'Imaging',
          provider: 'Metro Radiology',
          recordedAt: now.subtract(const Duration(days: 210)),
          summary: 'No acute cardiopulmonary process.',
          attachmentLabel: 'DICOM note',
        ),
        MedicalRecord(
          id: 'mr3',
          title: 'Allergy panel',
          category: 'Diagnostics',
          provider: 'City Allergy Center',
          recordedAt: now.subtract(const Duration(days: 400)),
          summary: 'Positive seasonal pollen markers.',
        ),
      ];

  static List<LabResult> labResults() => [
        LabResult(
          id: 'lab1',
          testName: 'Hemoglobin',
          value: '13.8',
          unit: 'g/dL',
          referenceRange: '12.0 – 15.5',
          collectedAt: now.subtract(const Duration(days: 14)),
        ),
        LabResult(
          id: 'lab2',
          testName: 'LDL Cholesterol',
          value: '128',
          unit: 'mg/dL',
          referenceRange: '< 100',
          collectedAt: now.subtract(const Duration(days: 14)),
          status: 'high',
        ),
        LabResult(
          id: 'lab3',
          testName: 'Vitamin D (25-OH)',
          value: '28',
          unit: 'ng/mL',
          referenceRange: '30 – 100',
          collectedAt: now.subtract(const Duration(days: 14)),
          status: 'low',
        ),
        LabResult(
          id: 'lab4',
          testName: 'Fasting glucose',
          value: '92',
          unit: 'mg/dL',
          referenceRange: '70 – 99',
          collectedAt: now.subtract(const Duration(days: 14)),
        ),
      ];

  static List<Vaccination> vaccinations() => [
        Vaccination(
          id: 'vac1',
          name: 'Influenza (seasonal)',
          doseLabel: '2025–2026 dose',
          administeredAt: now.subtract(const Duration(days: 90)),
          provider: 'AfterCare Clinic',
          nextDueAt: now.add(const Duration(days: 275)),
          lotNumber: 'FLU-25-8841',
        ),
        Vaccination(
          id: 'vac2',
          name: 'COVID-19 booster',
          doseLabel: 'Updated formula',
          administeredAt: now.subtract(const Duration(days: 320)),
          provider: 'Municipal Vaccination Hub',
          lotNumber: 'COV-24-1190',
        ),
        Vaccination(
          id: 'vac3',
          name: 'Tetanus / diphtheria',
          doseLabel: 'Td booster',
          administeredAt: now.subtract(const Duration(days: 1200)),
          provider: 'Family doctor',
          nextDueAt: now.add(const Duration(days: 620)),
        ),
      ];

  static List<HeartRateSample> heartRate() => [
        for (var i = 0; i < 8; i++)
          HeartRateSample(
            id: 'hr$i',
            bpm: 68 + (i % 5) * 2,
            recordedAt: now.subtract(Duration(hours: i * 3)),
            context: i == 2 ? 'walk' : 'resting',
          ),
      ];

  static List<WeightEntry> weight() => [
        WeightEntry(
          id: 'w1',
          kg: 62.5,
          recordedAt: now.subtract(const Duration(days: 1)),
        ),
        WeightEntry(
          id: 'w2',
          kg: 62.8,
          recordedAt: now.subtract(const Duration(days: 8)),
        ),
        WeightEntry(
          id: 'w3',
          kg: 63.1,
          recordedAt: now.subtract(const Duration(days: 15)),
          note: 'After travel',
        ),
        WeightEntry(
          id: 'w4',
          kg: 63.4,
          recordedAt: now.subtract(const Duration(days: 30)),
        ),
      ];

  static List<SleepSession> sleep() => [
        SleepSession(
          id: 's1',
          bedtime: DateTime(now.year, now.month, now.day - 1, 23, 10),
          wakeTime: DateTime(now.year, now.month, now.day, 6, 35),
          qualityScore: 82,
          deepHours: 1.6,
          remHours: 1.8,
        ),
        SleepSession(
          id: 's2',
          bedtime: DateTime(now.year, now.month, now.day - 2, 23, 40),
          wakeTime: DateTime(now.year, now.month, now.day - 1, 6, 50),
          qualityScore: 74,
          deepHours: 1.2,
          remHours: 1.5,
        ),
        SleepSession(
          id: 's3',
          bedtime: DateTime(now.year, now.month, now.day - 3, 22, 55),
          wakeTime: DateTime(now.year, now.month, now.day - 2, 6, 20),
          qualityScore: 88,
          deepHours: 1.9,
          remHours: 2.0,
        ),
      ];

  static List<NutritionEntry> nutrition() => [
        NutritionEntry(
          id: 'n1',
          meal: 'Breakfast',
          description: 'Greek yogurt, berries, oats',
          calories: 420,
          recordedAt: DateTime(now.year, now.month, now.day, 8, 30),
          proteinG: 24,
          carbsG: 48,
          fatG: 12,
        ),
        NutritionEntry(
          id: 'n2',
          meal: 'Lunch',
          description: 'Grilled chicken salad',
          calories: 540,
          recordedAt: DateTime(now.year, now.month, now.day, 13, 10),
          proteinG: 38,
          carbsG: 22,
          fatG: 28,
        ),
        NutritionEntry(
          id: 'n3',
          meal: 'Snack',
          description: 'Apple + almonds',
          calories: 210,
          recordedAt: DateTime(now.year, now.month, now.day, 16, 0),
          proteinG: 6,
          carbsG: 22,
          fatG: 12,
        ),
        NutritionEntry(
          id: 'n4',
          meal: 'Dinner',
          description: 'Salmon, quinoa, vegetables',
          calories: 610,
          recordedAt: DateTime(now.year, now.month, now.day - 1, 19, 40),
          proteinG: 42,
          carbsG: 45,
          fatG: 24,
        ),
      ];

  static List<HealthInsight> insights() => const [
        HealthInsight(
          id: 'i1',
          title: 'Recovery looks solid',
          body:
              'Your resting heart rate stayed in a calm zone this week. Keep the evening wind-down routine.',
          severity: 'positive',
        ),
        HealthInsight(
          id: 'i2',
          title: 'Hydration nudge',
          body: 'You logged fewer fluids yesterday. Aim for 2 liters today.',
          severity: 'info',
        ),
        HealthInsight(
          id: 'i3',
          title: 'Sleep debt watch',
          body:
              'Two short nights can affect focus. Consider a 20-minute earlier bedtime.',
          severity: 'warning',
          isPremium: true,
        ),
      ];

  static List<AppNotification> notifications() => [
        AppNotification(
          id: 'n1',
          title: 'Medication reminder',
          body: 'Omega-3 is due at 19:00.',
          createdAt: now.subtract(const Duration(minutes: 35)),
          category: 'medication',
        ),
        AppNotification(
          id: 'n2',
          title: 'Doctor visit in 5 days',
          body: 'Annual checkup with Dr. Elif Kara.',
          createdAt: now.subtract(const Duration(hours: 4)),
          category: 'visit',
        ),
        AppNotification(
          id: 'n3',
          title: 'Lab result ready',
          body: 'LDL cholesterol is flagged high — review with your clinician.',
          createdAt: now.subtract(const Duration(days: 1)),
          category: 'lab',
        ),
      ];
}