import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/app_strings.dart';
import '../../data/providers/infrastructure_providers.dart';
import '../common/widgets/metric_tile.dart';

final weightProvider = FutureProvider((ref) {
  return ref.watch(healthRepositoryProvider).getWeightEntries();
});

class WeightScreen extends ConsumerWidget {
  const WeightScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(weightProvider);
    return Scaffold(
      appBar: AfterAppBar(title: Text(ref.tr('features.weight'))),
      body: async.when(
        loading: () => const Center(child: AfterLoading()),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) {
          final latest = items.first;
          final delta = items.length > 1 ? latest.kg - items.last.kg : 0.0;
          return AfterScaffoldBody(
            child: ListView(
              children: [
                MetricTile(
                  label: ref.tr('weight.latest'),
                  value: latest.kg.toStringAsFixed(1),
                  unit: 'kg',
                ),
                const SizedBox(height: 12),
                Text(
                  '${ref.tr('weight.change_30d')}: '
                  '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)} kg',
                ),
                const SizedBox(height: 16),
                AfterCard(
                  child: AfterSparkline(
                    values: items.reversed.map((e) => e.kg).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                ...items.map(
                  (entry) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.monitor_weight_outlined),
                    title: Text('${entry.kg.toStringAsFixed(1)} kg'),
                    subtitle: Text(
                      entry.note.isEmpty
                          ? '${entry.recordedAt}'
                          : '${entry.recordedAt} · ${entry.note}',
                    ),
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