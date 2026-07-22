import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/app_strings.dart';
import '../../data/providers/infrastructure_providers.dart';
import '../../domain/entities/doctor_visit.dart';
import '../../domain/entities/health_insight.dart';
import '../../domain/entities/lab_result.dart';
import '../../domain/entities/medical_record.dart';
import '../../domain/entities/medication.dart';
import '../../domain/entities/nutrition_entry.dart';
import '../../domain/entities/vaccination.dart';
import '../common/widgets/empty_placeholder.dart';

final searchQueryProvider =
    NotifierProvider<SearchQueryController, String>(SearchQueryController.new);

class SearchQueryController extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) => state = value;

  void clear() => state = '';
}

final searchResultsProvider = FutureProvider<List<Object>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  return ref.watch(healthRepositoryProvider).search(query);
});

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(searchResultsProvider);

    return AfterScaffoldBody(
      child: Column(
        children: [
          AfterSearchField(
            hint: ref.tr('search.hint'),
            onChanged: (value) =>
                ref.read(searchQueryProvider.notifier).setQuery(value),
            onClear: () => ref.read(searchQueryProvider.notifier).clear(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: results.when(
              loading: () => const Center(child: AfterLoading()),
              error: (e, _) => Center(child: Text('$e')),
              data: (items) {
                if (items.isEmpty) {
                  return EmptyPlaceholder(
                    title: ref.tr('search.empty_title'),
                    message: ref.tr('search.empty_body'),
                  );
                }
                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    if (item is Medication) {
                      return ListTile(
                        leading: const Icon(Icons.medication_outlined),
                        title: Text(item.name),
                        subtitle: Text(item.dosage),
                      );
                    }
                    if (item is DoctorVisit) {
                      return ListTile(
                        leading: const Icon(Icons.local_hospital_outlined),
                        title: Text(item.reason),
                        subtitle: Text(item.clinician),
                      );
                    }
                    if (item is MedicalRecord) {
                      return ListTile(
                        leading: const Icon(Icons.folder_shared_outlined),
                        title: Text(item.title),
                        subtitle: Text(item.category),
                      );
                    }
                    if (item is LabResult) {
                      return ListTile(
                        leading: const Icon(Icons.science_outlined),
                        title: Text(item.testName),
                        subtitle: Text('${item.value} ${item.unit}'),
                      );
                    }
                    if (item is Vaccination) {
                      return ListTile(
                        leading: const Icon(Icons.vaccines_outlined),
                        title: Text(item.name),
                        subtitle: Text(item.doseLabel),
                      );
                    }
                    if (item is NutritionEntry) {
                      return ListTile(
                        leading: const Icon(Icons.restaurant_outlined),
                        title: Text(item.meal),
                        subtitle: Text(item.description),
                      );
                    }
                    if (item is HealthInsight) {
                      return ListTile(
                        leading: const Icon(Icons.lightbulb_outline),
                        title: Text(item.title),
                        subtitle: Text(item.body),
                      );
                    }
                    return ListTile(title: Text('$item'));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}