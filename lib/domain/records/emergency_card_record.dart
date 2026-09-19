class EmergencyCardRecord {
  const EmergencyCardRecord({
    required this.id,
    required this.ownerUserId,
    required this.updatedAt,
    this.enabled = false,
    this.lockScreenSharingConsent = false,
    this.displayName = '',
    this.bloodType = '',
    this.allergies = const [],
    this.importantNotes = const [],
    this.emergencyContactName = '',
    this.emergencyContactPhone = '',
    this.editHistory = const [],
  });

  final String id;
  final String ownerUserId;
  final bool enabled;
  final bool lockScreenSharingConsent;
  final String displayName;
  final String bloodType;
  final List<String> allergies;
  final List<String> importantNotes;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final DateTime updatedAt;
  final List<String> editHistory;

  Map<String, Object?> toJson() => {
        'id': id,
        'ownerUserId': ownerUserId,
        'enabled': enabled,
        'lockScreenSharingConsent': lockScreenSharingConsent,
        'displayName': displayName,
        'bloodType': bloodType,
        'allergies': allergies,
        'importantNotes': importantNotes,
        'emergencyContactName': emergencyContactName,
        'emergencyContactPhone': emergencyContactPhone,
        'updatedAt': updatedAt.toUtc().toIso8601String(),
        'editHistory': editHistory,
      };

  factory EmergencyCardRecord.fromJson(Map<String, Object?> json) {
    return EmergencyCardRecord(
      id: json['id']! as String,
      ownerUserId: json['ownerUserId']! as String,
      enabled: json['enabled'] as bool? ?? false,
      lockScreenSharingConsent:
          json['lockScreenSharingConsent'] as bool? ?? false,
      displayName: json['displayName'] as String? ?? '',
      bloodType: json['bloodType'] as String? ?? '',
      allergies: (json['allergies'] as List<dynamic>?)
              ?.map((e) => '$e')
              .toList() ??
          const [],
      importantNotes: (json['importantNotes'] as List<dynamic>?)
              ?.map((e) => '$e')
              .toList() ??
          const [],
      emergencyContactName: json['emergencyContactName'] as String? ?? '',
      emergencyContactPhone: json['emergencyContactPhone'] as String? ?? '',
      updatedAt: DateTime.parse(json['updatedAt']! as String).toUtc(),
      editHistory: (json['editHistory'] as List<dynamic>?)
              ?.map((e) => '$e')
              .toList() ??
          const [],
    );
  }

  EmergencyCardRecord copyWith({
    bool? enabled,
    bool? lockScreenSharingConsent,
    String? displayName,
    String? bloodType,
    List<String>? allergies,
    List<String>? importantNotes,
    String? emergencyContactName,
    String? emergencyContactPhone,
    DateTime? updatedAt,
    List<String>? editHistory,
  }) {
    return EmergencyCardRecord(
      id: id,
      ownerUserId: ownerUserId,
      enabled: enabled ?? this.enabled,
      lockScreenSharingConsent:
          lockScreenSharingConsent ?? this.lockScreenSharingConsent,
      displayName: displayName ?? this.displayName,
      bloodType: bloodType ?? this.bloodType,
      allergies: allergies ?? this.allergies,
      importantNotes: importantNotes ?? this.importantNotes,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      updatedAt: updatedAt ?? this.updatedAt,
      editHistory: editHistory ?? this.editHistory,
    );
  }
}
