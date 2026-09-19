import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/records/observation.dart';

/// Local-first observation store with per-user isolation and tombstones.
/// Drift replaces this in P0; this slice is the safe contract.
class UserScopedObservationStore {
  UserScopedObservationStore(this._prefs);

  final SharedPreferences _prefs;

  static const _recordsKey = 'super_health.obs.records';
  static const _tombstonesKey = 'super_health.obs.tombstones';

  Future<void> upsert(Observation observation) async {
    final records = _loadRecords();
    final stones = _loadTombstones();
    stones.remove('${observation.ownerUserId}:${observation.id}');
    records[observation.id] = observation;
    await _save(records, stones);
  }

  Future<void> delete({
    required String ownerUserId,
    required String id,
  }) async {
    final records = _loadRecords();
    records.remove(id);
    final stones = _loadTombstones();
    stones.add('$ownerUserId:$id');
    await _save(records, stones);
  }

  List<Observation> listForUser(String ownerUserId) {
    final stones = _loadTombstones();
    return _loadRecords()
        .values
        .where(
          (o) =>
              o.ownerUserId == ownerUserId &&
              !stones.contains('$ownerUserId:${o.id}'),
        )
        .toList()
      ..sort((a, b) => b.measuredAtUtc.compareTo(a.measuredAtUtc));
  }

  bool isTombstoned({required String ownerUserId, required String id}) {
    return _loadTombstones().contains('$ownerUserId:$id');
  }

  /// Remote pull must not resurrect tombstoned ids.
  Future<void> applyRemote(Observation remote) async {
    if (isTombstoned(ownerUserId: remote.ownerUserId, id: remote.id)) {
      return;
    }
    await upsert(remote);
  }

  Map<String, Observation> _loadRecords() {
    final raw = _prefs.getString(_recordsKey);
    if (raw == null || raw.isEmpty) return {};
    final list = jsonDecode(raw) as List<dynamic>;
    final map = <String, Observation>{};
    for (final item in list) {
      final obs = Observation.fromJson(Map<String, Object?>.from(item as Map));
      map[obs.id] = obs;
    }
    return map;
  }

  Set<String> _loadTombstones() {
    final raw = _prefs.getStringList(_tombstonesKey) ?? const [];
    return raw.toSet();
  }

  Future<void> _save(
    Map<String, Observation> records,
    Set<String> tombstones,
  ) async {
    final encoded = jsonEncode(records.values.map((e) => e.toJson()).toList());
    await _prefs.setString(_recordsKey, encoded);
    await _prefs.setStringList(_tombstonesKey, tombstones.toList());
  }
}
