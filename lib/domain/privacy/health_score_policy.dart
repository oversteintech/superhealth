/// Super Health never invents a single wellness / diagnosis score.
abstract final class HealthScorePolicy {
  static Never refuseCompositeScore(String reason) {
    throw StateError(
      'Composite health scores are not produced. $reason',
    );
  }

  static double? scoreFromObservations(Iterable<Object> observations) {
    if (observations.isEmpty) {
      return null;
    }
    refuseCompositeScore('Observations must be shown as-is, not scored.');
  }
}
