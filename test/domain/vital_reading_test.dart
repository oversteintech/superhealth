import 'package:flutter_test/flutter_test.dart';
import 'package:super_health/domain/entities/vital_reading.dart';

void main() {
  test('blood pressure display combines secondary value', () {
    final reading = VitalReading(
      id: '1',
      kind: VitalKind.bloodPressure,
      value: 118,
      secondaryValue: 76,
      unit: 'mmHg',
      recordedAt: DateTime(2026, 1, 1),
    );
    expect(reading.displayValue, '118/76');
    expect(reading.label, 'Blood pressure');
  });
}