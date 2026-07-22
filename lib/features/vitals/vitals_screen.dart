import 'package:after_core/after_core.dart';
import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/config/feature_flag_keys.dart';
import '../../app/l10n/app_strings.dart';
import '../../app/navigation/health_feature_icons.dart';
import '../../app/navigation/health_feature_navigator.dart';
import '../../data/providers/infrastructure_providers.dart';
import '../../domain/entities/health_feature.dart';
import '../common/widgets/metric_tile.dart';

final vitalsProvider = FutureProvider((ref) {
  return ref.watch(healthRepositoryProvider).getVitals();
});

class VitalsScreen extends ConsumerWidget {
  const VitalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(vitalsProvider);
    final chartsEnabled = ref.watch(afterFeatureFlagsProvider).isEnabled(
          FeatureFlagKeys.vitalsCharts,
          defaultValue: true,
        );

    return async.when(
      loading: () => const Center(child: AfterLoading()),
      error: (e, _) => Center(child: Text('$e')),
      data: (vitals) {
        return AfterScaffoldBody(
          child: ListView(
            children: [
              Text(
                ref.tr('vitals.title'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(ref.tr('vitals.subtitle')),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final id in [
                    HealthFeatureId.heartRate,
                    HealthFeatureId.weight,
                    HealthFeatureId.sleep,
                    HealthFeatureId.nutrition,
                  ])
                    ActionChip(
                      avatar: Icon(HealthFeatureIcons.iconFor(id)),
                      label: Text(
                        ref.tr(
                          HealthFeatureCatalog.all
                              .firstWhere((f) => f.id == id)
                              .titleKey,
                        ),
                      ),
                      onPressed: () =>
                          HealthFeatureNavigator.open(context, ref, id),
                    ),
                ],
              ),
              if (chartsEnabled) ...[
                const SizedBox(height: 16),
                AfterCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ref.tr('vitals.trend')),
                      const SizedBox(height: 12),
                      const AfterSparkline(
                        values: [70.0, 72.0, 71.0, 73.0, 72.0, 74.0, 72.0],
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              ...vitals.map(
                (vital) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: MetricTile(
                    label: vital.label,
                    value: vital.displayValue,
                    unit:
                        '${vital.unit} · ${vital.recordedAt.hour.toString().padLeft(2, '0')}:${vital.recordedAt.minute.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}