import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_health/app/l10n/app_strings.dart';
import 'package:super_health/app/l10n/string_catalog.dart';
import 'package:super_health/app/platform/after_framework.dart';
import 'package:super_health/app/theme/app_theme.dart';
import 'package:super_health/data/providers/record_providers.dart';
import 'package:super_health/features/appointments/appointments_screen.dart';
import 'package:super_health/features/caregivers/caregivers_screen.dart';
import 'package:super_health/features/common/widgets/health_record_card.dart';
import 'package:super_health/features/common/widgets/metric_tile.dart';
import 'package:super_health/features/dashboard/dashboard_screen.dart';
import 'package:super_health/features/documents/documents_vault_screen.dart';
import 'package:super_health/features/doctor_visits/doctor_visits_screen.dart';
import 'package:super_health/features/habits/habits_screen.dart';
import 'package:super_health/features/lab_results/lab_results_screen.dart';
import 'package:super_health/features/medications/medications_screen.dart';
import 'package:super_health/features/observations/observations_screen.dart';
import 'package:super_health/features/onboarding/onboarding_screen.dart';
import 'package:super_health/features/sharing/sharing_screen.dart';
import 'package:super_health/features/timeline/timeline_screen.dart';
import 'package:super_health/features/vaccinations/vaccinations_screen.dart';

/// Fail if a RenderFlex overflow (or similar) exception is reported.
void expectNoOverflow(WidgetTester tester) {
  final exception = tester.takeException();
  expect(exception, isNull, reason: 'Unexpected layout exception: $exception');
  // Flutter reports overflows via FlutterError; takeException catches them.
}

