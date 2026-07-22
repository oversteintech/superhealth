class LabResult {
  const LabResult({
    required this.id,
    required this.testName,
    required this.value,
    required this.unit,
    required this.referenceRange,
    required this.collectedAt,
    this.status = 'normal',
  });

  final String id;
  final String testName;
  final String value;
  final String unit;
  final String referenceRange;
  final DateTime collectedAt;
  final String status;

  bool get isFlagged => status != 'normal';
}