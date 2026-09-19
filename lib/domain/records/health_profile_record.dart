/// Prefer birth year or age band; never require national ID.
class HealthProfile {
  const HealthProfile({
    required this.id,
    required this.ownerUserId,
    required this.displayName,
    this.birthYear,
    this.ageBand,
    this.heightCm,
    this.preferredUnitSystem = UnitSystem.metric,
    this.timeZoneId = 'UTC',
    this.countryCode = '',
    this.languageCode = 'en',
  });

  final String id;
  final String ownerUserId;
  final String displayName;
  final int? birthYear;
  final String? ageBand;
  final double? heightCm;
  final UnitSystem preferredUnitSystem;
  final String timeZoneId;
  final String countryCode;
  final String languageCode;

  int? get approximateAgeYears {
    if (birthYear == null) return null;
    return DateTime.now().year - birthYear!;
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'ownerUserId': ownerUserId,
        'displayName': displayName,
        'birthYear': birthYear,
        'ageBand': ageBand,
        'heightCm': heightCm,
        'preferredUnitSystem': preferredUnitSystem.name,
        'timeZoneId': timeZoneId,
        'countryCode': countryCode,
        'languageCode': languageCode,
      };

  factory HealthProfile.fromJson(Map<String, Object?> json) {
    return HealthProfile(
      id: json['id']! as String,
      ownerUserId: json['ownerUserId']! as String,
      displayName: json['displayName']! as String,
      birthYear: json['birthYear'] as int?,
      ageBand: json['ageBand'] as String?,
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      preferredUnitSystem: UnitSystem.values.byName(
        json['preferredUnitSystem'] as String? ?? 'metric',
      ),
      timeZoneId: json['timeZoneId'] as String? ?? 'UTC',
      countryCode: json['countryCode'] as String? ?? '',
      languageCode: json['languageCode'] as String? ?? 'en',
    );
  }

  HealthProfile copyWith({
    String? displayName,
    int? birthYear,
    String? ageBand,
    double? heightCm,
    UnitSystem? preferredUnitSystem,
    String? timeZoneId,
    String? countryCode,
    String? languageCode,
  }) {
    return HealthProfile(
      id: id,
      ownerUserId: ownerUserId,
      displayName: displayName ?? this.displayName,
      birthYear: birthYear ?? this.birthYear,
      ageBand: ageBand ?? this.ageBand,
      heightCm: heightCm ?? this.heightCm,
      preferredUnitSystem: preferredUnitSystem ?? this.preferredUnitSystem,
      timeZoneId: timeZoneId ?? this.timeZoneId,
      countryCode: countryCode ?? this.countryCode,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}

enum UnitSystem { metric, imperial }
