import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/app_strings.dart';
import '../../data/providers/infrastructure_providers.dart';
import '../common/widgets/metric_tile.dart';

final sleepProvider = FutureProvider((ref) {
  return ref.watch(healthRepositoryProvider).getSleepSessions();
});

class SleepScreen extends ConsumerWidget {
  const SleepScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(sleepProvider);
    return Scaffold(
      appBar: AfterAppBar(title: Text(ref.tr('features.sleep'))),
      body: async.when(
        loading: () => const Center(child: AfterLoading()),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) {
          final latest = items.first;
          return AfterScaffoldBody(
            child: ListView(
              children: [
                MetricTile(
                  label: ref.tr('sleep.last_night'),
                  value: latest.durationHours.toStringAsFixed(1),
                  unit: 'h · score ${latest.qualityScore}',
                ),
                const SizedBox(height: 16),
                AfterCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ref.tr('sleep.stages')),
                      const SizedBox(height: 8),
                      Text(
                        '${ref.tr('sleep.deep')}: '
                        '${latest.deepHours.toStringAsFixed(1)} h',
                      ),
                      Text(
                        '${ref.tr('sleep.rem')}: '
                        '${latest.remHours.toStringAsFixed(1)} h',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ...items.map(
                  (session) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.bedtime_outlined),
                    title: Text(
                      '${session.durationHours.toStringAsFixed(1)} h',
                    ),
                    subtitle: Text(
                      '${session.bedtime} → ${session.wakeTime}\n'
                      '${ref.tr('sleep.quality')}: ${session.qualityScore}',
                    ),
                    isThreeLine: true,
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