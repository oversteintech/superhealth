/// User-entered or imported measurement. Not a clinical threshold.
enum ObservationType {
  bloodPressureSystolic,
  bloodPressureDiastolic,
  heartRate,
  weight,
  glucose,
  temperature,
  sleepDuration,
  steps,
  other,
}

enum DataSourceKind { manual, wearable, import, clinicianEntered }

class Observation {
  const Observation({
    required this.id,
    required this.ownerUserId,
    required this.type,
    required this.value,
    required this.unit,
    required this.measuredAt,
    required this.sourceKind,
    required this.sourceId,
    this.note = '',
    this.reliabilityNote = '',
    this.timeZoneId = 'UTC',
  });

  final String id;
  final String ownerUserId;
  final ObservationType type;
  final double value;
  final String unit;
  final DateTime measuredAt;
  final DataSourceKind sourceKind;
  final String sourceId;
  final String note;
  final String reliabilityNote;
  final String timeZoneId;

  DateTime get measuredAtUtc => measuredAt.toUtc();

  Map<String, Object?> toJson() => {
        'id': id,
        'ownerUserId': ownerUserId,
        'type': type.name,
        'value': value,
        'unit': unit,
        'measuredAt': measuredAtUtc.toIso8601String(),
        'sourceKind': sourceKind.name,
        'sourceId': sourceId,
        'note': note,
        'reliabilityNote': reliabilityNote,
        'timeZoneId': timeZoneId,
      };

  factory Observation.fromJson(Map<String, Object?> json) {
    return Observation(
      id: json['id']! as String,
      ownerUserId: json['ownerUserId']! as String,
      type: ObservationType.values.byName(json['type']! as String),
      value: (json['value']! as num).toDouble(),
      unit: json['unit']! as String,
      measuredAt: DateTime.parse(json['measuredAt']! as String).toUtc(),
      sourceKind: DataSourceKind.values.byName(json['sourceKind']! as String),
      sourceId: json['sourceId']! as String,
      note: json['note'] as String? ?? '',
      reliabilityNote: json['reliabilityNote'] as String? ?? '',
      timeZoneId: json['timeZoneId'] as String? ?? 'UTC',
    );
  }
}
