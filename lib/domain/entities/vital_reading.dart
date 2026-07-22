enum VitalKind { heartRate, bloodPressure, steps, sleepHours, glucose, spo2 }

class VitalReading {
  const VitalReading({
    required this.id,
    required this.kind,
    required this.value,
    required this.unit,
    required this.recordedAt,
    this.secondaryValue,
  });

  final String id;
  final VitalKind kind;
  final double value;
  final String unit;
  final DateTime recordedAt;
  final double? secondaryValue;

  String get label => switch (kind) {
        VitalKind.heartRate => 'Heart rate',
        VitalKind.bloodPressure => 'Blood pressure',
        VitalKind.steps => 'Steps',
        VitalKind.sleepHours => 'Sleep',
        VitalKind.glucose => 'Glucose',
        VitalKind.spo2 => 'SpO2',
      };

  String get displayValue {
    if (kind == VitalKind.bloodPressure && secondaryValue != null) {
      return '${value.toInt()}/${secondaryValue!.toInt()}';
    }
    if (value == value.roundToDouble()) {
      return '${value.toInt()}';
    }
    return value.toStringAsFixed(1);
  }
}