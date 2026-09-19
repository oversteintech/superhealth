class HabitGoal {
  const HabitGoal({
    required this.id,
    required this.ownerUserId,
    required this.title,
    required this.targetPerDay,
    required this.unitLabel,
    this.active = true,
  });

  final String id;
  final String ownerUserId;
  final String title;
  final double targetPerDay;
  final String unitLabel;
  final bool active;

  Map<String, Object?> toJson() => {
        'id': id,
        'ownerUserId': ownerUserId,
        'title': title,
        'targetPerDay': targetPerDay,
        'unitLabel': unitLabel,
        'active': active,
      };

  factory HabitGoal.fromJson(Map<String, Object?> json) {
    return HabitGoal(
      id: json['id']! as String,
      ownerUserId: json['ownerUserId']! as String,
      title: json['title']! as String,
      targetPerDay: (json['targetPerDay']! as num).toDouble(),
      unitLabel: json['unitLabel']! as String,
      active: json['active'] as bool? ?? true,
    );
  }
}

class HabitLog {
  const HabitLog({
    required this.id,
    required this.ownerUserId,
    required this.goalId,
    required this.dayKey,
    required this.value,
    required this.loggedAt,
  });

  final String id;
  final String ownerUserId;
  final String goalId;
  /// Local calendar day `yyyy-MM-dd` in the user's timezone.
  final String dayKey;
  final double value;
  final DateTime loggedAt;

  Map<String, Object?> toJson() => {
        'id': id,
        'ownerUserId': ownerUserId,
        'goalId': goalId,
        'dayKey': dayKey,
        'value': value,
        'loggedAt': loggedAt.toUtc().toIso8601String(),
      };

  factory HabitLog.fromJson(Map<String, Object?> json) {
    return HabitLog(
      id: json['id']! as String,
      ownerUserId: json['ownerUserId']! as String,
      goalId: json['goalId']! as String,
      dayKey: json['dayKey']! as String,
      value: (json['value']! as num).toDouble(),
      loggedAt: DateTime.parse(json['loggedAt']! as String).toUtc(),
    );
  }
}
