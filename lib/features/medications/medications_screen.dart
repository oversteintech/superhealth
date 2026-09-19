import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../app/l10n/app_strings.dart';
import '../../data/providers/record_providers.dart';
import '../../domain/privacy/sensitive_notification_copy.dart';
import '../../domain/records/medication_record.dart';

class MedicationsScreen extends ConsumerStatefulWidget {
  const MedicationsScreen({super.key});

  @override
  ConsumerState<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends ConsumerState<MedicationsScreen> {
  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentHealthUserIdProvider);
    final repo = ref.watch(healthRecordsRepositoryProvider);
    final items = repo.listMedications(userId);

    return Scaffold(
      appBar: AfterAppBar(
        title: Text(ref.tr('features.medication')),
        actions: [
          IconButton(
            tooltip: ref.tr('medication.add'),
            icon: const Icon(Icons.add),
            onPressed: () async {
              await repo.upsertMedication(
                MedicationRecord(
                  id: const Uuid().v4(),
                  ownerUserId: userId,
                  name: 'Example tablet',
                  instructionAsEntered:
                      'Take as written by clinician — app does not change dose',
                  reminderTimesLocal: const ['08:00'],
                ),
              );
              setState(() {});
            },
          ),
        ],
      ),
      body: items.isEmpty
          ? AfterEmptyState(
              title: ref.tr('medication.empty_title'),
              subtitle: ref.tr('medication.empty_body'),
            )
          : AfterScaffoldBody(
              child: ListView(
                children: [
                  AfterInlineBanner(
                    message: ref.tr('medication.disclaimer'),
                    icon: Icons.info_outline,
                  ),
                  const SizedBox(height: 12),
                  for (final med in items) ...[
                    AfterCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            med.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(med.instructionAsEntered),
                          const SizedBox(height: 8),
                          Text(
                            SensitiveNotificationCopy.medicationReminder(
                              medicationName: med.name,
                              instruction: med.instructionAsEntered,
                            ).lockScreenBody,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              AfterButton(
                                label: ref.tr('medication.taken'),
                                onPressed: () async {
                                  await repo.markAdherence(
                                    ownerUserId: userId,
                                    medicationId: med.id,
                                    scheduledFor: DateTime.now(),
                                    status: AdherenceStatus.taken,
                                  );
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text(ref.tr('medication.logged_taken')),
                                    ),
                                  );
                                },
                              ),
                              AfterButton(
                                label: ref.tr('medication.snooze'),
                                variant: AfterButtonVariant.secondary,
                                onPressed: () async {
                                  await repo.markAdherence(
                                    ownerUserId: userId,
                                    medicationId: med.id,
                                    scheduledFor: DateTime.now(),
                                    status: AdherenceStatus.snoozed,
                                  );
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        ref.tr('medication.logged_snooze'),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              AfterButton(
                                label: ref.tr('medication.skipped'),
                                variant: AfterButtonVariant.secondary,
                                onPressed: () async {
                                  await repo.markAdherence(
                                    ownerUserId: userId,
                                    medicationId: med.id,
                                    scheduledFor: DateTime.now(),
                                    status: AdherenceStatus.skipped,
                                  );
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        ref.tr('medication.logged_skipped'),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
    );
  }
}
