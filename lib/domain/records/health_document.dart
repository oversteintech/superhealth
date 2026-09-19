enum HealthDocumentKind {
  labResult,
  prescription,
  vaccinationCard,
  report,
  imaging,
  other,
}

class HealthDocument {
  const HealthDocument({
    required this.id,
    required this.ownerUserId,
    required this.title,
    required this.kind,
    required this.documentDate,
    required this.localUri,
    this.tags = const [],
    this.mimeType = 'application/octet-stream',
  });

  final String id;
  final String ownerUserId;
  final String title;
  final HealthDocumentKind kind;
  final DateTime documentDate;
  final String localUri;
  final List<String> tags;
  final String mimeType;

  Map<String, Object?> toJson() => {
        'id': id,
        'ownerUserId': ownerUserId,
        'title': title,
        'kind': kind.name,
        'documentDate': documentDate.toUtc().toIso8601String(),
        'localUri': localUri,
        'tags': tags,
        'mimeType': mimeType,
      };

  factory HealthDocument.fromJson(Map<String, Object?> json) {
    return HealthDocument(
      id: json['id']! as String,
      ownerUserId: json['ownerUserId']! as String,
      title: json['title']! as String,
      kind: HealthDocumentKind.values.byName(json['kind']! as String),
      documentDate: DateTime.parse(json['documentDate']! as String).toUtc(),
      localUri: json['localUri']! as String,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => '$e').toList() ?? const [],
      mimeType: json['mimeType'] as String? ?? 'application/octet-stream',
    );
  }
}
