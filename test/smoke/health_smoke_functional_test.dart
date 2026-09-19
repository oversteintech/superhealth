import 'package:after_core/after_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_health/app/family/family_stores.dart';
import 'package:super_health/app/l10n/app_strings.dart';
import 'package:super_health/app/l10n/string_catalog.dart';
import 'package:super_health/app/platform/after_framework.dart';
import 'package:super_health/app/theme/app_theme.dart';
import 'package:super_health/data/local/health_records_repository.dart';
import 'package:super_health/data/providers/record_providers.dart';
import 'package:super_health/domain/entities/health_feature.dart';
import 'package:super_health/domain/membership/health_entitlement_matrix.dart';
import 'package:super_health/domain/records/observation.dart';
import 'package:super_health/features/appointments/appointments_screen.dart';
import 'package:super_health/features/auth/login_screen.dart';
import 'package:super_health/features/caregivers/caregivers_screen.dart';
import 'package:super_health/features/documents/documents_vault_screen.dart';
import 'package:super_health/features/habits/habits_screen.dart';
import 'package:super_health/features/medications/medications_screen.dart';
import 'package:super_health/features/observations/observations_screen.dart';
import 'package:super_health/features/privacy/privacy_security_screen.dart';
import 'package:super_health/features/sharing/sharing_screen.dart';
import 'package:super_health/features/timeline/timeline_screen.dart';
import 'package:super_health/features/trends/trends_screen.dart';
import 'package:super_health/features/wearable/wearable_import_screen.dart';

