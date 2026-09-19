import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/health_drift_schema.dart';

typedef JsonMap = Map<String, Object?>;

/// Local-first health DB: user scope, soft-delete tombstones, offline sync queue.
/// Field layout matches [HealthDriftSchema] for a future Drift executor.
class PrefsHealthLocalDatabase {
  PrefsHealthLocalDatabase(this._prefs, {Uuid? uuid})
      : _uuid = uuid ?? const Uuid();

  final SharedPreferences _prefs;
  final Uuid _uuid;

  static const _prefix = 'super_health.db.';

  String _tableKey(String table) => '$_prefix$table';
  String get _tombstoneKey => '${_prefix}tombstones';
  String get _syncKey => '${_prefix}sync_operations';

  Future<void> upsert({
    required String table,
    required String ownerUserId,
    required String id,
    required JsonMap row,
  }) async {
    final map = _loadTable(table);
    final stones = _loadTombstones();
    stones.remove('$ownerUserId:$table:$id');
    final now = DateTime.now().toUtc().toIso8601String();
    map[id] = {
      ...row,
      'id': id,
      'ownerUserId': ownerUserId,
      'updatedAt': now,
      'createdAt': row['createdAt'] ?? now,
      'deletedAt': null,
      'version': (row['version'] as int? ?? 0) + 1,
      'syncStatus': 'pendingUpload',
    };
    await _saveTable(table, map);
    await _saveTombstones(stones);
    await enqueueSync(
      SyncQueueItem(
        id: _uuid.v4(),
        ownerUserId: ownerUserId,
        entityType: table,
        entityId: id,
        opType: SyncOpType.upsert,
        enqueuedAt: DateTime.now().toUtc(),
        payloadJson: jsonEncode(map[id]),
      ),
    );
  }

  Future<void> delete({
    required String table,
    required String ownerUserId,
    required String id,
  }) async {
    final map = _loadTable(table);
    map.remove(id);
    final stones = _loadTombstones();
    stones.add('$ownerUserId:$table:$id');
    await _saveTable(table, map);
    await _saveTombstones(stones);
    await enqueueSync(
      SyncQueueItem(
        id: _uuid.v4(),
        ownerUserId: ownerUserId,
        entityType: table,
        entityId: id,
        opType: SyncOpType.delete,
        enqueuedAt: DateTime.now().toUtc(),
      ),
    );
  }

  List<JsonMap> list({
    required String table,
    required String ownerUserId,
  }) {
    final stones = _loadTombstones();
    return _loadTable(table)
        .values
        .where(
          (row) =>
              row['ownerUserId'] == ownerUserId &&
              !stones.contains('$ownerUserId:$table:${row['id']}'),
        )
        .toList();
  }

  JsonMap? getById({
    required String table,
    required String ownerUserId,
    required String id,
  }) {
    if (isTombstoned(table: table, ownerUserId: ownerUserId, id: id)) {
      return null;
    }
    final row = _loadTable(table)[id];
    if (row == null || row['ownerUserId'] != ownerUserId) return null;
    return row;
  }

  bool isTombstoned({
    required String table,
    required String ownerUserId,
    required String id,
  }) {
    return _loadTombstones().contains('$ownerUserId:$table:$id');
  }

  /// Remote apply must not resurrect tombstones.
  Future<void> applyRemote({
    required String table,
    required String ownerUserId,
    required String id,
    required JsonMap row,
  }) async {
    if (isTombstoned(table: table, ownerUserId: ownerUserId, id: id)) {
      return;
    }
    final map = _loadTable(table);
    map[id] = {...row, 'id': id, 'ownerUserId': ownerUserId};
    await _saveTable(table, map);
  }

  Future<void> enqueueSync(SyncQueueItem item) async {
    final queue = pendingSync();
    queue.add(item);
    await _prefs.setString(
      _syncKey,
      jsonEncode(queue.map((e) => e.toJson()).toList()),
    );
  }

  List<SyncQueueItem> pendingSync({int limit = 50}) {
    final raw = _prefs.getString(_syncKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => SyncQueueItem.fromJson(Map<String, Object?>.from(e as Map)))
        .take(limit)
        .toList();
  }

  Future<void> markSyncCompleted(String operationId) async {
    final remaining =
        pendingSync(limit: 1000).where((e) => e.id != operationId).toList();
    await _prefs.setString(
      _syncKey,
      jsonEncode(remaining.map((e) => e.toJson()).toList()),
    );
  }

  Map<String, JsonMap> _loadTable(String table) {
    final raw = _prefs.getString(_tableKey(table));
    if (raw == null || raw.isEmpty) return {};
    final list = jsonDecode(raw) as List<dynamic>;
    final map = <String, JsonMap>{};
    for (final item in list) {
      final row = Map<String, Object?>.from(item as Map);
      map[row['id']! as String] = row;
    }
    return map;
  }

  Future<void> _saveTable(String table, Map<String, JsonMap> map) async {
    await _prefs.setString(
      _tableKey(table),
      jsonEncode(map.values.toList()),
    );
  }

  Set<String> _loadTombstones() {
    return (_prefs.getStringList(_tombstoneKey) ?? const []).toSet();
  }

  Future<void> _saveTombstones(Set<String> stones) async {
    await _prefs.setStringList(_tombstoneKey, stones.toList());
  }
}
