import '../records/observation.dart';

/// Permission-gated wearable / platform health import.
/// Real HealthKit / Health Connect adapters plug in later.
abstract class WearableImportPort {
  String get platformId;
  bool get isDemo;
  Future<bool> hasPermission();
  Future<bool> requestPermission();
  Future<List<Observation>> importSince({
    required String ownerUserId,
    required DateTime sinceUtc,
  });
}

/// Fingerprint to detect duplicate wearable samples.
abstract final class WearableDeduper {
  static String fingerprint(Observation o) =>
      '${o.ownerUserId}|${o.type.name}|${o.measuredAtUtc.toIso8601String()}|'
      '${o.value}|${o.unit}|${o.sourceId}';

  static List<Observation> dedupe(List<Observation> incoming) {
    final seen = <String>{};
    final out = <Observation>[];
    for (final o in incoming) {
      final key = fingerprint(o);
      if (seen.add(key)) out.add(o);
    }
    return out;
  }
}
