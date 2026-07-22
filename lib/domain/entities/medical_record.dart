class MedicalRecord {
  const MedicalRecord({
    required this.id,
    required this.title,
    required this.category,
    required this.provider,
    required this.recordedAt,
    this.summary = '',
    this.attachmentLabel,
  });

  final String id;
  final String title;
  final String category;
  final String provider;
  final DateTime recordedAt;
  final String summary;
  final String? attachmentLabel;
}