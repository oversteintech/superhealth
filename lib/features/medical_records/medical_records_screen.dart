import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/app_strings.dart';
import '../../data/providers/infrastructure_providers.dart';

final medicalRecordsProvider = FutureProvider((ref) {
  return ref.watch(healthRepositoryProvider).getMedicalRecords();
});

class MedicalRecordsScreen extends ConsumerWidget {
  const MedicalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(medicalRecordsProvider);
    return Scaffold(
      appBar: AfterAppBar(title: Text(ref.tr('features.medical_records'))),
      body: async.when(
        loading: () => const Center(child: AfterLoading()),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) => AfterScaffoldBody(
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final record = items[index];
              return AfterCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text('${record.category} · ${record.provider}'),
                    const SizedBox(height: 8),
                    Text(record.summary),
                    if (record.attachmentLabel != null) ...[
                      const SizedBox(height: 8),
                      Chip(label: Text(record.attachmentLabel!)),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}