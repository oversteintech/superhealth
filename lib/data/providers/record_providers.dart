import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../local/health_records_repository.dart';
import '../local/prefs_health_local_database.dart';
import '../local/user_scoped_observation_store.dart';
import 'infrastructure_providers.dart';
import '../../domain/records/timeline_event.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw StateError('SharedPreferences must be overridden at bootstrap');
});

final currentHealthUserIdProvider = Provider<String>((ref) => 'local-user');

final prefsHealthDatabaseProvider = Provider<PrefsHealthLocalDatabase>((ref) {
  return PrefsHealthLocalDatabase(ref.watch(sharedPreferencesProvider));
});

final healthRecordsRepositoryProvider = Provider<HealthRecordsRepository>((ref) {
  return HealthRecordsRepository(ref.watch(prefsHealthDatabaseProvider));
});

/// Legacy observation-only store kept for Prompt 0 tests.
final observationStoreProvider = Provider<UserScopedObservationStore>((ref) {
  return UserScopedObservationStore(ref.watch(sharedPreferencesProvider));
});

final timelineEventsProvider =
    FutureProvider<List<TimelineEvent>>((ref) async {
  final userId = ref.watch(currentHealthUserIdProvider);
  final records = ref.watch(healthRecordsRepositoryProvider);
  final events = <TimelineEvent>[];

  for (final o in records.listObservations(userId)) {
    events.add(
      TimelineEvent(
        id: o.id,
        ownerUserId: o.ownerUserId,
        kind: TimelineKind.observation,
        occurredAt: o.measuredAtUtc,
        title: '${o.type.name}: ${o.value} ${o.unit}',
        sourceLabel: '${o.sourceKind.name}/${o.sourceId}',
        detail: o.reliabilityNote,
      ),
    );
  }
  for (final s in records.listSymptoms(userId)) {
    events.add(
      TimelineEvent(
        id: s.id,
        ownerUserId: s.ownerUserId,
        kind: TimelineKind.symptomNote,
        occurredAt: s.occurredAt,
        title: s.label,
        sourceLabel: 'manual/user',
        detail: s.freeNote,
      ),
    );
  }
  for (final a in records.listAppointments(userId)) {
    events.add(
      TimelineEvent(
        id: a.id,
        ownerUserId: a.ownerUserId,
        kind: TimelineKind.appointment,
        occurredAt: a.startsAt,
        title: a.title,
        sourceLabel: a.clinicianName.isEmpty ? 'appointment' : a.clinicianName,
        detail: a.location,
      ),
    );
  }
  for (final d in records.listDocuments(userId)) {
    events.add(
      TimelineEvent(
        id: d.id,
        ownerUserId: d.ownerUserId,
        kind: TimelineKind.document,
        occurredAt: d.documentDate,
        title: d.title,
        sourceLabel: d.kind.name,
        detail: d.tags.join(', '),
      ),
    );
  }

  if (events.isNotEmpty) {
    events.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return events;
  }

  final vitals = await ref.watch(healthRepositoryProvider).getVitals();
  return vitals
      .map(
        (v) => TimelineEvent(
          id: v.id,
          ownerUserId: userId,
          kind: TimelineKind.observation,
          occurredAt: v.recordedAt,
          title: '${v.label}: ${v.displayValue} ${v.unit}',
          sourceLabel: 'manual/mock',
          detail: 'Demo sample — not a device reading.',
        ),
      )
      .toList();
});
