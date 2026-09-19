enum ShareFormat { csv, pdfText }

enum ShareCategory {
  observations,
  medications,
  appointments,
  documents,
  habits,
  symptoms,
}

class ShareGrant {
  const ShareGrant({
    required this.id,
    required this.ownerUserId,
    required this.recipientLabel,
    required this.categories,
    required this.createdAt,
    required this.expiresAt,
    required this.format,
    this.revokedAt,
    this.recordIds = const [],
    this.fromDate,
    this.toDate,
  });

  final String id;
  final String ownerUserId;
  final String recipientLabel;
  final List<ShareCategory> categories;
  final DateTime createdAt;
  final DateTime expiresAt;
  final ShareFormat format;
  final DateTime? revokedAt;
  final List<String> recordIds;
  final DateTime? fromDate;
  final DateTime? toDate;

  bool get isActive {
    if (revokedAt != null) return false;
    return DateTime.now().toUtc().isBefore(expiresAt.toUtc());
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'ownerUserId': ownerUserId,
        'recipientLabel': recipientLabel,
        'categories': categories.map((e) => e.name).toList(),
        'createdAt': createdAt.toUtc().toIso8601String(),
        'expiresAt': expiresAt.toUtc().toIso8601String(),
        'format': format.name,
        'revokedAt': revokedAt?.toUtc().toIso8601String(),
        'recordIds': recordIds,
        'fromDate': fromDate?.toUtc().toIso8601String(),
        'toDate': toDate?.toUtc().toIso8601String(),
      };

  factory ShareGrant.fromJson(Map<String, Object?> json) {
    return ShareGrant(
      id: json['id']! as String,
      ownerUserId: json['ownerUserId']! as String,
      recipientLabel: json['recipientLabel']! as String,
      categories: (json['categories']! as List<dynamic>)
          .map((e) => ShareCategory.values.byName('$e'))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']! as String).toUtc(),
      expiresAt: DateTime.parse(json['expiresAt']! as String).toUtc(),
      format: ShareFormat.values.byName(json['format']! as String),
      revokedAt: json['revokedAt'] == null
          ? null
          : DateTime.parse(json['revokedAt']! as String).toUtc(),
      recordIds: (json['recordIds'] as List<dynamic>?)
              ?.map((e) => '$e')
              .toList() ??
          const [],
      fromDate: json['fromDate'] == null
          ? null
          : DateTime.parse(json['fromDate']! as String).toUtc(),
      toDate: json['toDate'] == null
          ? null
          : DateTime.parse(json['toDate']! as String).toUtc(),
    );
  }

  ShareGrant copyWith({DateTime? revokedAt}) {
    return ShareGrant(
      id: id,
      ownerUserId: ownerUserId,
      recipientLabel: recipientLabel,
      categories: categories,
      createdAt: createdAt,
      expiresAt: expiresAt,
      format: format,
      revokedAt: revokedAt ?? this.revokedAt,
      recordIds: recordIds,
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}
