import 'package:flutter/material.dart';

import '../../domain/entities/health_feature.dart';

abstract final class HealthFeatureIcons {
  static const Map<HealthFeatureId, IconData> _icons = {
    HealthFeatureId.timeline: Icons.timeline_outlined,
    HealthFeatureId.observations: Icons.monitor_heart_outlined,
    HealthFeatureId.habits: Icons.water_drop_outlined,
    HealthFeatureId.medication: Icons.medication_outlined,
    HealthFeatureId.appointments: Icons.event_outlined,
    HealthFeatureId.documents: Icons.folder_special_outlined,
    HealthFeatureId.profile: Icons.person_outline,
    HealthFeatureId.trends: Icons.show_chart,
    HealthFeatureId.sharing: Icons.ios_share_outlined,
    HealthFeatureId.caregivers: Icons.family_restroom,
    HealthFeatureId.wearableImport: Icons.watch_outlined,
    HealthFeatureId.medicalRecords: Icons.folder_shared_outlined,
    HealthFeatureId.doctorVisits: Icons.local_hospital_outlined,
    HealthFeatureId.labResults: Icons.science_outlined,
    HealthFeatureId.vaccinations: Icons.vaccines_outlined,
    HealthFeatureId.heartRate: Icons.favorite_outline,
    HealthFeatureId.weight: Icons.monitor_weight_outlined,
    HealthFeatureId.sleep: Icons.bedtime_outlined,
    HealthFeatureId.nutrition: Icons.restaurant_outlined,
    HealthFeatureId.healthAi: Icons.auto_awesome_outlined,
    HealthFeatureId.emergencyCard: Icons.emergency_outlined,
  };

  static IconData iconFor(HealthFeatureId id) =>
      _icons[id] ?? Icons.circle_outlined;
}
