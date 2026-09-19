import '../records/observation.dart';
import '../records/unit_conversion.dart';

class TrendPoint {
  const TrendPoint({
    required this.measuredAtUtc,
    required this.value,
    required this.unit,
    required this.sourceLabel,
    required this.observationId,
  });

  final DateTime measuredAtUtc;
  final double value;
  final String unit;
  final String sourceLabel;
  final String observationId;
}

class TrendSeries {
  const TrendSeries({
    required this.type,
    required this.displayUnit,
    required this.points,
    required this.gapStarts,
  });

  final ObservationType type;
  final String displayUnit;
  final List<TrendPoint> points;
  /// Indices in [points] after which a gap exists (do not draw a connecting line).
  final List<int> gapStarts;

  bool hasGapAfter(int index) => gapStarts.contains(index);
}

/// Builds measurement trends. Never invents values for missing intervals.
abstract final class TrendSeriesBuilder {
  /// Default: gaps longer than this do not get a continuous line.
  static const defaultGap = Duration(hours: 36);

  static TrendSeries build({
    required List<Observation> observations,
    required ObservationType type,
    required String displayUnit,
    Duration maxGap = defaultGap,
  }) {
    final filtered = observations.where((o) => o.type == type).toList()
      ..sort((a, b) => a.measuredAtUtc.compareTo(b.measuredAtUtc));

    final points = <TrendPoint>[];
    for (final o in filtered) {
      final value = _convert(o.value, o.unit, displayUnit);
      points.add(
        TrendPoint(
          measuredAtUtc: o.measuredAtUtc,
          value: value,
          unit: displayUnit,
          sourceLabel: '${o.sourceKind.name}/${o.sourceId}',
          observationId: o.id,
        ),
      );
    }

    final gaps = <int>[];
    for (var i = 0; i < points.length - 1; i++) {
      final delta =
          points[i + 1].measuredAtUtc.difference(points[i].measuredAtUtc);
      if (delta > maxGap) {
        gaps.add(i);
      }
    }

    return TrendSeries(
      type: type,
      displayUnit: displayUnit,
      points: points,
      gapStarts: gaps,
    );
  }

  static double _convert(double value, String from, String to) {
    try {
      return UnitConversion.convert(value: value, fromUnit: from, toUnit: to);
    } on ArgumentError {
      if (from.toLowerCase() == to.toLowerCase()) return value;
      rethrow;
    }
  }
}
