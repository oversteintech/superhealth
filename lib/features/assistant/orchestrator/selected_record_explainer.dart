import '../../../domain/privacy/ai_safety_policy.dart';
import '../../../domain/records/observation.dart';

class SelectedRecordSummary {
  const SelectedRecordSummary({
    required this.text,
    required this.sourceLabels,
    required this.uncertaintyNote,
  });

  final String text;
  final List<String> sourceLabels;
  final String uncertaintyNote;
}

/// Explains only explicitly selected observations in plain language.
abstract final class SelectedRecordExplainer {
  static SelectedRecordSummary? explain({
    required List<String> selectedIds,
    required List<Observation> all,
    required bool userExplicitlySelected,
  }) {
    final payload = AiSafetyPolicy.buildPayload(
      userMessage: 'explain',
      selectedRecordIds: selectedIds,
      userExplicitlySelectedRecords: userExplicitlySelected,
    );
    if (payload.blocked || payload.recordIds.isEmpty) return null;

    final chosen =
        all.where((o) => payload.recordIds.contains(o.id)).toList();
    if (chosen.isEmpty) return null;

    final lines = <String>[];
    final sources = <String>[];
    for (final o in chosen) {
      final source = '${o.sourceKind.name}/${o.sourceId}';
      sources.add(source);
      lines.add(
        'Record ${o.id}: ${o.type.name} = ${o.value} ${o.unit} at '
        '${o.measuredAtUtc.toIso8601String()} (source: $source).',
      );
      if (o.reliabilityNote.isNotEmpty) {
        lines.add('Note from entry: ${o.reliabilityNote}');
      }
    }
    lines.add(AiSafetyPolicy.refuseClinicalEn);
    return SelectedRecordSummary(
      text: lines.join('\n'),
      sourceLabels: sources,
      uncertaintyNote:
          'Uncertainty: values are as you entered or imported; '
          'missing context is not filled in; this is not a clinical interpretation.',
    );
  }
}
