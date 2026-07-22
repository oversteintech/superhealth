import 'package:after_consumer/after_consumer.dart';
import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final index = MainTab.values.indexOf(tab);
    _visited.add(index);
    final membership = ref.watch(healthMembershipProvider);

    return Scaffold(
      body: Column(
        children: [
          FamilyShellHeader(
            title: healthChrome.shellTitle,
            plan: membership.plan,
            onLocationTap: () {},
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
        destinations: const [
          AfterNavDestination(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
            label: 'Home',
          ),
          AfterNavDestination(
            icon: Icons.sensors_outlined,
            selectedIcon: Icons.sensors,
            label: 'Live',
          ),
          AfterNavDestination(
            icon: Icons.auto_awesome_outlined,
            selectedIcon: Icons.auto_awesome,
            label: 'AI',
          ),
          AfterNavDestination(
            icon: Icons.grid_view_outlined,
            selectedIcon: Icons.grid_view,
            label: 'Features',
          ),
          AfterNavDestination(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
