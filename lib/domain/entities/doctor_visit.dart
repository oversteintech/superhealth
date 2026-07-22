class DoctorVisit {
  const DoctorVisit({
    required this.id,
    required this.reason,
    required this.clinician,
    required this.specialty,
    required this.clinic,
    required this.startsAt,
    this.notes = '',
    this.followUpRequired = false,
  });

  final String id;
  final String reason;
  final String clinician;
  final String specialty;
  final String clinic;
  final DateTime startsAt;
  final String notes;
  final bool followUpRequired;
}