import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../app/l10n/app_strings.dart';
import '../../data/providers/record_providers.dart';
import '../../domain/records/habit_record.dart';
import '../common/widgets/health_record_card.dart';

class HabitsScreen extends ConsumerStatefulWidget {
  const HabitsScreen({super.key});

  @override
  ConsumerState<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends ConsumerState<HabitsScreen> {
  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentHealthUserIdProvider);
    final repo = ref.watch(healthRecordsRepositoryProvider);
    final goals = repo.listHabits(userId);
    final dayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final logs = repo.habitLogsForDay(userId, dayKey);

    return Scaffold(
      appBar: AfterAppBar(
        title: Text(ref.tr('features.habits')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: ref.tr('habits.add'),
            onPressed: () async {
              await repo.upsertHabit(
                HabitGoal(
                  id: const Uuid().v4(),
                  ownerUserId: userId,
                  title: 'Water',
                  targetPerDay: 8,
                  unitLabel: 'glasses',
                ),
              );
              setState(() {});
            },
          ),
        ],
      ),
      body: goals.isEmpty
          ? AfterEmptyState(
              title: ref.tr('habits.empty_title'),
              subtitle: ref.tr('habits.empty_body'),
            )
          : AfterScaffoldBody(
              child: ListView(
                children: [
                  AfterInlineBanner(
                    message: ref.tr('habits.non_judgmental'),
                    icon: Icons.favorite_outline,
                  ),
                  const SizedBox(height: 12),
                  for (final g in goals)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: HealthRecordCard(
                        title: g.title,
                        lines: [
                          '${ref.tr('habits.target')}: ${g.targetPerDay} ${g.unitLabel}',
                        ],
                        actions: [
                          AfterButton(
                            label: ref.tr('habits.log'),
                            onPressed: () async {
                              final prior = logs
                                  .where((l) => l.goalId == g.id)
                                  .fold<double>(0, (a, b) => a + b.value);
                              await repo.logHabit(
                                HabitLog(
                                  id: const Uuid().v4(),
                                  ownerUserId: userId,
                                  goalId: g.id,
                                  dayKey: dayKey,
                                  value: prior + 1,
                                  loggedAt: DateTime.now().toUtc(),
                                ),
                              );
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(ref.tr('habits.logged')),
                                ),
                              );
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
