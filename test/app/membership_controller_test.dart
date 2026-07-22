import 'dart:async';

import 'package:after_core/after_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_health/app/membership/membership_controller.dart';
import 'package:super_health/app/platform/after_framework.dart';

Future<AfterAuthSession> _awaitAuthed(ProviderContainer container) {
  final completer = Completer<AfterAuthSession>();
  final sub = container.listen<AsyncValue<AfterAuthSession>>(
    afterAuthSessionProvider,
    (previous, next) {
      final value = next.asData?.value;
      if (value != null && value.isAuthenticated && !completer.isCompleted) {
        completer.complete(value);
      }
    },
    fireImmediately: true,
  );
  return completer.future.whenComplete(sub.close).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException(
          'authenticated session was not observed',
        ),
      );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('membership controller upgrades plan', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: AfterFramework.createSuperHealthAfterOverrides(prefs),
    );
    addTearDown(container.dispose);
    await container
        .read(membershipControllerProvider.notifier)
        .upgradeToPremium();
    expect(
      container.read(membershipControllerProvider).plan,
      AfterUserPlan.premium,
    );
  });

  test('superadmin email elevates membership to superadmin', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: AfterFramework.createSuperHealthAfterOverrides(
        prefs,
        mockGoogleEmailForTests: 'ayhanuzundal@gmail.com',
      ),
    );
    addTearDown(container.dispose);

    await container.read(afterAuthRepositoryProvider).signInWithGoogle();
    await _awaitAuthed(container);

    final membership = container.read(membershipControllerProvider);
    expect(membership.plan, AfterUserPlan.superadmin);
    expect(membership.badge, AfterMembershipBadge.admin);
    expect(
      membership.entitlement.canUse(AfterPlanFeature.aiUnlimited),
      isTrue,
    );
  });

  test('non-admin google email keeps stored plan', () async {
    SharedPreferences.setMockInitialValues({
      'super_health.membership.plan': 'premium',
    });
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: AfterFramework.createSuperHealthAfterOverrides(
        prefs,
        mockGoogleEmailForTests: 'member@gmail.com',
      ),
    );
    addTearDown(container.dispose);

    await container.read(afterAuthRepositoryProvider).signInWithGoogle();
    await _awaitAuthed(container);

    final membership = container.read(membershipControllerProvider);
    expect(membership.plan, AfterUserPlan.premium);
  });

  test('never restores superadmin plan from prefs alone', () async {
    SharedPreferences.setMockInitialValues({
      'super_health.membership.plan': 'superadmin',
    });
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: AfterFramework.createSuperHealthAfterOverrides(prefs),
    );
    addTearDown(container.dispose);

    final membership = container.read(membershipControllerProvider);
    expect(membership.plan, AfterUserPlan.free);
  });
}
