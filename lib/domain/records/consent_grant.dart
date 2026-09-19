enum ConsentPurpose {
  localHealthStore,
  reminders,
  lockScreenEmergency,
  cloudBlob,
  aiExplain,
}

class ConsentGrant {
  const ConsentGrant({
    required this.id,
    required this.ownerUserId,
    required this.purpose,
    required this.granted,
    required this.version,
    required this.recordedAt,
    this.scopeNotes = '',
  });

  final String id;
  final String ownerUserId;
  final ConsentPurpose purpose;
  final bool granted;
  final String version;
  final DateTime recordedAt;
  final String scopeNotes;
}
