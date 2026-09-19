class AiContextPayload {
  const AiContextPayload({
    required this.userMessage,
    required this.recordIds,
    required this.blocked,
    required this.refusalKey,
  });

  final String userMessage;
  final List<String> recordIds;
  final bool blocked;
  final String? refusalKey;

  Map<String, Object?> toAnalyticsFields() => {
        'blocked': blocked,
        'record_count': recordIds.length,
        if (refusalKey != null) 'refusal': refusalKey,
      };
}

/// Mate may only see records the user explicitly selected. No diagnosis.
abstract final class AiSafetyPolicy {
  static final _blocked = RegExp(
    r'\b(diagnos\w*|prescribe|dos(e|age)|treat(ment|ing|ed)?|triage|which (drug|medicine)|sağlık puan|health score)\b',
    caseSensitive: false,
  );

  static bool isBlockedPrompt(String prompt) => _blocked.hasMatch(prompt);

  static AiContextPayload buildPayload({
    required String userMessage,
    List<String> selectedRecordIds = const [],
    bool userExplicitlySelectedRecords = false,
  }) {
    if (isBlockedPrompt(userMessage)) {
      return AiContextPayload(
        userMessage: userMessage,
        recordIds: const [],
        blocked: true,
        refusalKey: 'ai.refuse_clinical',
      );
    }
    final ids = userExplicitlySelectedRecords ? selectedRecordIds : const <String>[];
    return AiContextPayload(
      userMessage: userMessage,
      recordIds: ids,
      blocked: false,
      refusalKey: null,
    );
  }

  static const refuseClinicalEn =
      'I cannot diagnose, treat, calculate doses, or triage emergencies. '
      'I only help you navigate records you select and prepare questions for a licensed professional.';

  static const refuseClinicalTr =
      'Tanı, tedavi, doz hesabı veya acil durum değerlendirmesi yapamam. '
      'Yalnızca sizin seçtiğiniz kayıtlarda gezinmenize ve lisanslı bir uzmana soru hazırlamanıza yardımcı olurum.';
}
