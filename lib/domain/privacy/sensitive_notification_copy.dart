class NotificationCopy {
  const NotificationCopy({
    required this.title,
    required this.body,
    required this.hideSensitiveBody,
  });

  final String title;
  final String body;
  final bool hideSensitiveBody;

  String get lockScreenTitle => hideSensitiveBody ? 'Health reminder' : title;

  String get lockScreenBody =>
      hideSensitiveBody ? 'Open Super Health to view this reminder.' : body;
}

abstract final class SensitiveNotificationCopy {
  static NotificationCopy medicationReminder({
    required String medicationName,
    required String instruction,
  }) {
    return NotificationCopy(
      title: 'Medication reminder',
      body: '$medicationName — $instruction',
      hideSensitiveBody: true,
    );
  }
}
