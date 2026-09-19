import 'package:after_core/after_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_health/app/platform/crash_reporting.dart';
import 'package:super_health/app/security/secure_storage_service.dart';
import 'package:super_health/domain/entities/health_profile.dart';
import 'package:super_health/domain/entities/lab_result.dart';

class _MemorySecureStorage implements AfterSecureStorage {
  final Map<String, String> _values = {};

  @override
  Future<void> write(String key, String value) async => _values[key] = value;

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  Future<void> deleteAll() async => _values.clear();

  @override
  Future<bool> containsKey(String key) async => _values.containsKey(key);
}

void main() {
  test('SecureStorageService health secret round-trip', () async {
    final storage = SecureStorageService(_MemorySecureStorage());
    await storage.writeHealthSecret('pin', '1234');
    expect(await storage.readHealthSecret('pin'), '1234');
    await storage.delete('superhealth.secret.pin');
    expect(await storage.readHealthSecret('pin'), isNull);
  });

  test('entity helpers for BMI and flagged labs', () {
    const profile = HealthProfile(
      id: 'p',
      displayName: 'A',
      ageYears: 30,
      bloodType: 'A+',
      heightCm: 180,
      weightKg: 72,
    );
    expect(profile.bmi, closeTo(22.2, 0.1));
    expect(
      LabResult(
        id: 'l',
        testName: 'LDL',
        value: '160',
        unit: 'mg/dL',
        referenceRange: '<100',
        collectedAt: DateTime.utc(2026),
        status: 'high',
      ).isFlagged,
      isTrue,
    );
    expect(
      LabResult(
        id: 'l2',
        testName: 'HDL',
        value: '55',
        unit: 'mg/dL',
        referenceRange: '>40',
        collectedAt: DateTime.utc(2026),
      ).isFlagged,
      isFalse,
    );
  });

  test('CrashReporting install is idempotent', () {
    CrashReporting.install(const ConsoleAfterLogger());
    CrashReporting.install(const ConsoleAfterLogger());
    CrashReporting.recordError(StateError('x'), null, fatal: true);
  });
}
