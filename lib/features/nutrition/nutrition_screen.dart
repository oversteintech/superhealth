import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/app_strings.dart';
import '../../data/providers/infrastructure_providers.dart';
import '../common/widgets/metric_tile.dart';

final nutritionProvider = FutureProvider((ref) {
  return ref.watch(healthRepositoryProvider).getNutritionEntries();
});

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(nutritionProvider);
    return Scaffold(
      appBar: AfterAppBar(title: Text(ref.tr('features.nutrition'))),
      body: async.when(
        loading: () => const Center(child: AfterLoading()),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) {
          final today = items.where((e) {
            final d = e.recordedAt;
            final n = DateTime.now();
            return d.year == n.year && d.month == n.month && d.day == n.day;
          }).toList();
          final calories = today.fold<int>(0, (sum, e) => sum + e.calories);
          return AfterScaffoldBody(
            child: ListView(
              children: [
                MetricTile(
                  label: ref.tr('nutrition.today'),
                  value: '$calories',
                  unit: 'kcal',
                ),
                const SizedBox(height: 16),
                ...items.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AfterCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${entry.meal} · ${entry.calories} kcal',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(entry.description),
                          const SizedBox(height: 8),
                          Text(
                            'P ${entry.proteinG.toStringAsFixed(0)}g · '
                            'C ${entry.carbsG.toStringAsFixed(0)}g · '
                            'F ${entry.fatG.toStringAsFixed(0)}g',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
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