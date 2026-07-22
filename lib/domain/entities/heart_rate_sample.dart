class HeartRateSample {
  const HeartRateSample({
    required this.id,
    required this.bpm,
    required this.recordedAt,
    this.context = 'resting',
  });

  final String id;
  final int bpm;
  final DateTime recordedAt;
  final String context;
}