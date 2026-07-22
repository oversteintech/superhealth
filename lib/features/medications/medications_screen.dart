import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/app_strings.dart';
import '../../data/providers/infrastructure_providers.dart';

final medicationsProvider = FutureProvider((ref) {
  return ref.watch(healthRepositoryProvider).getMedications();
});

class MedicationsScreen extends ConsumerWidget {
  const MedicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(medicationsProvider);
    return Scaffold(
      appBar: AfterAppBar(title: Text(ref.tr('features.medication'))),
      body: async.when(
        loading: () => const Center(child: AfterLoading()),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) => AfterScaffoldBody(
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final med = items[index];
              return ListTile(
                leading: Icon(
                  med.takenToday ? Icons.check_circle : Icons.medication_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(med.name),
                subtitle: Text('${med.dosage} · ${med.schedule}'),
                trailing: Text(
                  med.takenToday
                      ? ref.tr('medication.taken')
                      : ref.tr('medication.due'),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}