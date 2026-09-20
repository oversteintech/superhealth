import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/app_strings.dart';
import '../../data/providers/infrastructure_providers.dart';
import '../common/widgets/health_record_card.dart';

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
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final vac = items[index];
              return HealthRecordCard(
                leading: const Icon(Icons.vaccines_outlined),
                title: vac.name,
                lines: [
                  vac.doseLabel,
                  '${vac.provider}${vac.lotNumber != null ? ' · lot ${vac.lotNumber}' : ''}',
                  '${ref.tr('vaccinations.given')}: ${vac.administeredAt}',
                  if (vac.nextDueAt != null)
                    '${ref.tr('vaccinations.next')}: ${vac.nextDueAt}',
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
