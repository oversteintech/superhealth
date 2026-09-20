import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../app/l10n/app_strings.dart';
import '../../data/providers/record_providers.dart';
import '../../domain/records/observation.dart';
import '../common/widgets/health_record_card.dart';

class ObservationsScreen extends ConsumerStatefulWidget {
  const ObservationsScreen({super.key});

  @override
  ConsumerState<ObservationsScreen> createState() => _ObservationsScreenState();
}

class _ObservationsScreenState extends ConsumerState<ObservationsScreen> {
  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentHealthUserIdProvider);
    final repo = ref.watch(healthRecordsRepositoryProvider);
    final items = repo.listObservations(userId);

    return Scaffold(
      appBar: AfterAppBar(
        title: Text(ref.tr('features.observations')),
        actions: [
          IconButton(
            tooltip: ref.tr('observations.add'),
            icon: const Icon(Icons.add),
            onPressed: () async {
              await repo.upsertObservation(
                Observation(
                  id: const Uuid().v4(),
                  ownerUserId: userId,
                  type: ObservationType.weight,
                  value: 70,
                  unit: 'kg',
                  measuredAt: DateTime.now().toUtc(),
                  sourceKind: DataSourceKind.manual,
                  sourceId: 'user-entry',
                  timeZoneId: 'Europe/Istanbul',
                  reliabilityNote: 'Manual entry — not a medical threshold',
                ),
              );
              setState(() {});
            },
          ),
        ],
      ),
      body: items.isEmpty
          ? AfterEmptyState(
              title: ref.tr('observations.empty_title'),
              subtitle: ref.tr('observations.empty_body'),
            )
          : AfterScaffoldBody(
              child: ListView(
                children: [
                  AfterInlineBanner(
                    message: ref.tr('observations.disclaimer'),
                    icon: Icons.info_outline,
                  ),
                  const SizedBox(height: 12),
                  for (final o in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: HealthRecordCard(
                        title: '${o.type.name}: ${o.value} ${o.unit}',
                        lines: [
                          '${o.measuredAtUtc.toLocal()}',
                          '${o.sourceKind.name}/${o.sourceId}',
                          if (o.reliabilityNote.isNotEmpty) o.reliabilityNote,
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
