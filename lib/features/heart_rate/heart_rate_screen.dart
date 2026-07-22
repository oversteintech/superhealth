import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/app_strings.dart';
import '../../data/providers/infrastructure_providers.dart';
import '../common/widgets/metric_tile.dart';

final heartRateProvider = FutureProvider((ref) {
  return ref.watch(healthRepositoryProvider).getHeartRateSamples();
});

class HeartRateScreen extends ConsumerWidget {
  const HeartRateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(heartRateProvider);
    return Scaffold(
      appBar: AfterAppBar(title: Text(ref.tr('features.heart_rate'))),
      body: async.when(
        loading: () => const Center(child: AfterLoading()),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) {
          final latest = items.first;
          return AfterScaffoldBody(
            child: ListView(
              children: [
                MetricTile(
                  label: ref.tr('heart_rate.latest'),
                  value: '${latest.bpm}',
                  unit: 'bpm · ${latest.context}',
                  accent: Theme.of(context).colorScheme.tertiary,
                ),
                const SizedBox(height: 16),
                AfterCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ref.tr('heart_rate.trend')),
                      const SizedBox(height: 12),
                      AfterSparkline(
                        values: items.map((e) => e.bpm.toDouble()).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ...items.map(
                  (sample) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.favorite_outline),
                    title: Text('${sample.bpm} bpm'),
                    subtitle: Text('${sample.context} · ${sample.recordedAt}'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}