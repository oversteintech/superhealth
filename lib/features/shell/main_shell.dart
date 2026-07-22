import 'package:after_consumer/after_consumer.dart';
import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/l10n/app_strings.dart';

import '../../app/family/family_stores.dart';
import '../../app/navigation/shell_navigation.dart';
import '../dashboard/dashboard_screen.dart';
import '../family_crud/family_hub_screens.dart';

/// Family shell with After shared top bar (location + notifications + AI).
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  final Set<int> _visited = {0};
  final Map<int, Widget> _bodies = {};

  Widget _body(int index) {
    return _bodies.putIfAbsent(index, () {
      switch (MainTab.values[index]) {
        case MainTab.dashboard:
          return const DashboardScreen();
        case MainTab.live:
          return const FamilyLiveScreen();
        case MainTab.assistant:
          return const FamilyAiTab();
        case MainTab.features:
          return const FamilyFeatureCatalogScreen();
        case MainTab.profile:
          return const FamilySettingsTab();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tab = ref.watch(mainTabProvider);
    final locale = ref.watch(localeCodeProvider);
    final index = MainTab.values.indexOf(tab);
    _visited.add(index);
    final membership = ref.watch(healthMembershipProvider);

    return Scaffold(
      body: Column(
        children: [
          FamilyShellHeader(
            title: healthChrome.shellTitle,
            plan: membership.plan,
            onNotifications: () {},
            onAi: () {
              ref.read(mainTabProvider.notifier).select(MainTab.assistant);
            },
          ),
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                for (final i in _visited)
                  Offstage(
                    offstage: i != index,
                    child: TickerMode(
                      enabled: i == index,
                      child: KeyedSubtree(key: ValueKey(i), child: _body(i)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: AfterNavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          ref.read(mainTabProvider.notifier).select(MainTab.values[i]);
        },
        destinations: [
          AfterNavDestination(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
            label: FamilyUiStrings.t('nav_home', locale),
          ),
          AfterNavDestination(
            icon: Icons.sensors_outlined,
            selectedIcon: Icons.sensors,
            label: FamilyUiStrings.t('nav_live', locale),
          ),
          AfterNavDestination(
            icon: Icons.hub_outlined,
            selectedIcon: Icons.hub_rounded,
            label: FamilyUiStrings.t('nav_ai', locale),
          ),
          AfterNavDestination(
            icon: Icons.grid_view_outlined,
            selectedIcon: Icons.grid_view,
            label: FamilyUiStrings.t('nav_features', locale),
          ),
          AfterNavDestination(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
            label: FamilyUiStrings.t('nav_settings', locale),
          ),
        ],
      ),
    );
  }
}
