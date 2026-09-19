/// Drift table contracts for Super Health (Garage-parity sync columns).
///
/// Runtime executor today: [PrefsHealthLocalDatabase] (JSON + tombstones).
/// Swap to `@DriftDatabase` codegen when native CI/assets allow — same field names.
abstract final class HealthDriftSchema {
  static const version = 1;

  static const tables = <String>[
    'health_profiles',
    'observations',
    'symptom_entries',
    'habit_goals',
    'habit_logs',
    'medication_records',
    'medication_adherence_events',
    'care_appointments',
    'health_documents',
    'emergency_cards',
    'consent_grants',
    'share_grants',
    'care_circle_members',
    'audit_events',
    'sync_operations',
    'tombstones',
  ];

  /// Shared sync metadata columns on every user-owned row.
  static const syncColumns = <String>[
    'user_id',
    'created_at',
    'updated_at',
    'deleted_at',
    'version',
    'sync_status',
    'device_id',
    'last_synced_at',
  ];
}

enum SyncOpType { upsert, delete }

class SyncQueueItem {
  const SyncQueueItem({
    required this.id,
    required this.ownerUserId,
    required this.entityType,
    required this.entityId,
    required this.opType,
    required this.enqueuedAt,
    this.payloadJson = '',
  });

  final String id;
  final String ownerUserId;
  final String entityType;
  final String entityId;
  final SyncOpType opType;
  final DateTime enqueuedAt;
  final String payloadJson;

  Map<String, Object?> toJson() => {
        'id': id,
        'ownerUserId': ownerUserId,
        'entityType': entityType,
        'entityId': entityId,
        'opType': opType.name,
        'enqueuedAt': enqueuedAt.toUtc().toIso8601String(),
        'payloadJson': payloadJson,
      };

  factory SyncQueueItem.fromJson(Map<String, Object?> json) {
    return SyncQueueItem(
      id: json['id']! as String,
      ownerUserId: json['ownerUserId']! as String,
      entityType: json['entityType']! as String,
      entityId: json['entityId']! as String,
      opType: SyncOpType.values.byName(json['opType']! as String),
      enqueuedAt: DateTime.parse(json['enqueuedAt']! as String).toUtc(),
      payloadJson: json['payloadJson'] as String? ?? '',
    );
  }
}
