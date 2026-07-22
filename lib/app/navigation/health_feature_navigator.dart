import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/health_feature.dart';
import '../../features/doctor_visits/doctor_visits_screen.dart';
import '../../features/emergency_card/emergency_card_screen.dart';
import '../../features/heart_rate/heart_rate_screen.dart';
import '../../features/lab_results/lab_results_screen.dart';
import '../../features/medical_records/medical_records_screen.dart';
import '../../features/medications/medications_screen.dart';
import '../../features/nutrition/nutrition_screen.dart';
import '../../features/sleep/sleep_screen.dart';
import '../../features/vaccinations/vaccinations_screen.dart';
import '../../features/weight/weight_screen.dart';
import 'shell_navigation.dart';

abstract final class HealthFeatureNavigator {
  static void open(BuildContext context, WidgetRef ref, HealthFeatureId id) {
    switch (id) {
      case HealthFeatureId.healthAi:
        ref.read(mainTabProvider.notifier).select(MainTab.assistant);
        return;
      case HealthFeatureId.medication:
        _push(context, const MedicationsScreen());
        return;
      case HealthFeatureId.medicalRecords:
        _push(context, const MedicalRecordsScreen());
        return;
      case HealthFeatureId.doctorVisits:
        _push(context, const DoctorVisitsScreen());
        return;
      case HealthFeatureId.labResults:
        _push(context, const LabResultsScreen());
        return;
      case HealthFeatureId.vaccinations:
        _push(context, const VaccinationsScreen());
        return;
      case HealthFeatureId.heartRate:
        _push(context, const HeartRateScreen());
        return;
      case HealthFeatureId.weight:
        _push(context, const WeightScreen());
        return;
      case HealthFeatureId.sleep:
        _push(context, const SleepScreen());
        return;
      case HealthFeatureId.nutrition:
        _push(context, const NutritionScreen());
        return;
      case HealthFeatureId.emergencyCard:
        _push(context, const EmergencyCardScreen());
        return;
    }
  }

  static void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }
}