class Medication {
  const Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.schedule,
    required this.nextDoseAt,
    this.takenToday = false,
  });

  final String id;
  final String name;
  final String dosage;
  final String schedule;
  final DateTime nextDoseAt;
  final bool takenToday;
}