Map<String, String> _minimalCatalog() => {
      'dashboard.greeting': 'Hello, {name}',
      'dashboard.offline_banner': 'Offline',
      'dashboard.core_features': 'Core features',
      'dashboard.medications': 'Medications',
      'dashboard.medications_subtitle': 'Today',
      'dashboard.appointments': 'Visits',
      'dashboard.insights': 'Reminders',
      'dashboard.missing_data': 'Some days have no measurements yet.',
      'common.see_all': 'See all',
      'features.timeline': 'Timeline',
      'features.observations': 'Measurements',
      'features.habits': 'Routines',
      'features.appointments': 'Appointments',
      'features.documents': 'Documents',
      'features.medication': 'Medication',
      'features.doctor_visits': 'Doctor Visits',
      'features.lab_results': 'Lab Results',
      'features.vaccinations': 'Vaccinations',
      'features.caregivers': 'Care circle',
      'features.sharing': 'Sharing',
      'features.timeline_sub': 'Notes and files',
      'features.observations_sub': 'Unit and time',
      'features.habits_sub': 'Goals',
      'features.appointments_sub': 'Visits',
      'features.documents_sub': 'Vault',
      'features.profile': 'Profile',
      'features.profile_sub': 'Units',
      'features.trends': 'Trends',
      'features.trends_sub': 'Gaps stay empty',
      'features.sharing_sub': 'CSV PDF',
      'features.caregivers_sub': 'Invite',
      'features.wearable_import': 'Wearable',
      'features.wearable_import_sub': 'Demo',
      'features.medication_sub': 'Doses',
      'features.medical_records': 'Records',
      'features.medical_records_sub': 'Files',
      'features.doctor_visits_sub': 'Clinics',
      'features.lab_results_sub': 'Panels',
      'features.vaccinations_sub': 'Doses',
      'features.heart_rate': 'Heart Rate',
      'features.heart_rate_sub': 'Resting',
      'features.weight': 'Weight',
      'features.weight_sub': 'Progress',
      'features.sleep': 'Sleep',
      'features.sleep_sub': 'Duration',
      'features.nutrition': 'Nutrition',
      'features.nutrition_sub': 'Meals',
      'features.health_ai': 'Health AI',
      'features.health_ai_sub': 'Mate',
      'features.emergency_card': 'Emergency',
      'features.emergency_card_sub': 'Critical',
      'timeline.empty_title': 'No timeline',
      'timeline.empty_body': 'Add a measurement',
      'timeline.disclaimer': 'Personal records only',
      'observations.add': 'Add',
      'observations.empty_title': 'No measurements',
      'observations.empty_body': 'Add a value',
      'observations.disclaimer': 'Not thresholds',
      'habits.add': 'Add',
      'habits.empty_title': 'No routines',
      'habits.empty_body': 'Set a goal',
      'habits.non_judgmental': 'No guilt',
      'habits.target': 'Target',
      'habits.log': 'Log',
      'habits.logged': 'Logged',
      'appointments.empty_title': 'No appointments',
      'appointments.empty_body': 'Add visits',
      'documents.empty_title': 'Vault empty',
      'documents.empty_body': 'Add files',
      'documents.delete': 'Delete',
      'medication.empty_title': 'No meds',
      'medication.empty_body': 'Add one',
      'medication.add': 'Add',
      'medication.disclaimer': 'As written',
      'medication.taken': 'Taken',
      'medication.snooze': 'Snooze',
      'medication.skipped': 'Skipped',
      'medication.logged_taken': 'Taken',
      'medication.logged_snooze': 'Snoozed',
      'medication.logged_skipped': 'Skipped',
      'caregivers.default_no_full_access': 'No full access',
      'caregivers.empty_title': 'No members',
      'caregivers.empty_body': 'Invite',
      'caregivers.invite': 'Invite',
      'caregivers.none': 'none',
      'caregivers.revoke': 'Revoke',
      'sharing.disclaimer': 'Exports only chosen',
      'sharing.create_csv': 'CSV',
      'sharing.create_pdf': 'PDF',
      'sharing.active_grants': 'Grants',
      'sharing.none': 'None',
      'sharing.active': 'active',
      'sharing.revoked': 'revoked',
      'sharing.revoke': 'Revoke',
      'sharing.preview': 'Preview',
      'sharing.audit': 'Audit',
      'visits.follow_up': 'Follow-up',
      'vaccinations.given': 'Given',
      'vaccinations.next': 'Next',
      'onboarding.page1_title': 'Know your vitals',
      'onboarding.page1_body': 'Track calmly',
      'onboarding.page2_title': 'Care in one place',
      'onboarding.page2_body': 'Organized',
      'onboarding.consent_title': 'Your data',
      'onboarding.consent_body': 'Choose storage',
      'onboarding.consent_local': 'Store locally',
      'onboarding.consent_reminders': 'Reminders',
      'onboarding.next': 'Next',
      'onboarding.get_started': 'Get started',
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late StringCatalog catalog;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    catalog = StringCatalog.forTest({'en': _minimalCatalog()});
  });

  Future<void> pumpScreen(
    WidgetTester tester,
    Widget screen, {
    Size size = const Size(320, 568),
    double textScale = 1.3,
  }) async {
    tester.view.physicalSize = size * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          stringCatalogProvider.overrideWithValue(catalog),
          sharedPreferencesProvider.overrideWithValue(prefs),
          ...AfterFramework.createSuperHealthAfterOverrides(prefs),
        ],
        child: MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(textScale),
          ),
          child: MaterialApp(
            theme: SuperHealthTheme.light(),
            home: screen,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  group('Overflow guard, unit widgets', () {
    testWidgets('HealthRecordCard clamps long title and lines', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: HealthRecordCard(
                title: 'A' * 80,
                lines: ['B' * 120, 'C' * 120],
                actions: [
                  TextButton(onPressed: () {}, child: const Text('Revoke now')),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expectNoOverflow(tester);
    });

    testWidgets('MetricTile clamps long label/value/unit', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 140,
              height: 112,
              child: MetricTile(
                label: 'Blood pressure systolic diastolic',
                value: '120/80-extra',
                unit: 'mmHg-millimeters',
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expectNoOverflow(tester);
    });
  });

  group('Overflow guard, screens at phone + large text', () {
    testWidgets('DashboardScreen', (tester) async {
      await pumpScreen(tester, const DashboardScreen());
      expect(find.byType(DashboardScreen), findsOneWidget);
      expectNoOverflow(tester);
    });

    testWidgets('OnboardingScreen consent page scrolls', (tester) async {
      await pumpScreen(
        tester,
        OnboardingScreen(onFinished: () async {}),
        size: const Size(320, 480),
        textScale: 1.4,
      );
      // Advance to consent page.
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Store locally'), findsOneWidget);
      expectNoOverflow(tester);
    });

    testWidgets('TimelineScreen', (tester) async {
      await pumpScreen(tester, const TimelineScreen());
      expectNoOverflow(tester);
    });

    testWidgets('ObservationsScreen', (tester) async {
      await pumpScreen(tester, const ObservationsScreen());
      expectNoOverflow(tester);
    });

    testWidgets('HabitsScreen', (tester) async {
      await pumpScreen(tester, const HabitsScreen());
      expectNoOverflow(tester);
    });

    testWidgets('AppointmentsScreen', (tester) async {
      await pumpScreen(tester, const AppointmentsScreen());
      expectNoOverflow(tester);
    });

    testWidgets('DocumentsVaultScreen', (tester) async {
      await pumpScreen(tester, const DocumentsVaultScreen());
      expectNoOverflow(tester);
    });

    testWidgets('MedicationsScreen', (tester) async {
      await pumpScreen(tester, const MedicationsScreen());
      expectNoOverflow(tester);
    });

    testWidgets('CaregiversScreen', (tester) async {
      await pumpScreen(tester, const CaregiversScreen());
      expectNoOverflow(tester);
    });

    testWidgets('SharingScreen', (tester) async {
      await pumpScreen(tester, const SharingScreen());
      expectNoOverflow(tester);
    });

    testWidgets('DoctorVisitsScreen', (tester) async {
      await pumpScreen(tester, const DoctorVisitsScreen());
      expectNoOverflow(tester);
    });

    testWidgets('LabResultsScreen', (tester) async {
      await pumpScreen(tester, const LabResultsScreen());
      expectNoOverflow(tester);
    });

    testWidgets('VaccinationsScreen', (tester) async {
      await pumpScreen(tester, const VaccinationsScreen());
      expectNoOverflow(tester);
    });
  });
}
