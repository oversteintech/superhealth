/// Append-only audit trail. Never stores clinical values — ids and actions only.
class AuditEvent {
  const AuditEvent({
    required this.id,
    required this.ownerUserId,
    required this.action,
    required this.occurredAt,
    this.entityType = '',
    this.entityId = '',
    this.metadata = const {},
  });

  final String id;
  final String ownerUserId;
  final String action;
  final DateTime occurredAt;
  final String entityType;
  final String entityId;
  final Map<String, String> metadata;

  Map<String, Object?> toJson() => {
        'id': id,
        'ownerUserId': ownerUserId,
        'action': action,
        'occurredAt': occurredAt.toUtc().toIso8601String(),
        'entityType': entityType,
        'entityId': entityId,
        'metadata': metadata,
      };

  factory AuditEvent.fromJson(Map<String, Object?> json) {
    final meta = json['metadata'];
    return AuditEvent(
      id: json['id']! as String,
      ownerUserId: json['ownerUserId']! as String,
      action: json['action']! as String,
      occurredAt: DateTime.parse(json['occurredAt']! as String).toUtc(),
      entityType: json['entityType'] as String? ?? '',
      entityId: json['entityId'] as String? ?? '',
      metadata: meta is Map
          ? meta.map((k, v) => MapEntry('$k', '$v'))
          : const {},
    );
  }

  /// Reject payloads that look like clinical leakage into audit metadata.
  static bool metadataLooksSensitive(Map<String, String> metadata) {
    final joined = metadata.values.join(' ').toLowerCase();
    return RegExp(
      r'\b(allergy|penicillin|glucose|blood|diagnosis|dose|mg/dl|mmhg)\b',
    ).hasMatch(joined);
  }
}
