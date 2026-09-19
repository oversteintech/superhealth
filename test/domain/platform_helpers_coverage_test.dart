import 'package:after_core/after_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_health/app/errors/error_handler.dart';
import 'package:super_health/app/family/family_stores.dart';
import 'package:super_health/app/l10n/app_strings.dart';
import 'package:super_health/app/l10n/string_catalog.dart';
import 'package:super_health/app/platform/adapters/product_analytics.dart';
import 'package:super_health/app/platform/after_framework.dart';
import 'package:super_health/app/platform/crash_reporting.dart';
import 'package:super_health/app/theme/app_theme.dart';
import 'package:super_health/domain/entities/app_notification.dart';
import 'package:super_health/domain/entities/sleep_session.dart';
import 'package:super_health/domain/entities/vital_reading.dart';
import 'package:super_health/domain/privacy/privacy_preferences.dart';
import 'package:super_health/domain/privacy/sensitive_payload_filter.dart';
import 'package:super_health/domain/records/audit_event.dart';
import 'package:super_health/domain/records/care_circle_member.dart';
import 'package:super_health/domain/records/health_profile_record.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('PrivacyPreferences getters and setters', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final privacy = PrivacyPreferences(prefs);

    expect(privacy.lockEnabled, isFalse);
    expect(privacy.hideNotificationBody, isTrue);
    expect(privacy.blockScreenshots, isFalse);
    expect(privacy.clearOnSignOut, isTrue);
    expect(privacy.remindersEnabled, isFalse);
    expect(privacy.cloudClarityAcknowledged, isFalse);

    await privacy.setLockEnabled(true);
    await privacy.setHideNotificationBody(false);
    await privacy.setBlockScreenshots(true);
    await privacy.setClearOnSignOut(false);
    await privacy.setRemindersEnabled(true);
    await privacy.setCloudClarityAcknowledged(true);

    expect(privacy.lockEnabled, isTrue);
    expect(privacy.hideNotificationBody, isFalse);
    expect(privacy.blockScreenshots, isTrue);
    expect(privacy.clearOnSignOut, isFalse);
    expect(privacy.remindersEnabled, isTrue);
    expect(privacy.cloudClarityAcknowledged, isTrue);
  });

  test('SensitivePayloadFilter sanitizes and detects', () {
    final safe = SensitivePayloadFilter.sanitize({
      'plan': 'free',
      'medication': 'hidden',
      'note': 'penicillin',
      'ok': 'short',
      'long': 'x' * 100,
      'glucose_value': 120,
    });
    expect(safe.keys, containsAll(['plan', 'ok']));
    expect(safe.containsKey('medication'), isFalse);
    expect(safe.containsKey('note'), isFalse);
    expect(safe.containsKey('long'), isFalse);
    expect(safe.containsKey('glucose_value'), isFalse);

    expect(
      SensitivePayloadFilter.containsSensitive({'dose': '1mg'}),
      isTrue,
    );
    expect(
      SensitivePayloadFilter.containsSensitive({'plan': 'free'}),
      isFalse,
    );
    expect(
      SensitivePayloadFilter.auditSafe(
        AuditEvent(
          id: 'a',
          ownerUserId: 'u',
          action: 'x',
          occurredAt: DateTime.now().toUtc(),
          metadata: const {'scope': 'share'},
        ),
      ),
      isTrue,
    );
  });

  test('CareCircleMember json and full access', () {
    final member = CareCircleMember(
      id: 'c1',
      ownerUserId: 'u1',
      memberLabel: 'Parent',
      role: CareMemberRole.caregiver,
      visibleFields: CareFieldVisibility.values,
      invitedAt: DateTime.utc(2026, 1, 1),
      acceptedAt: DateTime.utc(2026, 1, 2),
    );
    expect(member.hasFullAccess, isTrue);
    final round = CareCircleMember.fromJson(member.toJson());
    expect(round.acceptedAt, DateTime.utc(2026, 1, 2));
    expect(
      round.copyWith(revokedAt: DateTime.utc(2026, 2, 1)).isActive,
      isFalse,
    );
  });

  test('HealthProfile copyWith keeps identity', () {
    const profile = HealthProfile(
      id: 'p1',
      ownerUserId: 'u1',
      displayName: 'Ayhan',
      birthYear: 1990,
    );
    final patched = profile.copyWith(ageBand: '30-39', displayName: 'A.');
    expect(patched.ageBand, '30-39');
    expect(patched.displayName, 'A.');
    expect(patched.birthYear, 1990);
  });

  test('ProductAnalytics drops clinical properties', () async {
    final analytics = ProductAnalytics(const ConsoleAfterLogger());
    await analytics.logEvent(
      'x',
      parameters: {'medication': 'Aspirin', 'plan': 'free'},
    );
    expect(analytics.events.single.containsKey('medication'), isFalse);
    expect(analytics.events.single['plan'], 'free');
    await analytics.setUserId('uid-1');
    await analytics.setUserProperty('medication', 'Aspirin');
    await analytics.setUserProperty('tier', 'silver');
    await analytics.logScreenView('Timeline', screenClass: 'TimelineScreen');
    expect(analytics.events.any((e) => e['name'] == 'screen_view'), isTrue);
  });

  test('CrashReporting and ErrorHandler', () {
    CrashReporting.install(const ConsoleAfterLogger());
    CrashReporting.recordError(Exception('boom'), StackTrace.current);
    CrashReporting.recordFlutterError(
      FlutterErrorDetails(
        exception: Exception('ui'),
        stack: StackTrace.current,
      ),
    );
    ErrorHandler.report(
      Exception('handled'),
      StackTrace.current,
      logger: const ConsoleAfterLogger(),
    );
    expect(
      ErrorHandler.userMessage(Exception('x')),
      contains('Something went wrong'),
    );
    expect(
      ErrorHandler.userMessage(const AfterAuthException('Friendly')),
      'Friendly',
    );
  });

  testWidgets('ErrorHandler snack bar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () => ErrorHandler.showSnackBar(context, 'Oops'),
                child: const Text('Go'),
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('Go'));
    await tester.pump();
    expect(find.text('Oops'), findsOneWidget);
  });

  test('VitalReading labels, SleepSession, AppNotification', () {
    for (final kind in VitalKind.values) {
      expect(
        VitalReading(
          id: kind.name,
          kind: kind,
          value: 1,
          unit: 'u',
          recordedAt: DateTime.utc(2026),
        ).label,
        isNotEmpty,
      );
    }
    expect(
      VitalReading(
        id: 'bp',
        kind: VitalKind.bloodPressure,
        value: 120,
        unit: 'mmHg',
        recordedAt: DateTime.utc(2026),
        secondaryValue: 80,
      ).displayValue,
      '120/80',
    );
    expect(
      VitalReading(
        id: 'hr',
        kind: VitalKind.heartRate,
        value: 72.5,
        unit: 'bpm',
        recordedAt: DateTime.utc(2026),
      ).displayValue,
      '72.5',
    );
    final sleep = SleepSession(
      id: 's1',
      bedtime: DateTime.utc(2026, 9, 18, 23),
      wakeTime: DateTime.utc(2026, 9, 19, 7),
      qualityScore: 80,
    );
    expect(sleep.durationHours, closeTo(8, 0.01));
    final n = AppNotification(
      id: 'n1',
      title: 't',
      body: 'b',
      createdAt: DateTime.utc(2026),
    );
    expect(n.copyWith(isRead: true).isRead, isTrue);
  });

  test('theme, string catalog, locale, entitlement, family stores', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final catalog = StringCatalog.forTest({
      'en': {'hello': 'Hello {name}'},
      'tr': {'hello': 'Merhaba {name}'},
    });
    expect(catalog.t('hello', args: {'name': 'Ayhan'}), 'Hello Ayhan');
    catalog.setLocale('tr');
    expect(catalog.t('hello', args: {'name': 'Ayhan'}), 'Merhaba Ayhan');
    expect(catalog.t('missing'), 'missing');

    expect(SuperHealthTheme.light(), isA<ThemeData>());
    expect(SuperHealthTheme.dark(), isA<ThemeData>());

    final container = ProviderContainer(
      overrides: [
        stringCatalogProvider.overrideWithValue(catalog),
        ...AfterFramework.createSuperHealthAfterOverrides(prefs),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(localeCodeProvider), isNotEmpty);
    container.read(localeCodeProvider.notifier).setLocale('tr');
    container.read(localeCodeProvider.notifier).setLocale(null);
    expect(container.read(healthMembershipProvider).plan, AfterUserPlan.free);
    expect(
      container.read(afterEntitlementProvider).canUse(AfterPlanFeature.aiUnlimited),
      isFalse,
    );

    expect(container.read(medicationsStoreProvider), isNotEmpty);
    expect(container.read(medicalRecordsStoreProvider), isNotEmpty);
    expect(container.read(doctorVisitsStoreProvider), isNotEmpty);
    expect(container.read(labResultsStoreProvider), isNotEmpty);
    expect(container.read(vaccinationsStoreProvider), isNotEmpty);
    expect(container.read(heartRateStoreProvider), isNotEmpty);
    expect(container.read(weightStoreProvider), isNotEmpty);
    expect(container.read(sleepStoreProvider), isNotEmpty);
    expect(container.read(nutritionStoreProvider), isNotEmpty);
    expect(container.read(emergencyStoreProvider), isNotEmpty);
    expect(healthChrome.appName, 'Health');
  });
}
