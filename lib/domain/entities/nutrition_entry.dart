class NutritionEntry {
  const NutritionEntry({
    required this.id,
    required this.meal,
    required this.description,
    required this.calories,
    required this.recordedAt,
    this.proteinG = 0,
    this.carbsG = 0,
    this.fatG = 0,
  });

  final String id;
  final String meal;
  final String description;
  final int calories;
  final DateTime recordedAt;
  final double proteinG;
  final double carbsG;
  final double fatG;
}