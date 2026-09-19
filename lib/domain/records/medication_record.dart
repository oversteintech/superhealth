/// User- or clinician-entered instructions stored verbatim. App never recalculates dose.
class MedicationRecord {
  const MedicationRecord({
    required this.id,
    required this.ownerUserId,
    required this.name,
    required this.instructionAsEntered,
    this.reminderTimesLocal = const [],
    this.notes = '',
    this.active = true,
  });

  final String id;
  final String ownerUserId;
  final String name;
  final String instructionAsEntered;
  final List<String> reminderTimesLocal;
  final String notes;
  final bool active;

  Map<String, Object?> toJson() => {
        'id': id,
        'ownerUserId': ownerUserId,
        'name': name,
        'instructionAsEntered': instructionAsEntered,
        'reminderTimesLocal': reminderTimesLocal,
        'notes': notes,
        'active': active,
      };

  factory MedicationRecord.fromJson(Map<String, Object?> json) {
    return MedicationRecord(
      id: json['id']! as String,
      ownerUserId: json['ownerUserId']! as String,
      name: json['name']! as String,
      instructionAsEntered: json['instructionAsEntered']! as String,
      reminderTimesLocal: (json['reminderTimesLocal'] as List<dynamic>?)
              ?.map((e) => '$e')
              .toList() ??
          const [],
      notes: json['notes'] as String? ?? '',
      active: json['active'] as bool? ?? true,
    );
  }
}

enum AdherenceStatus { taken, skipped, snoozed }

class MedicationAdherenceEvent {
  const MedicationAdherenceEvent({
    required this.id,
    required this.ownerUserId,
    required this.medicationId,
    required this.scheduledFor,
    required this.status,
    required this.recordedAt,
    this.snoozeUntil,
  });

  final String id;
  final String ownerUserId;
  final String medicationId;
  final DateTime scheduledFor;
  final AdherenceStatus status;
  final DateTime recordedAt;
  final DateTime? snoozeUntil;

  Map<String, Object?> toJson() => {
        'id': id,
        'ownerUserId': ownerUserId,
        'medicationId': medicationId,
        'scheduledFor': scheduledFor.toUtc().toIso8601String(),
        'status': status.name,
        'recordedAt': recordedAt.toUtc().toIso8601String(),
        'snoozeUntil': snoozeUntil?.toUtc().toIso8601String(),
      };

  factory MedicationAdherenceEvent.fromJson(Map<String, Object?> json) {
    return MedicationAdherenceEvent(
      id: json['id']! as String,
      ownerUserId: json['ownerUserId']! as String,
      medicationId: json['medicationId']! as String,
      scheduledFor: DateTime.parse(json['scheduledFor']! as String).toUtc(),
      status: AdherenceStatus.values.byName(json['status']! as String),
      recordedAt: DateTime.parse(json['recordedAt']! as String).toUtc(),
      snoozeUntil: json['snoozeUntil'] == null
          ? null
          : DateTime.parse(json['snoozeUntil']! as String).toUtc(),
    );
  }
}
