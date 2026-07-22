import 'package:after_consumer/after_consumer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final healthMembershipProvider =
    NotifierProvider<FamilyMembershipController, FamilyMembershipState>(
  () => FamilyMembershipController('super_health.membership.plan'),
);

const healthChrome = FamilyChromeConfig(
  appName: 'Health',
  headerTitle: 'Health',
  supportEmail: 'superhealth@overstein.com',
  accent: Color(0xFF10B981),
  productId: AfterProductId.health,
  tagline: 'SuperHealth — powered by After Framework',
  aiTitle: 'SuperHealth AI',
);

final medicationsStoreProvider = familyMapListProvider(
  'super_health.medications',
  seed: const [
    FamilyMapRecord(
      id: 'medications_1',
      fields: {'name': 'Can Demir', 'dosage': 'Medications dosage 1', 'schedule': 'As needed'},
    ),
    FamilyMapRecord(
      id: 'medications_2',
      fields: {'name': 'Ece Kara', 'dosage': 'Medications dosage 2', 'schedule': 'Daily 06:00'},
    ),
  ],
);

final medicalRecordsStoreProvider = familyMapListProvider(
  'super_health.medical_records',
  seed: const [
    FamilyMapRecord(
      id: 'medical_records_1',
      fields: {'title': 'Medical Records — Morning briefing', 'category': 'Archive', 'notes': 'All clear'},
    ),
    FamilyMapRecord(
      id: 'medical_records_2',
      fields: {'title': 'Medical Records — Weekend plan', 'category': 'General', 'notes': 'Follow up next week'},
    ),
  ],
);

final doctorVisitsStoreProvider = familyMapListProvider(
  'super_health.doctor_visits',
  seed: const [
    FamilyMapRecord(
      id: 'doctor_visits_1',
      fields: {'title': 'Doctor Visits — Morning briefing', 'clinician': 'Doctor Visits clinician 1', 'when': '2026-07-24 14:30'},
    ),
    FamilyMapRecord(
      id: 'doctor_visits_2',
      fields: {'title': 'Doctor Visits — Weekend plan', 'clinician': 'Doctor Visits clinician 2', 'when': '2026-07-26 09:00'},
    ),
  ],
);

final labResultsStoreProvider = familyMapListProvider(
  'super_health.lab_results',
  seed: const [
    FamilyMapRecord(
      id: 'lab_results_1',
      fields: {'title': 'Lab Results — Morning briefing', 'status': 'completed', 'date': '2026-07-22'},
    ),
    FamilyMapRecord(
      id: 'lab_results_2',
      fields: {'title': 'Lab Results — Weekend plan', 'status': 'on hold', 'date': '2026-07-28'},
    ),
  ],
);

final vaccinationsStoreProvider = familyMapListProvider(
  'super_health.vaccinations',
  seed: const [
    FamilyMapRecord(
      id: 'vaccinations_1',
      fields: {'title': 'Vaccinations — Morning briefing', 'date': '2026-08-01', 'next': '2027-01-12'},
    ),
    FamilyMapRecord(
      id: 'vaccinations_2',
      fields: {'title': 'Vaccinations — Weekend plan', 'date': '2026-07-20', 'next': '2026-08-01'},
    ),
  ],
);

final heartRateStoreProvider = familyMapListProvider(
  'super_health.heart_rate',
  seed: const [
    FamilyMapRecord(
      id: 'heart_rate_1',
      fields: {'title': 'Heart Rate — Morning briefing', 'value': 'Heart Rate value 1', 'unit': 'kg'},
    ),
    FamilyMapRecord(
      id: 'heart_rate_2',
      fields: {'title': 'Heart Rate — Weekend plan', 'value': 'Heart Rate value 2', 'unit': 'lt'},
    ),
  ],
);

final weightStoreProvider = familyMapListProvider(
  'super_health.weight',
  seed: const [
    FamilyMapRecord(
      id: 'weight_1',
      fields: {'title': 'Weight — Morning briefing', 'value': 'Weight value 1', 'unit': 'box'},
    ),
    FamilyMapRecord(
      id: 'weight_2',
      fields: {'title': 'Weight — Weekend plan', 'value': 'Weight value 2', 'unit': 'pcs'},
    ),
  ],
);

final sleepStoreProvider = familyMapListProvider(
  'super_health.sleep',
  seed: const [
    FamilyMapRecord(
      id: 'sleep_1',
      fields: {'title': 'Sleep — Morning briefing', 'hours': '09:00–18:00', 'quality': 'Sleep quality 1'},
    ),
    FamilyMapRecord(
      id: 'sleep_2',
      fields: {'title': 'Sleep — Weekend plan', 'hours': '24/7', 'quality': 'Sleep quality 2'},
    ),
  ],
);

final nutritionStoreProvider = familyMapListProvider(
  'super_health.nutrition',
  seed: const [
    FamilyMapRecord(
      id: 'nutrition_1',
      fields: {'title': 'Nutrition — Morning briefing', 'calories': 'Nutrition calories 1', 'notes': 'Needs review'},
    ),
    FamilyMapRecord(
      id: 'nutrition_2',
      fields: {'title': 'Nutrition — Weekend plan', 'calories': 'Nutrition calories 2', 'notes': 'All clear'},
    ),
  ],
);

final emergencyStoreProvider = familyMapListProvider(
  'super_health.emergency',
  seed: const [
    FamilyMapRecord(
      id: 'emergency_1',
      fields: {'title': 'Emergency — Morning briefing', 'name': 'Ada Yılmaz', 'phone': '+90 533 200 3000'},
    ),
    FamilyMapRecord(
      id: 'emergency_2',
      fields: {'title': 'Emergency — Weekend plan', 'name': 'Can Demir', 'phone': '+90 534 300 4000'},
    ),
  ],
);
