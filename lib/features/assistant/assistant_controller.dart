import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/infrastructure_providers.dart';

class ChatMessage {
  const ChatMessage({required this.text, required this.isUser});

  final String text;
  final bool isUser;
}

class AssistantState {
  const AssistantState({
    this.messages = const [],
    this.busy = false,
  });

  final List<ChatMessage> messages;
  final bool busy;

  AssistantState copyWith({
    List<ChatMessage>? messages,
    bool? busy,
  }) {
    return AssistantState(
      messages: messages ?? this.messages,
      busy: busy ?? this.busy,
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
              'Hi — I am SuperHealth Mate (Health AI). Ask about medications, labs, sleep, nutrition, or your emergency card. I never diagnose.',
          isUser: false,
        ),
      ],
    );
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

    final replies =
        await ref.read(healthRepositoryProvider).assistantReplies(trimmed);
    state = state.copyWith(
      busy: false,
      messages: [
        ...state.messages,
        ...replies.map((r) => ChatMessage(text: r, isUser: false)),
      ],
    );
  }
}