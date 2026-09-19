/// Free-text symptom diary. Never used to infer a clinical diagnosis.
class SymptomEntry {
  const SymptomEntry({
    required this.id,
    required this.ownerUserId,
    required this.label,
    required this.occurredAt,
    this.severity = 0,
    this.durationMinutes,
    this.triggerNote = '',
    this.freeNote = '',
  });

  final String id;
  final String ownerUserId;
  final String label;
  final DateTime occurredAt;
  /// 0–10 user scale; not a clinical score.
  final int severity;
  final int? durationMinutes;
  final String triggerNote;
  final String freeNote;

  Map<String, Object?> toJson() => {
        'id': id,
        'ownerUserId': ownerUserId,
        'label': label,
        'occurredAt': occurredAt.toUtc().toIso8601String(),
        'severity': severity,
        'durationMinutes': durationMinutes,
        'triggerNote': triggerNote,
        'freeNote': freeNote,
      };

  factory SymptomEntry.fromJson(Map<String, Object?> json) {
    return SymptomEntry(
      id: json['id']! as String,
      ownerUserId: json['ownerUserId']! as String,
      label: json['label']! as String,
      occurredAt: DateTime.parse(json['occurredAt']! as String).toUtc(),
      severity: json['severity'] as int? ?? 0,
      durationMinutes: json['durationMinutes'] as int?,
      triggerNote: json['triggerNote'] as String? ?? '',
      freeNote: json['freeNote'] as String? ?? '',
    );
  }
}
