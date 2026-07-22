import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/app_strings.dart';
import '../../data/providers/infrastructure_providers.dart';

final labResultsProvider = FutureProvider((ref) {
  return ref.watch(healthRepositoryProvider).getLabResults();
});

class LabResultsScreen extends ConsumerWidget {
  const LabResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(labResultsProvider);
    return Scaffold(
      appBar: AfterAppBar(title: Text(ref.tr('features.lab_results'))),
      body: async.when(
        loading: () => const Center(child: AfterLoading()),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) => AfterScaffoldBody(
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final lab = items[index];
              final color = lab.isFlagged
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary;
              return ListTile(
                leading: Icon(Icons.science_outlined, color: color),
                title: Text(lab.testName),
                subtitle: Text(
                  '${lab.value} ${lab.unit} · ref ${lab.referenceRange}\n'
                  '${lab.collectedAt}',
                ),
                isThreeLine: true,
                trailing: Text(
                  lab.status.toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}