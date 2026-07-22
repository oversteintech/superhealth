class SleepSession {
  const SleepSession({
    required this.id,
    required this.bedtime,
    required this.wakeTime,
    required this.qualityScore,
    this.deepHours = 0,
    this.remHours = 0,
  });

  final String id;
  final DateTime bedtime;
  final DateTime wakeTime;
  final int qualityScore;
  final double deepHours;
  final double remHours;

  double get durationHours =>
      wakeTime.difference(bedtime).inMinutes / 60.0;
}