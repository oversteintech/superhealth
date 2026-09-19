import '../records/observation.dart';
import '../records/share_grant.dart';

class ShareExportResult {
  const ShareExportResult({
    required this.grantId,
    required this.format,
    required this.body,
    required this.contentType,
  });

  final String grantId;
  final ShareFormat format;
  final String body;
  final String contentType;
}

/// Builds CSV / text-PDF summaries from selected categories. No diagnosis text.
abstract final class ShareExportBuilder {
  static ShareExportResult build({
    required ShareGrant grant,
    required List<Observation> observations,
  }) {
    final scoped = observations.where((o) {
      if (grant.fromDate != null &&
          o.measuredAtUtc.isBefore(grant.fromDate!.toUtc())) {
        return false;
      }
      if (grant.toDate != null && o.measuredAtUtc.isAfter(grant.toDate!.toUtc())) {
        return false;
      }
      if (grant.recordIds.isNotEmpty && !grant.recordIds.contains(o.id)) {
        return false;
      }
      return true;
    }).toList();

    if (grant.format == ShareFormat.csv) {
      final buf = StringBuffer('id,type,value,unit,measuredAtUtc,source\n');
      for (final o in scoped) {
        buf.writeln(
          '${o.id},${o.type.name},${o.value},${o.unit},'
          '${o.measuredAtUtc.toIso8601String()},'
          '${o.sourceKind.name}/${o.sourceId}',
        );
      }
      return ShareExportResult(
        grantId: grant.id,
        format: ShareFormat.csv,
        body: buf.toString(),
        contentType: 'text/csv',
      );
    }

    // Text stand-in for PDF until a rendering package is wired.
    final lines = <String>[
      'Super Health share summary (text/PDF placeholder)',
      'Recipient: ${grant.recipientLabel}',
      'Expires: ${grant.expiresAt.toUtc().toIso8601String()}',
      'Categories: ${grant.categories.map((e) => e.name).join(', ')}',
      'Disclaimer: Personal records only — not a diagnosis or treatment plan.',
      '---',
    ];
    for (final o in scoped) {
      lines.add(
        '${o.measuredAtUtc.toIso8601String()} · ${o.type.name} · '
        '${o.value} ${o.unit} · source=${o.sourceKind.name}/${o.sourceId}',
      );
    }
    return ShareExportResult(
      grantId: grant.id,
      format: ShareFormat.pdfText,
      body: lines.join('\n'),
      contentType: 'text/plain',
    );
  }
}
