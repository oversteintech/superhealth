enum CareMemberRole { caregiver, dependentChild, dependentAdult }

enum CareFieldVisibility {
  observations,
  medications,
  appointments,
  habits,
  emergencyCard,
}

class CareCircleMember {
  const CareCircleMember({
    required this.id,
    required this.ownerUserId,
    required this.memberLabel,
    required this.role,
    required this.visibleFields,
    required this.invitedAt,
    this.acceptedAt,
    this.revokedAt,
    this.consentVersion = 'p1-1',
  });

  final String id;
  final String ownerUserId;
  final String memberLabel;
  final CareMemberRole role;
  /// Explicit allow-list. Empty = no clinical fields (default).
  final List<CareFieldVisibility> visibleFields;
  final DateTime invitedAt;
  final DateTime? acceptedAt;
  final DateTime? revokedAt;
  final String consentVersion;

  bool get isActive => revokedAt == null;

  /// Default invite never grants full vault access.
  bool get hasFullAccess =>
      CareFieldVisibility.values.every(visibleFields.contains);

  Map<String, Object?> toJson() => {
        'id': id,
        'ownerUserId': ownerUserId,
        'memberLabel': memberLabel,
        'role': role.name,
        'visibleFields': visibleFields.map((e) => e.name).toList(),
        'invitedAt': invitedAt.toUtc().toIso8601String(),
        'acceptedAt': acceptedAt?.toUtc().toIso8601String(),
        'revokedAt': revokedAt?.toUtc().toIso8601String(),
        'consentVersion': consentVersion,
      };

  factory CareCircleMember.fromJson(Map<String, Object?> json) {
    return CareCircleMember(
      id: json['id']! as String,
      ownerUserId: json['ownerUserId']! as String,
      memberLabel: json['memberLabel']! as String,
      role: CareMemberRole.values.byName(json['role']! as String),
      visibleFields: (json['visibleFields'] as List<dynamic>?)
              ?.map((e) => CareFieldVisibility.values.byName('$e'))
              .toList() ??
          const [],
      invitedAt: DateTime.parse(json['invitedAt']! as String).toUtc(),
      acceptedAt: json['acceptedAt'] == null
          ? null
          : DateTime.parse(json['acceptedAt']! as String).toUtc(),
      revokedAt: json['revokedAt'] == null
          ? null
          : DateTime.parse(json['revokedAt']! as String).toUtc(),
      consentVersion: json['consentVersion'] as String? ?? 'p1-1',
    );
  }

  CareCircleMember copyWith({
    List<CareFieldVisibility>? visibleFields,
    DateTime? acceptedAt,
    DateTime? revokedAt,
  }) {
    return CareCircleMember(
      id: id,
      ownerUserId: ownerUserId,
      memberLabel: memberLabel,
      role: role,
      visibleFields: visibleFields ?? this.visibleFields,
      invitedAt: invitedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      revokedAt: revokedAt ?? this.revokedAt,
      consentVersion: consentVersion,
    );
  }
}
