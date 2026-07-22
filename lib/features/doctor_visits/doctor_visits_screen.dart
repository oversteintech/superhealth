import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/app_strings.dart';
import '../../data/providers/infrastructure_providers.dart';

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
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final visit = items[index];
              final upcoming = visit.startsAt.isAfter(DateTime.now());
              return ListTile(
                leading: Icon(
                  upcoming ? Icons.event_available : Icons.history,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(visit.reason),
                subtitle: Text(
                  '${visit.clinician} · ${visit.specialty}\n'
                  '${visit.clinic}\n${visit.startsAt}',
                ),
                isThreeLine: true,
                trailing: visit.followUpRequired
                    ? Chip(label: Text(ref.tr('visits.follow_up')))
                    : null,
              );
            },
          ),
        ),
      ),
    );
  }
}