/// Functional smoke suite — pumps core P0/P1 screens and asserts chrome + journeys.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late StringCatalog catalog;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    catalog = StringCatalog.forTest({
      'en': {
        'auth.welcome_title': 'Welcome back',
        'auth.welcome_subtitle': 'Sign in to continue your health journey.',
        'auth.email': 'Email',
        'auth.password': 'Password',
        'auth.sign_in': 'Sign in',
        'auth.continue_google': 'Continue with Google',
        'auth.superadmin_hint':
            'Signing in with an Overstein admin email unlocks Super Admin.',
        'features.timeline': 'Timeline',
        'features.observations': 'Measurements',
        'features.habits': 'Routines',
        'features.appointments': 'Appointments',
        'features.documents': 'Document vault',
        'features.trends': 'Trends',
        'features.sharing': 'Sharing',
        'features.caregivers': 'Care circle',
        'features.wearable_import': 'Wearable import',
        'features.medication': 'Medication',
        'timeline.empty_title': 'No timeline entries yet',
        'timeline.empty_body':
            'Add a measurement or note. This is a personal log, not a diagnosis.',
        'timeline.disclaimer':
            'Entries are your records. Source and time are shown.',
        'observations.add': 'Add measurement',
        'observations.empty_title': 'No measurements',
        'observations.empty_body':
            'Add a value with unit, time, timezone, and source.',
        'observations.disclaimer':
            'Reference ranges are not personal medical thresholds.',
        'habits.add': 'Add routine',
        'habits.empty_title': 'No routines yet',
        'habits.empty_body': 'Set a personal goal. No guilt language.',
        'habits.non_judgmental': 'Progress is yours — no streaks guilt.',
        'habits.target': 'Target',
        'habits.log': 'Log',
        'habits.logged': 'Logged',
        'appointments.empty_title': 'No appointments',
        'appointments.empty_body': 'Track visits and questions here.',
        'documents.empty_title': 'Vault is empty',
        'documents.empty_body': 'Add lab or prescription files.',
        'documents.delete': 'Delete document',
        'trends.gap_policy': 'Missing intervals are not filled with lines.',
        'trends.empty_title': 'No trend points',
        'trends.empty_body': 'Add weight measurements first.',
        'sharing.disclaimer': 'Exports include only categories you choose.',
        'sharing.create_csv': 'Create CSV share (7 days)',
        'sharing.create_pdf': 'Create PDF-text share (7 days)',
        'sharing.active_grants': 'Share grants',
        'sharing.none': 'No shares yet',
        'sharing.audit': 'Audit log',
        'caregivers.default_no_full_access':
            'Invites grant zero fields by default.',
        'caregivers.empty_title': 'No care circle members',
        'caregivers.empty_body': 'Invite with limited fields.',
        'caregivers.invite': 'Invite',
        'caregivers.none': 'none',
        'caregivers.revoke': 'Revoke',
        'wearable.demo_banner': 'Demo feed until a real platform is connected.',
        'wearable.live_banner': 'Platform connected with permission.',
        'wearable.platform': 'Platform',
        'wearable.demo_chip': 'Demo',
        'wearable.request_permission': 'Request permission',
        'wearable.permission_ok': 'Permission granted (demo)',
        'wearable.import': 'Import since last week',
        'wearable.imported': 'Imported {count} new samples',
        'wearable.last_count': 'Last import count',
        'medication.empty_title': 'No medications',
        'medication.empty_body': 'Store name and instructions as written.',
        'medication.add': 'Add medication',
        'medication.disclaimer': 'Instructions are stored as written.',
        'medication.taken': 'Taken',
        'medication.snooze': 'Snooze',
        'medication.skipped': 'Skipped',
        'medication.logged_taken': 'Logged taken',
        'medication.logged_snooze': 'Logged snooze',
        'medication.logged_skipped': 'Logged skipped',
        'privacy.title': 'Privacy & security',
        'privacy.cloud_clarity': 'Records stay on this device by default.',
        'privacy.ack_cloud': 'I understand on-device vs optional cloud storage',
        'privacy.plan': 'Membership',
        'privacy.records_free': 'Personal health records are included on Free.',
        'privacy.lock': 'App lock (PIN / biometric-ready)',
        'privacy.lock_hint': 'Stores a PIN in secure storage.',
        'privacy.pin': 'PIN (min 4 digits)',
        'privacy.save_pin': 'Save PIN',
        'privacy.hide_notif': 'Hide sensitive notification bodies',
        'privacy.block_screenshots': 'Prefer blocking screenshots',
        'privacy.clear_signout': 'Clear local views when signing out',
        'privacy.reminders': 'Medication / appointment reminders',
        'privacy.consent': 'Consent versions',
        'privacy.consent_version': 'Current policy version',
        'privacy.renew_local_consent': 'Renew local store consent',
        'privacy.data': 'Your data',
        'privacy.export': 'Export all local health JSON',
        'privacy.delete_all': 'Delete all local health data',
        'privacy.access_log': 'Access / audit log',
        'privacy.access_empty': 'No access events yet',
      },
    });
  });

  Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          stringCatalogProvider.overrideWithValue(catalog),
          sharedPreferencesProvider.overrideWithValue(prefs),
          ...AfterFramework.createSuperHealthAfterOverrides(prefs),
        ],
        child: MaterialApp(
          theme: SuperHealthTheme.light(),
          home: screen,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  group('Smoke functional, auth', () {
    testWidgets('LoginScreen', (tester) async {
      await pumpScreen(tester, const LoginScreen());
      expect(find.text('Sign in'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Smoke functional, P0 records', () {
    testWidgets('TimelineScreen', (tester) async {
      await pumpScreen(tester, const TimelineScreen());
      expect(find.byType(Scaffold), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ObservationsScreen empty', (tester) async {
      await pumpScreen(tester, const ObservationsScreen());
      expect(find.text('No measurements'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('HabitsScreen empty', (tester) async {
      await pumpScreen(tester, const HabitsScreen());
      expect(find.text('No routines yet'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(find.text('Water'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('AppointmentsScreen empty', (tester) async {
      await pumpScreen(tester, const AppointmentsScreen());
      expect(find.text('No appointments'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(find.text('Check-up'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('DocumentsVaultScreen empty', (tester) async {
      await pumpScreen(tester, const DocumentsVaultScreen());
      expect(find.text('Vault is empty'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(find.textContaining('Lab panel'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('MedicationsScreen empty', (tester) async {
      await pumpScreen(tester, const MedicationsScreen());
      expect(find.text('No medications'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Smoke functional, P1 sharing & privacy', () {
    testWidgets('TrendsScreen', (tester) async {
      await pumpScreen(tester, const TrendsScreen());
      expect(find.text('No trend points'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('SharingScreen', (tester) async {
      await pumpScreen(tester, const SharingScreen());
      expect(find.text('Create CSV share (7 days)'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('CaregiversScreen', (tester) async {
      await pumpScreen(tester, const CaregiversScreen());
      expect(find.text('No care circle members'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('WearableImportScreen', (tester) async {
      await pumpScreen(tester, const WearableImportScreen());
      expect(find.text('Demo'), findsOneWidget);
      expect(find.text('Request permission'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('PrivacySecurityScreen', (tester) async {
      await pumpScreen(tester, const PrivacySecurityScreen());
      expect(find.text('Privacy & security'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });

  group('Smoke functional, journeys', () {
    test('observation write then timeline provider resolves', () async {
      final container = ProviderContainer(
        overrides: [
          stringCatalogProvider.overrideWithValue(catalog),
          sharedPreferencesProvider.overrideWithValue(prefs),
          ...AfterFramework.createSuperHealthAfterOverrides(prefs),
        ],
      );
      addTearDown(container.dispose);

      final repo = container.read(healthRecordsRepositoryProvider);
      await repo.upsertObservation(
        Observation(
          id: 'smoke-obs',
          ownerUserId: 'local-user',
          type: ObservationType.weight,
          value: 70,
          unit: 'kg',
          measuredAt: DateTime.utc(2026, 9, 19),
          sourceKind: DataSourceKind.manual,
          sourceId: 'user',
        ),
      );

      final events = await container.read(timelineEventsProvider.future);
      expect(events.any((e) => e.id == 'smoke-obs'), isTrue);
      expect(repo, isA<HealthRecordsRepository>());
    });

    test('membership upgrade keeps personal records free', () async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          ...AfterFramework.createSuperHealthAfterOverrides(prefs),
        ],
      );
      addTearDown(container.dispose);

      expect(
        HealthEntitlementMatrix.canOpenFeature(
          plan: AfterUserPlan.free,
          id: HealthFeatureId.timeline,
        ),
        isTrue,
      );

      await container
          .read(healthMembershipProvider.notifier)
          .setPlan(AfterUserPlan.superPlan);
      expect(container.read(healthMembershipProvider).plan, AfterUserPlan.superPlan);
      expect(
        HealthEntitlementMatrix.canOpenFeature(
          plan: container.read(healthMembershipProvider).plan,
          id: HealthFeatureId.timeline,
        ),
        isTrue,
      );
      expect(
        HealthEntitlementMatrix.canOpenFeature(
          plan: container.read(healthMembershipProvider).plan,
          id: HealthFeatureId.caregivers,
        ),
        isTrue,
      );
    });
  });
}
