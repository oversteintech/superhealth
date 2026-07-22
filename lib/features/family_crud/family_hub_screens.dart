import 'package:after_ai/after_ai.dart';
import 'package:after_consumer/after_consumer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/family/family_stores.dart';
import '../../app/l10n/app_strings.dart';
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
            leading: Icon(Icons.sensors),
            title: Text('Signal OK'),
            subtitle: Text('Last pulse: just now'),
          ),
          ListTile(
            leading: Icon(Icons.timeline),
            title: Text('Trend stable'),
            subtitle: Text('No alerts'),
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
      onSend: (prompt) => platform.chat(message: prompt),
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
      canUsePremiumThemes: true,
      localeCode: ref.watch(localeCodeProvider),
      onLocale: (c) {
        if (c == null) return;
        ref.read(localeCodeProvider.notifier).setLocale(c);
      },
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
      _Feat('Medications', MedicationsCrudScreen.new),
      _Feat('Medical Records', MedicalRecordsCrudScreen.new),
      _Feat('Doctor Visits', DoctorVisitsCrudScreen.new),
      _Feat('Lab Results', LabResultsCrudScreen.new),
      _Feat('Vaccinations', VaccinationsCrudScreen.new),
      _Feat('Heart Rate', HeartRateCrudScreen.new),
      _Feat('Weight', WeightCrudScreen.new),
      _Feat('Sleep', SleepCrudScreen.new),
      _Feat('Nutrition', NutritionCrudScreen.new),
      _Feat('Emergency', EmergencyCrudScreen.new),
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
