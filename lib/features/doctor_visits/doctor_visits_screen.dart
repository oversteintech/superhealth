import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/app_strings.dart';
import '../../data/providers/infrastructure_providers.dart';
import '../common/widgets/health_record_card.dart';

final doctorVisitsProvider = FutureProvider((ref) {
  return ref.watch(healthRepositoryProvider).getDoctorVisits();
});

class DoctorVisitsScreen extends ConsumerWidget {
  const DoctorVisitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(doctorVisitsProvider);
    return Scaffold(
      appBar: AfterAppBar(title: Text(ref.tr('features.doctor_visits'))),
      body: async.when(
        loading: () => const Center(child: AfterLoading()),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) => AfterScaffoldBody(
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final visit = items[index];
              final upcoming = visit.startsAt.isAfter(DateTime.now());
              return HealthRecordCard(
                leading: Icon(
                  upcoming ? Icons.event_available : Icons.history,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: visit.reason,
                lines: [
                  '${visit.clinician} · ${visit.specialty}',
                  visit.clinic,
                  '${visit.startsAt}',
                ],
                actions: visit.followUpRequired
                    ? [Chip(label: Text(ref.tr('visits.follow_up')))]
                    : null,
              );
            },
          ),
        ),
      ),
    );
  }
}
