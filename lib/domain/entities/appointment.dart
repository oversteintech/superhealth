class Appointment {
  const Appointment({
    required this.id,
    required this.title,
    required this.clinician,
    required this.location,
    required this.startsAt,
    this.notes = '',
  });

  final String id;
  final String title;
  final String clinician;
  final String location;
  final DateTime startsAt;
  final String notes;
}