enum TimelineKind {
  symptomNote,
  generalNote,
  appointment,
  observation,
  document,
  completedRoutine,
}

class TimelineEvent {
  const TimelineEvent({
    required this.id,
    required this.ownerUserId,
    required this.kind,
    required this.occurredAt,
    required this.title,
    required this.sourceLabel,
    this.detail = '',
  });

  final String id;
  final String ownerUserId;
  final TimelineKind kind;
  final DateTime occurredAt;
  final String title;
  final String sourceLabel;
  final String detail;
}
