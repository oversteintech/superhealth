class WeightEntry {
  const WeightEntry({
    required this.id,
    required this.kg,
    required this.recordedAt,
    this.note = '',
  });

  final String id;
  final double kg;
  final DateTime recordedAt;
  final String note;
}