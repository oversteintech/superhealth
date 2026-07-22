class HealthInsight {
  const HealthInsight({
    required this.id,
    required this.title,
    required this.body,
    required this.severity,
    this.isPremium = false,
  });

  final String id;
  final String title;
  final String body;
  final String severity;
  final bool isPremium;
}