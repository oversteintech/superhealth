import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/infrastructure_providers.dart';
import '../../data/providers/record_providers.dart';
import '../../domain/privacy/ai_safety_policy.dart';
import 'orchestrator/health_ai_in_app_route_catalog.dart';
import 'orchestrator/selected_record_explainer.dart';

class ChatMessage {
  const ChatMessage({required this.text, required this.isUser});

  final String text;
  final bool isUser;
}

class AssistantState {
  const AssistantState({
    this.messages = const [],
    this.busy = false,
    this.selectedRecordIds = const [],
  });

  final List<ChatMessage> messages;
  final bool busy;
  final List<String> selectedRecordIds;

  AssistantState copyWith({
    List<ChatMessage>? messages,
    bool? busy,
    List<String>? selectedRecordIds,
  }) {
    return AssistantState(
      messages: messages ?? this.messages,
      busy: busy ?? this.busy,
      selectedRecordIds: selectedRecordIds ?? this.selectedRecordIds,
    );
  }
}

final assistantControllerProvider =
    NotifierProvider<AssistantController, AssistantState>(
  AssistantController.new,
);

class AssistantController extends Notifier<AssistantState> {
  @override
  AssistantState build() {
    return const AssistantState(
      messages: [
        ChatMessage(
          text:
              'Hi — I am SuperHealth Mate. I route you in-app first, and only explain records you select. I never diagnose, treat, or calculate doses.',
          isUser: false,
        ),
      ],
    );
  }

  void setSelectedRecordIds(List<String> ids) {
    state = state.copyWith(selectedRecordIds: ids);
  }

  Future<void> send(String prompt) async {
    final trimmed = prompt.trim();
    if (trimmed.isEmpty || state.busy) return;

    state = state.copyWith(
      busy: true,
      messages: [
        ...state.messages,
        ChatMessage(text: trimmed, isUser: true),
      ],
    );

    final payload = AiSafetyPolicy.buildPayload(
      userMessage: trimmed,
      selectedRecordIds: state.selectedRecordIds,
      userExplicitlySelectedRecords: state.selectedRecordIds.isNotEmpty,
    );
    if (payload.blocked) {
      state = state.copyWith(
        busy: false,
        messages: [
          ...state.messages,
          const ChatMessage(
            text: AiSafetyPolicy.refuseClinicalEn,
            isUser: false,
          ),
        ],
      );
      return;
    }

    final inApp = HealthAiInAppRouteCatalog.resolve(trimmed);
    if (inApp != null && payload.recordIds.isEmpty) {
      state = state.copyWith(
        busy: false,
        messages: [
          ...state.messages,
          ChatMessage(text: inApp.message, isUser: false),
        ],
      );
      return;
    }

    if (payload.recordIds.isNotEmpty) {
      final userId = ref.read(currentHealthUserIdProvider);
      final obs =
          ref.read(healthRecordsRepositoryProvider).listObservations(userId);
      final summary = SelectedRecordExplainer.explain(
        selectedIds: payload.recordIds,
        all: obs,
        userExplicitlySelected: true,
      );
      state = state.copyWith(
        busy: false,
        messages: [
          ...state.messages,
          ChatMessage(
            text: summary == null
                ? AiSafetyPolicy.refuseClinicalEn
                : '${summary.text}\n\n${summary.uncertaintyNote}',
            isUser: false,
          ),
        ],
      );
      return;
    }

    final replies =
        await ref.read(healthRepositoryProvider).assistantReplies(trimmed);
    state = state.copyWith(
      busy: false,
      messages: [
        ...state.messages,
        ...replies.map((r) => ChatMessage(text: r, isUser: false)),
        const ChatMessage(
          text: AiSafetyPolicy.refuseClinicalEn,
          isUser: false,
        ),
      ],
    );
  }
}
