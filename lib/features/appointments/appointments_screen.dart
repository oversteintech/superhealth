import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../app/l10n/app_strings.dart';
import '../../data/providers/record_providers.dart';
import '../../domain/records/care_appointment.dart';
import '../common/widgets/health_record_card.dart';

class AppointmentsScreen extends ConsumerWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentHealthUserIdProvider);
    final repo = ref.watch(healthRecordsRepositoryProvider);
    final items = repo.listAppointments(userId);

    return Scaffold(
      appBar: AfterAppBar(
        title: Text(ref.tr('features.appointments')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await repo.upsertAppointment(
                CareAppointment(
                  id: const Uuid().v4(),
                  ownerUserId: userId,
                  title: 'Check-up',
                  startsAt: DateTime.now().toUtc().add(const Duration(days: 3)),
                  location: 'Clinic',
                  clinicianName: 'Dr. Example',
                  questions: const ['Ask about recent labs'],
                  reminderMinutesBefore: 60,
                ),
              );
              if (context.mounted) (context as Element).markNeedsBuild();
            },
          ),
        ],
      ),
      body: items.isEmpty
          ? AfterEmptyState(
              title: ref.tr('appointments.empty_title'),
              subtitle: ref.tr('appointments.empty_body'),
            )
          : AfterScaffoldBody(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final a = items[i];
                  return HealthRecordCard(
                    title: a.title,
                    lines: [
                      a.clinicianName,
                      a.location,
                      '${a.startsAt.toLocal()}',
                    ],
                  );
                },
              ),
            ),
    );
  }
}
