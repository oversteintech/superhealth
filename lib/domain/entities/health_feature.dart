/// Domain feature catalog — no Flutter imports.
enum HealthFeatureId {
  timeline,
  observations,
  habits,
  medication,
  appointments,
  documents,
  profile,
  trends,
  sharing,
  caregivers,
  wearableImport,
  medicalRecords,
  doctorVisits,
  labResults,
  vaccinations,
  heartRate,
  weight,
  sleep,
  nutrition,
  healthAi,
  emergencyCard,
}

class HealthFeature {
  const HealthFeature({
    required this.id,
    required this.titleKey,
    required this.subtitleKey,
  });

  final HealthFeatureId id;
  final String titleKey;
  final String subtitleKey;
}

abstract final class HealthFeatureCatalog {
  static const List<HealthFeature> all = [
    HealthFeature(
      id: HealthFeatureId.timeline,
      titleKey: 'features.timeline',
      subtitleKey: 'features.timeline_sub',
    ),
    HealthFeature(
      id: HealthFeatureId.observations,
      titleKey: 'features.observations',
      subtitleKey: 'features.observations_sub',
    ),
    HealthFeature(
      id: HealthFeatureId.habits,
      titleKey: 'features.habits',
      subtitleKey: 'features.habits_sub',
    ),
    HealthFeature(
      id: HealthFeatureId.medication,
      titleKey: 'features.medication',
      subtitleKey: 'features.medication_sub',
    ),
    HealthFeature(
      id: HealthFeatureId.appointments,
      titleKey: 'features.appointments',
      subtitleKey: 'features.appointments_sub',
    ),
    HealthFeature(
      id: HealthFeatureId.documents,
      titleKey: 'features.documents',
      subtitleKey: 'features.documents_sub',
    ),
    HealthFeature(
      id: HealthFeatureId.profile,
      titleKey: 'features.profile',
      subtitleKey: 'features.profile_sub',
    ),
    HealthFeature(
      id: HealthFeatureId.trends,
      titleKey: 'features.trends',
      subtitleKey: 'features.trends_sub',
    ),
    HealthFeature(
      id: HealthFeatureId.sharing,
      titleKey: 'features.sharing',
      subtitleKey: 'features.sharing_sub',
    ),
    HealthFeature(
      id: HealthFeatureId.caregivers,
      titleKey: 'features.caregivers',
      subtitleKey: 'features.caregivers_sub',
    ),
    HealthFeature(
      id: HealthFeatureId.wearableImport,
      titleKey: 'features.wearable_import',
      subtitleKey: 'features.wearable_import_sub',
    ),
    HealthFeature(
      id: HealthFeatureId.medicalRecords,
      titleKey: 'features.medical_records',
      subtitleKey: 'features.medical_records_sub',
    ),
    HealthFeature(
      id: HealthFeatureId.doctorVisits,
      titleKey: 'features.doctor_visits',
      subtitleKey: 'features.doctor_visits_sub',
    ),
    HealthFeature(
      id: HealthFeatureId.labResults,
      titleKey: 'features.lab_results',
      subtitleKey: 'features.lab_results_sub',
    ),
    HealthFeature(
      id: HealthFeatureId.vaccinations,
      titleKey: 'features.vaccinations',
      subtitleKey: 'features.vaccinations_sub',
    ),
    HealthFeature(
      id: HealthFeatureId.heartRate,
      titleKey: 'features.heart_rate',
      subtitleKey: 'features.heart_rate_sub',
    ),
    HealthFeature(
      id: HealthFeatureId.weight,
      titleKey: 'features.weight',
      subtitleKey: 'features.weight_sub',
    ),
    HealthFeature(
      id: HealthFeatureId.sleep,
      titleKey: 'features.sleep',
      subtitleKey: 'features.sleep_sub',
    ),
    HealthFeature(
      id: HealthFeatureId.nutrition,
      titleKey: 'features.nutrition',
      subtitleKey: 'features.nutrition_sub',
    ),
    HealthFeature(
      id: HealthFeatureId.healthAi,
      titleKey: 'features.health_ai',
      subtitleKey: 'features.health_ai_sub',
    ),
    HealthFeature(
      id: HealthFeatureId.emergencyCard,
      titleKey: 'features.emergency_card',
      subtitleKey: 'features.emergency_card_sub',
    ),
  ];
}
