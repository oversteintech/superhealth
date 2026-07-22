class EmergencyCard {
  const EmergencyCard({
    required this.fullName,
    required this.bloodType,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    this.allergies = const [],
    this.conditions = const [],
    this.medications = const [],
    this.notes = '',
    this.organDonor = false,
  });

  final String fullName;
  final String bloodType;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final List<String> allergies;
  final List<String> conditions;
  final List<String> medications;
  final String notes;
  final bool organDonor;
}