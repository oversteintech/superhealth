import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/app_strings.dart';
import '../../data/providers/record_providers.dart';
import '../../domain/records/observation.dart';
import '../../domain/trends/trend_series.dart';

class TrendsScreen extends ConsumerWidget {
  const TrendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentHealthUserIdProvider);
    final repo = ref.watch(healthRecordsRepositoryProvider);
    final obs = repo.listObservations(userId);
    final series = TrendSeriesBuilder.build(
      observations: obs,
      type: ObservationType.weight,
      displayUnit: 'kg',
    );

    return Scaffold(
      appBar: AfterAppBar(title: Text(ref.tr('features.trends'))),
      body: AfterScaffoldBody(
        child: ListView(
          children: [
            AfterInlineBanner(
              message: ref.tr('trends.gap_policy'),
              icon: Icons.show_chart,
            ),
            const SizedBox(height: 12),
            if (series.points.isEmpty)
              AfterEmptyState(
                title: ref.tr('trends.empty_title'),
                subtitle: ref.tr('trends.empty_body'),
              )
            else ...[
              Text(
                '${ref.tr('trends.series')}: ${series.type.name} (${series.displayUnit})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              for (var i = 0; i < series.points.length; i++) ...[
                AfterCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      '${series.points[i].value.toStringAsFixed(1)} ${series.points[i].unit}',
                    ),
                    subtitle: Text(
                      '${series.points[i].measuredAtUtc.toLocal()}\n'
                      '${ref.tr('trends.source')}: ${series.points[i].sourceLabel}',
                    ),
                    isThreeLine: true,
                  ),
                ),
                if (series.hasGapAfter(i))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      ref.tr('trends.gap_marker'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
