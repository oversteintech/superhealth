class HealthProfile {
  const HealthProfile({
    required this.id,
    required this.displayName,
    required this.ageYears,
    required this.bloodType,
    required this.heightCm,
    required this.weightKg,
    this.conditions = const [],
  });

  final String id;
  final String displayName;
  final int ageYears;
  final String bloodType;
  final double heightCm;
  final double weightKg;
  final List<String> conditions;

  double get bmi => weightKg / ((heightCm / 100) * (heightCm / 100));
}