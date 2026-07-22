import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/app_strings.dart';
import '../../data/providers/infrastructure_providers.dart';

final vaccinationsProvider = FutureProvider((ref) {
  return ref.watch(healthRepositoryProvider).getVaccinations();
});

class VaccinationsScreen extends ConsumerWidget {
  const VaccinationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(vaccinationsProvider);
    return Scaffold(
      appBar: AfterAppBar(title: Text(ref.tr('features.vaccinations'))),
      body: async.when(
        loading: () => const Center(child: AfterLoading()),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) => AfterScaffoldBody(
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final vac = items[index];
              return ListTile(
                leading: const Icon(Icons.vaccines_outlined),
                title: Text(vac.name),
                subtitle: Text(
                  '${vac.doseLabel}\n'
                  '${vac.provider}'
                  '${vac.lotNumber != null ? ' · lot ${vac.lotNumber}' : ''}\n'
                  '${ref.tr('vaccinations.given')}: ${vac.administeredAt}'
                  '${vac.nextDueAt != null ? '\n${ref.tr('vaccinations.next')}: ${vac.nextDueAt}' : ''}',
                ),
                isThreeLine: true,
              );
            },
          ),
        ),
      ),
    );
  }
}