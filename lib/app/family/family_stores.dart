import 'package:after_consumer/after_consumer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final healthMembershipProvider =
    NotifierProvider<FamilyMembershipController, FamilyMembershipState>(
  () => FamilyMembershipController('super_health.membership.plan'),
);

const healthChrome = FamilyChromeConfig(
  appName: 'SuperHealth',
  headerTitle: 'Health',
  supportEmail: 'superhealth@overstein.com',
  accent: Color(0xFF10B981),
  tagline: 'SuperHealth — powered by After Framework',
  aiTitle: 'SuperHealth AI',
);

final medicationsStoreProvider = familyMapListProvider(
  'super_health.medications',
  seed: const [
    FamilyMapRecord(
      id: 'medications_1',
      fields: {'name': 'Sample name', 'dosage': 'Sample dosage', 'schedule': 'Sample schedule'},
    ),
  ],
);

final medicalRecordsStoreProvider = familyMapListProvider(
  'super_health.medical_records',
  seed: const [
    FamilyMapRecord(
      id: 'medical_records_1',
      fields: {'title': 'Sample title', 'category': 'Sample category', 'notes': 'Sample notes'},
    ),
  ],
);

final doctorVisitsStoreProvider = familyMapListProvider(
  'super_health.doctor_visits',
  seed: const [
    FamilyMapRecord(
      id: 'doctor_visits_1',
      fields: {'title': 'Sample title', 'clinician': 'Sample clinician', 'when': 'Sample when'},
    ),
  ],
);

final labResultsStoreProvider = familyMapListProvider(
  'super_health.lab_results',
  seed: const [
    FamilyMapRecord(
      id: 'lab_results_1',
      fields: {'title': 'Sample title', 'status': 'Sample status', 'date': 'Sample date'},
    ),
  ],
);

final vaccinationsStoreProvider = familyMapListProvider(
  'super_health.vaccinations',
  seed: const [
    FamilyMapRecord(
      id: 'vaccinations_1',
      fields: {'title': 'Sample title', 'date': 'Sample date', 'next': 'Sample next'},
    ),
  ],
);

final heartRateStoreProvider = familyMapListProvider(
  'super_health.heart_rate',
  seed: const [
    FamilyMapRecord(
      id: 'heart_rate_1',
      fields: {'title': 'Sample title', 'value': 'Sample value', 'unit': 'Sample unit'},
    ),
  ],
);

final weightStoreProvider = familyMapListProvider(
  'super_health.weight',
  seed: const [
    FamilyMapRecord(
      id: 'weight_1',
      fields: {'title': 'Sample title', 'value': 'Sample value', 'unit': 'Sample unit'},
    ),
  ],
);

final sleepStoreProvider = familyMapListProvider(
  'super_health.sleep',
  seed: const [
    FamilyMapRecord(
      id: 'sleep_1',
      fields: {'title': 'Sample title', 'hours': 'Sample hours', 'quality': 'Sample quality'},
    ),
  ],
);

final nutritionStoreProvider = familyMapListProvider(
  'super_health.nutrition',
  seed: const [
    FamilyMapRecord(
      id: 'nutrition_1',
      fields: {'title': 'Sample title', 'calories': 'Sample calories', 'notes': 'Sample notes'},
    ),
  ],
);

final emergencyStoreProvider = familyMapListProvider(
  'super_health.emergency',
  seed: const [
    FamilyMapRecord(
      id: 'emergency_1',
      fields: {'title': 'Sample title', 'name': 'Sample name', 'phone': 'Sample phone'},
    ),
  ],
);
