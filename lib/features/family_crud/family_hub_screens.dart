import 'dart:async';

import 'package:after_ai/after_ai.dart';
import 'package:after_consumer/after_consumer.dart';
import 'package:after_core/after_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/family/family_stores.dart';
import '../../app/l10n/app_strings.dart';
import '../../domain/privacy/ai_safety_policy.dart';
import '../assistant/orchestrator/health_ai_in_app_route_catalog.dart';
import '../privacy/privacy_security_screen.dart';
import '../timeline/timeline_screen.dart';
import '../medications/medications_screen.dart';
import '../observations/observations_screen.dart';
import '../habits/habits_screen.dart';
import '../appointments/appointments_screen.dart';
import '../documents/documents_vault_screen.dart';
import '../profile/personal_profile_screen.dart';
import '../trends/trends_screen.dart';
import '../sharing/sharing_screen.dart';
import '../caregivers/caregivers_screen.dart';
import '../wearable/wearable_import_screen.dart';
import 'medications_crud_screen.dart';
import 'medical_records_crud_screen.dart';
import 'doctor_visits_crud_screen.dart';
import 'lab_results_crud_screen.dart';
import 'vaccinations_crud_screen.dart';
import 'heart_rate_crud_screen.dart';
import 'weight_crud_screen.dart';
import 'sleep_crud_screen.dart';
import 'nutrition_crud_screen.dart';
import 'emergency_crud_screen.dart';

class FamilyLiveScreen extends StatelessWidget {
  const FamilyLiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FamilyLiveScaffold(
      title: 'Vitals Live',
      subtitle: 'Mock live stream — hardware adapters later',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.warning_amber_outlined),
            title: Text('Mock wearable view'),
            subtitle: Text(
              'No validated device is connected. Source, measurement time, and accuracy are not clinical-grade.',
            ),
          ),
          ListTile(
            leading: Icon(Icons.sensors),
            title: Text('Demo pulse'),
            subtitle: Text('Source: demo/mock · measured: sample only'),
          ),
        ],
      ),
    );
  }
}

class FamilyAiTab extends ConsumerWidget {
  const FamilyAiTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platform = ref.watch(afterAiPlatformProvider);
    return FamilyAiChatScreen(
      title: healthChrome.aiTitle,
      onSend: (prompt) async {
        final payload = AiSafetyPolicy.buildPayload(userMessage: prompt);
        if (payload.blocked) {
          return AiSafetyPolicy.refuseClinicalEn;
        }
        final inApp = HealthAiInAppRouteCatalog.resolve(prompt);
        if (inApp != null) {
          return '${inApp.message}\n\n${AiSafetyPolicy.refuseClinicalEn}';
        }
        final reply = await platform.chat(message: prompt);
        return '$reply\n\n${AiSafetyPolicy.refuseClinicalEn}';
      },
    );
  }
}

class FamilySettingsTab extends ConsumerWidget {
  const FamilySettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membership = ref.watch(healthMembershipProvider);
    return FamilySettingsScreen(
      config: healthChrome,
      membership: membership,
      onSetPlan: (p) => ref.read(healthMembershipProvider.notifier).setPlan(p),
      themeStyle: ref.watch(familyThemeStyleProvider),
      onThemeStyle: (s) =>
          ref.read(familyThemeStyleProvider.notifier).setStyle(s),
      canUsePremiumThemes:
          membership.plan.isAtLeast(AfterUserPlan.premium) || membership.isSuperAdmin,
      localeCode: ref.watch(localeCodeProvider),
      onLocale: (c) {
        if (c == null) return;
        ref.read(localeCodeProvider.notifier).setLocale(c);
      },
      countryCode: ref.watch(afterCountryCodeProvider),
      onCountry: (c) {
        unawaited(
          ref.read(afterCountryCodeProvider.notifier).setCountry(
                c,
                legacyKey: 'superhealth.country',
              ),
        );
      },
      plugins: FamilySettingsPlugins(
        securityExtras: (context, ref) => [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.health_and_safety_outlined),
            title: Text(ref.tr('privacy.open')),
            subtitle: Text(ref.tr('privacy.open_sub')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PrivacySecurityScreen(),
              ),
            ),
          ),
        ],
        onExportData: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const PrivacySecurityScreen(),
            ),
          );
        },
      ),
      embedded: true,
    );
  }
}

class _Feat {
  const _Feat(this.title, this.builder);
  final String title;
  final Widget Function({Key? key}) builder;
}

class FamilyFeatureCatalogScreen extends StatelessWidget {
  const FamilyFeatureCatalogScreen({super.key});

    static final items = <_Feat>[
      _Feat('Timeline', TimelineScreen.new),
      _Feat('Measurements', ObservationsScreen.new),
      _Feat('Routines', HabitsScreen.new),
      _Feat('Medications', MedicationsScreen.new),
      _Feat('Appointments', AppointmentsScreen.new),
      _Feat('Documents', DocumentsVaultScreen.new),
      _Feat('Health profile', PersonalProfileScreen.new),
      _Feat('Trends', TrendsScreen.new),
      _Feat('Sharing', SharingScreen.new),
      _Feat('Caregivers', CaregiversScreen.new),
      _Feat('Wearable import', WearableImportScreen.new),
      _Feat('Emergency card', EmergencyCardManageScreen.new),
      _Feat('Medications (CRUD kit)', MedicationsCrudScreen.new),
      _Feat('Medical Records', MedicalRecordsCrudScreen.new),
      _Feat('Doctor Visits', DoctorVisitsCrudScreen.new),
      _Feat('Lab Results', LabResultsCrudScreen.new),
      _Feat('Vaccinations', VaccinationsCrudScreen.new),
      _Feat('Heart Rate', HeartRateCrudScreen.new),
      _Feat('Weight', WeightCrudScreen.new),
      _Feat('Sleep', SleepCrudScreen.new),
      _Feat('Nutrition', NutritionCrudScreen.new),
      _Feat('Emergency (CRUD kit)', EmergencyCrudScreen.new),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Features')),
      body: ListView(
        children: [
          for (final item in items)
            ListTile(
              title: Text(item.title),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => item.builder()),
              ),
            ),
        ],
      ),
    );
  }
}
