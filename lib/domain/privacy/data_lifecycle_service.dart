import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../data/local/health_records_repository.dart';
import '../../data/local/prefs_health_local_database.dart';
import '../records/audit_event.dart';

/// Full export + wipe for GDPR/KVKK-style user rights (local skeleton).
class DataLifecycleService {
  DataLifecycleService({
    required SharedPreferences prefs,
    required HealthRecordsRepository records,
    Uuid? uuid,
  })  : _prefs = prefs,
        _records = records,
        _uuid = uuid ?? const Uuid();

  final SharedPreferences _prefs;
  final HealthRecordsRepository _records;
  final Uuid _uuid;

  /// JSON export of user-owned tables (no secrets from secure storage).
  String exportJson(String ownerUserId) {
    final db = _records.database;
    final tables = <String, Object?>{};
    for (final table in [
      HealthRecordsRepository.profiles,
      HealthRecordsRepository.observations,
      HealthRecordsRepository.symptoms,
      HealthRecordsRepository.habits,
      HealthRecordsRepository.habitLogs,
      HealthRecordsRepository.medications,
      HealthRecordsRepository.adherence,
      HealthRecordsRepository.appointments,
      HealthRecordsRepository.documents,
      HealthRecordsRepository.emergency,
      HealthRecordsRepository.shares,
      HealthRecordsRepository.careCircle,
      HealthRecordsRepository.audit,
    ]) {
      tables[table] = db.list(table: table, ownerUserId: ownerUserId);
    }
    return const JsonEncoder.withIndent('  ').convert({
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'ownerUserId': ownerUserId,
      'disclaimer':
          'Personal health diary export — not a medical record certification.',
      'tables': tables,
    });
  }

  /// Deletes all local health rows for [ownerUserId] and appends an audit wipe event
  /// stored under a system tombstone note in prefs.
  Future<void> deleteAllLocalData(String ownerUserId) async {
    final db = _records.database;
    for (final table in [
      HealthRecordsRepository.profiles,
      HealthRecordsRepository.observations,
      HealthRecordsRepository.symptoms,
      HealthRecordsRepository.habits,
      HealthRecordsRepository.habitLogs,
      HealthRecordsRepository.medications,
      HealthRecordsRepository.adherence,
      HealthRecordsRepository.appointments,
      HealthRecordsRepository.documents,
      HealthRecordsRepository.emergency,
      HealthRecordsRepository.shares,
      HealthRecordsRepository.careCircle,
      HealthRecordsRepository.audit,
    ]) {
      final ids = db
          .list(table: table, ownerUserId: ownerUserId)
          .map((r) => r['id']! as String)
          .toList();
      for (final id in ids) {
        await db.delete(table: table, ownerUserId: ownerUserId, id: id);
      }
    }

    // Wipe consent + privacy prefs that are user-scoped keys.
    await _prefs.remove('super_health.consent.grants');
    await _prefs.remove('super_health.consent.purposes');
    await _prefs.remove('super_health.consent.local_store');
    await _prefs.remove('super_health.consent.reminders');

    await _prefs.setString(
      'super_health.lifecycle.last_wipe',
      DateTime.now().toUtc().toIso8601String(),
    );
    // Cannot append to wiped audit table for same user — keep a meta event id.
    await _prefs.setString(
      'super_health.lifecycle.last_wipe_event',
      jsonEncode(
        AuditEvent(
          id: _uuid.v4(),
          ownerUserId: ownerUserId,
          action: 'lifecycle.delete_all',
          occurredAt: DateTime.now().toUtc(),
          metadata: const {'scope': 'local'},
        ).toJson(),
      ),
    );
  }

  PrefsHealthLocalDatabase get database => _records.database;
}
