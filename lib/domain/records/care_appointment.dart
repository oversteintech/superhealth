class CareAppointment {
  const CareAppointment({
    required this.id,
    required this.ownerUserId,
    required this.title,
    required this.startsAt,
    this.location = '',
    this.clinicianName = '',
    this.notes = '',
    this.questions = const [],
    this.reminderMinutesBefore,
    this.exportToCalendar = false,
  });

  final String id;
  final String ownerUserId;
  final String title;
  final DateTime startsAt;
  final String location;
  final String clinicianName;
  final String notes;
  final List<String> questions;
  final int? reminderMinutesBefore;
  final bool exportToCalendar;

  Map<String, Object?> toJson() => {
        'id': id,
        'ownerUserId': ownerUserId,
        'title': title,
        'startsAt': startsAt.toUtc().toIso8601String(),
        'location': location,
        'clinicianName': clinicianName,
        'notes': notes,
        'questions': questions,
        'reminderMinutesBefore': reminderMinutesBefore,
        'exportToCalendar': exportToCalendar,
      };

  factory CareAppointment.fromJson(Map<String, Object?> json) {
    return CareAppointment(
      id: json['id']! as String,
      ownerUserId: json['ownerUserId']! as String,
      title: json['title']! as String,
      startsAt: DateTime.parse(json['startsAt']! as String).toUtc(),
      location: json['location'] as String? ?? '',
      clinicianName: json['clinicianName'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      questions: (json['questions'] as List<dynamic>?)
              ?.map((e) => '$e')
              .toList() ??
          const [],
      reminderMinutesBefore: json['reminderMinutesBefore'] as int?,
      exportToCalendar: json['exportToCalendar'] as bool? ?? false,
    );
  }
}
