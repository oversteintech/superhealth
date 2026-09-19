import 'package:uuid/uuid.dart';

import '../../domain/import/wearable_import_port.dart';
import '../../domain/records/observation.dart';

/// Mock platform feed — always labeled Demo. Not a validated medical device.
class DemoWearableImportAdapter implements WearableImportPort {
  DemoWearableImportAdapter({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;
  var _permitted = false;

  @override
  String get platformId => 'demo_health_platform';

  @override
  bool get isDemo => true;

  @override
  Future<bool> hasPermission() async => _permitted;

  @override
  Future<bool> requestPermission() async {
    _permitted = true;
    return true;
  }

  @override
  Future<List<Observation>> importSince({
    required String ownerUserId,
    required DateTime sinceUtc,
  }) async {
    if (!_permitted) return const [];
    final now = DateTime.now().toUtc();
    // Intentionally emit a duplicate pair to exercise dedupe.
    final sample = Observation(
      id: _uuid.v4(),
      ownerUserId: ownerUserId,
      type: ObservationType.heartRate,
      value: 68,
      unit: 'bpm',
      measuredAt: now.subtract(const Duration(hours: 1)),
      sourceKind: DataSourceKind.wearable,
      sourceId: 'demo_watch',
      timeZoneId: 'UTC',
      reliabilityNote: 'Demo sample — not a connected device',
    );
    final dup = Observation(
      id: _uuid.v4(),
      ownerUserId: ownerUserId,
      type: sample.type,
      value: sample.value,
      unit: sample.unit,
      measuredAt: sample.measuredAt,
      sourceKind: sample.sourceKind,
      sourceId: sample.sourceId,
      timeZoneId: sample.timeZoneId,
      reliabilityNote: sample.reliabilityNote,
    );
    final late = Observation(
      id: _uuid.v4(),
      ownerUserId: ownerUserId,
      type: ObservationType.steps,
      value: 4200,
      unit: 'steps',
      measuredAt: now,
      sourceKind: DataSourceKind.wearable,
      sourceId: 'demo_watch',
      reliabilityNote: 'Demo sample — not a connected device',
    );
    if (sample.measuredAtUtc.isBefore(sinceUtc) &&
        late.measuredAtUtc.isBefore(sinceUtc)) {
      return const [];
    }
    return WearableDeduper.dedupe([sample, dup, late]);
  }
}
