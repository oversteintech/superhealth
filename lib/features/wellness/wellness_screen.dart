import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/app_strings.dart';
import '../../data/providers/infrastructure_providers.dart';

final insightsProvider = FutureProvider((ref) {
  return ref.watch(healthRepositoryProvider).getInsights();
});

class WellnessScreen extends ConsumerWidget {
  const WellnessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(insightsProvider);
    return Scaffold(
      appBar: AfterAppBar(title: Text(ref.tr('wellness.title'))),
      body: async.when(
        loading: () => const Center(child: AfterLoading()),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) => AfterScaffoldBody(
          child: ListView(
            children: [
              for (final insight in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AfterCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          insight.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(insight.body),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}