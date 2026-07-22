import 'package:after_consumer/after_consumer.dart';
import 'package:after_core/after_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_health/app/family/family_stores.dart';
import 'package:super_health/app/platform/after_framework.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('family membership plan change', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: AfterFramework.createSuperHealthAfterOverrides(prefs),
    );
    addTearDown(container.dispose);

    expect(container.read(healthMembershipProvider).plan, AfterUserPlan.free);
    await container.read(healthMembershipProvider.notifier).setPlan(AfterUserPlan.superPlan);
    expect(container.read(healthMembershipProvider).plan, AfterUserPlan.superPlan);
    expect(container.read(healthMembershipProvider).badge, AfterMembershipBadge.gold);
  });

  test('family store CRUD round-trip', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: AfterFramework.createSuperHealthAfterOverrides(prefs),
    );
    addTearDown(container.dispose);

    final notifier = container.read(medicationsStoreProvider.notifier);
    final before = container.read(medicationsStoreProvider).length;
    await notifier.upsert(
      const FamilyMapRecord(
        id: 'smoke_1',
        fields: {'name': 'Smoke', 'note': 'round-trip'},
      ),
    );
    expect(container.read(medicationsStoreProvider).any((e) => e.id == 'smoke_1'), isTrue);
    expect(container.read(medicationsStoreProvider).length, before + 1);
    await notifier.deleteById('smoke_1');
    expect(container.read(medicationsStoreProvider).any((e) => e.id == 'smoke_1'), isFalse);
  });

  test('family dashboard section sort order', () {
    final sections = sortFamilyDashboardSections([
      const FamilyDashboardSection(
        id: 'secondary',
        priority: FamilyDashboardPriority.secondary,
        builder: _box,
      ),
      const FamilyDashboardSection(
        id: 'hero',
        priority: FamilyDashboardPriority.hero,
        builder: _box,
      ),
      const FamilyDashboardSection(
        id: 'hidden',
        priority: FamilyDashboardPriority.hero,
        visible: false,
        builder: _box,
      ),
    ]);
    expect(sections.map((s) => s.id).toList(), ['hero', 'secondary']);
  });
}

Widget _box(BuildContext context) => const SizedBox.shrink();
