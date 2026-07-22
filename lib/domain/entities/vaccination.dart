class Vaccination {
  const Vaccination({
    required this.id,
    required this.name,
    required this.doseLabel,
    required this.administeredAt,
    required this.provider,
    this.nextDueAt,
    this.lotNumber,
  });

  final String id;
  final String name;
  final String doseLabel;
  final DateTime administeredAt;
  final String provider;
  final DateTime? nextDueAt;
  final String? lotNumber;
}