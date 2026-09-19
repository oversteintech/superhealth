import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/health_feature.dart';
import '../../domain/membership/health_entitlement_matrix.dart';
import '../../features/appointments/appointments_screen.dart';
import '../../app/family/family_stores.dart';
import '../../features/caregivers/caregivers_screen.dart';
import '../../features/documents/documents_vault_screen.dart';
import '../../features/doctor_visits/doctor_visits_screen.dart';
import '../../features/habits/habits_screen.dart';
import '../../features/heart_rate/heart_rate_screen.dart';
import '../../features/lab_results/lab_results_screen.dart';
import '../../features/medical_records/medical_records_screen.dart';
import '../../features/medications/medications_screen.dart';
import '../../features/nutrition/nutrition_screen.dart';
import '../../features/observations/observations_screen.dart';
import '../../features/profile/personal_profile_screen.dart';
import '../../features/sharing/sharing_screen.dart';
import '../../features/sleep/sleep_screen.dart';
import '../../features/timeline/timeline_screen.dart';
import '../../features/trends/trends_screen.dart';
import '../../features/vaccinations/vaccinations_screen.dart';
import '../../features/wearable/wearable_import_screen.dart';
import '../../features/weight/weight_screen.dart';
import 'shell_navigation.dart';

abstract final class HealthFeatureNavigator {
  static void open(BuildContext context, WidgetRef ref, HealthFeatureId id) {
    switch (id) {
      case HealthFeatureId.timeline:
        _push(context, const TimelineScreen());
      case HealthFeatureId.observations:
        _push(context, const ObservationsScreen());
      case HealthFeatureId.habits:
        _push(context, const HabitsScreen());
      case HealthFeatureId.appointments:
        _push(context, const AppointmentsScreen());
      case HealthFeatureId.documents:
        _push(context, const DocumentsVaultScreen());
      case HealthFeatureId.profile:
        _push(context, const PersonalProfileScreen());
      case HealthFeatureId.trends:
        _push(context, const TrendsScreen());
      case HealthFeatureId.sharing:
        _push(context, const SharingScreen());
      case HealthFeatureId.caregivers:
        final plan = ref.read(healthMembershipProvider).plan;
        if (!HealthEntitlementMatrix.canOpenFeature(
          plan: plan,
          id: HealthFeatureId.caregivers,
        )) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Care circle invites need Gold or Business. Personal records stay free.',
              ),
            ),
          );
          return;
        }
        _push(context, const CaregiversScreen());
      case HealthFeatureId.wearableImport:
        _push(context, const WearableImportScreen());
      case HealthFeatureId.healthAi:
        ref.read(mainTabProvider.notifier).select(MainTab.assistant);
      case HealthFeatureId.medication:
        _push(context, const MedicationsScreen());
      case HealthFeatureId.medicalRecords:
        _push(context, const MedicalRecordsScreen());
      case HealthFeatureId.doctorVisits:
        _push(context, const DoctorVisitsScreen());
      case HealthFeatureId.labResults:
        _push(context, const LabResultsScreen());
      case HealthFeatureId.vaccinations:
        _push(context, const VaccinationsScreen());
      case HealthFeatureId.heartRate:
        _push(context, const HeartRateScreen());
      case HealthFeatureId.weight:
        _push(context, const WeightScreen());
      case HealthFeatureId.sleep:
        _push(context, const SleepScreen());
      case HealthFeatureId.nutrition:
        _push(context, const NutritionScreen());
      case HealthFeatureId.emergencyCard:
        _push(context, const EmergencyCardManageScreen());
    }
  }

  static void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }
}
