import '../records/audit_event.dart';

/// Strips clinical / PII-looking values from analytics and AI telemetry maps.
abstract final class SensitivePayloadFilter {
  static final _sensitiveKey = RegExp(
    '(allerg|diagnos|dose|medication|glucose|blood|symptom|note|instruction|phone|email|name|value|payload|prompt|body)',
    caseSensitive: false,
  );

  static final _sensitiveValue = RegExp(
    r'\b(penicillin|mmhg|mg/dl|mmol|diagnos|prescribe|allergy|tansiyon|ilaç)\b',
    caseSensitive: false,
  );

  static Map<String, Object?> sanitize(
    Map<String, Object?> parameters, {
    Set<String> allowKeys = const {
      'plan',
      'screen_name',
      'screen_class',
      'blocked',
      'record_count',
      'refusal',
      'format',
      'categories',
      'demo',
      'count',
      'platform',
      'scope',
    },
  }) {
    final out = <String, Object?>{};
    for (final entry in parameters.entries) {
      if (allowKeys.contains(entry.key)) {
        out[entry.key] = entry.value;
        continue;
      }
      if (_sensitiveKey.hasMatch(entry.key)) continue;
      final value = entry.value;
      if (value is String && _sensitiveValue.hasMatch(value)) continue;
      if (value is String && value.length > 80) continue;
      out[entry.key] = value;
    }
    return out;
  }

  static bool containsSensitive(Map<String, Object?> parameters) {
    for (final entry in parameters.entries) {
      if (_sensitiveKey.hasMatch(entry.key)) return true;
      final value = entry.value;
      if (value is String && _sensitiveValue.hasMatch(value)) return true;
    }
    return false;
  }

  static bool auditSafe(AuditEvent event) =>
      !AuditEvent.metadataLooksSensitive(event.metadata);
}
