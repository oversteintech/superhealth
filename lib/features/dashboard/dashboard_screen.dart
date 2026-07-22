import 'package:after_consumer/after_consumer.dart';
import 'package:after_core/after_core.dart';
import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/config/remote_config_keys.dart';
import '../../app/l10n/app_strings.dart';
import '../../app/navigation/health_feature_navigator.dart';
import '../../app/navigation/health_feature_icons.dart';
import '../../app/offline/offline_controller.dart';
import '../../domain/entities/health_feature.dart';
import '../common/widgets/metric_tile.dart';
import '../common/widgets/section_card.dart';
import 'dashboard_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dashboardProvider);
    final welcome = ref.watch(afterRemoteConfigProvider).getString(
          RemoteConfigKeys.welcomeMessage,
          defaultValue: 'Your health, calmly organized.',
        );
    final offline =
        ref.watch(connectivityStatusProvider) == ConnectivityStatus.offline;

    return async.when(
      loading: () => const Center(child: AfterLoading()),
      error: (e, _) => Center(child: Text('$e')),
      data: (data) {
        final topVitals = data.vitals.take(4).toList();
        final sections = sortFamilyDashboardSections([
          FamilyDashboardSection(
            id: 'hero',
            priority: FamilyDashboardPriority.hero,
            builder: (_) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ref.tr(
                    'dashboard.greeting',
                    args: {
                      'name': data.profile.displayName.split(' ').first,
                    },
                  ),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(welcome),
              ],
            ),
          ),
          FamilyDashboardSection(
            id: 'offline',
            priority: FamilyDashboardPriority.actionRequired,
            visible: offline,
            builder: (_) => Padding(
              padding: const EdgeInsets.only(top: 12),
              child: AfterInlineBanner(
                message: ref.tr('dashboard.offline_banner'),
                icon: Icons.cloud_off_outlined,
              ),
            ),
          ),
          FamilyDashboardSection(
            id: 'features',
            priority: FamilyDashboardPriority.dailyValue,
            order: 0,
            builder: (_) => Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AfterSectionHeader(title: ref.tr('dashboard.core_features')),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: HealthFeatureCatalog.all.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.55,
                    ),
                    itemBuilder: (context, index) {
                      final feature = HealthFeatureCatalog.all[index];
                      return AfterCard(
                        onTap: () => HealthFeatureNavigator.open(
                          context,
                          ref,
                          feature.id,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              HealthFeatureIcons.iconFor(feature.id),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const Spacer(),
                            Text(
                              ref.tr(feature.titleKey),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              ref.tr(feature.subtitleKey),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          FamilyDashboardSection(
            id: 'vitals',
            priority: FamilyDashboardPriority.dailyValue,
            order: 1,
            builder: (_) => Padding(
              padding: const EdgeInsets.only(top: 20),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: [
                  for (final vital in topVitals)
                    MetricTile(
                      label: vital.label,
                      value: vital.displayValue,
                      unit: vital.unit,
                    ),
                ],
              ),
            ),
          ),
          FamilyDashboardSection(
            id: 'medications',
            priority: FamilyDashboardPriority.secondary,
            order: 0,
            builder: (_) => Padding(
              padding: const EdgeInsets.only(top: 20),
              child: SectionCard(
                title: ref.tr('dashboard.medications'),
                subtitle: ref.tr('dashboard.medications_subtitle'),
                trailing: TextButton(
                  onPressed: () => HealthFeatureNavigator.open(
                    context,
                    ref,
                    HealthFeatureId.medication,
                  ),
                  child: Text(ref.tr('common.see_all')),
                ),
                child: Column(
                  children: [
                    for (final med in data.medications.take(3))
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          med.takenToday
                              ? Icons.check_circle
                              : Icons.schedule,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(med.name),
                        subtitle: Text('${med.dosage} · ${med.schedule}'),
                      ),
                  ],
                ),
              ),
            ),
          ),
          FamilyDashboardSection(
            id: 'appointments',
            priority: FamilyDashboardPriority.secondary,
            order: 1,
            builder: (_) => Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SectionCard(
                title: ref.tr('dashboard.appointments'),
                trailing: TextButton(
                  onPressed: () => HealthFeatureNavigator.open(
                    context,
                    ref,
                    HealthFeatureId.doctorVisits,
                  ),
                  child: Text(ref.tr('common.see_all')),
                ),
                child: Column(
                  children: [
                    for (final visit in data.visits.take(2))
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.event_outlined),
                        title: Text(visit.reason),
                        subtitle: Text(
                          '${visit.clinician}\n${visit.startsAt}',
                        ),
                        isThreeLine: true,
                      ),
                  ],
                ),
              ),
            ),
          ),
          FamilyDashboardSection(
            id: 'insights',
            priority: FamilyDashboardPriority.secondary,
            order: 2,
            builder: (_) => Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SectionCard(
                title: ref.tr('dashboard.insights'),
                child: Column(
                  children: [
                    for (final insight in data.insights)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(insight.title),
                        subtitle: Text(insight.body),
                        trailing: insight.isPremium
                            ? const Chip(label: Text('PRO'))
                            : null,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ]);
        return AfterScaffoldBody(
          child: ListView(
            children: [for (final s in sections) s.builder(context)],
          ),
        );
      },
    );
  }
}
