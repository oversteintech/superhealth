import 'package:after_core/after_core.dart';
import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/config/feature_flag_keys.dart';
import '../../app/l10n/app_strings.dart';
import '../common/widgets/empty_placeholder.dart';
import 'assistant_controller.dart';

class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = ref.watch(afterFeatureFlagsProvider).isEnabled(
          FeatureFlagKeys.aiAssistant,
          defaultValue: true,
        );
    if (!enabled) {
      return EmptyPlaceholder(
        title: ref.tr('assistant.disabled_title'),
        message: ref.tr('assistant.disabled_body'),
      );
    }

    final state = ref.watch(assistantControllerProvider);

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.messages.length + (state.busy ? 1 : 0),
            itemBuilder: (context, index) {
              if (state.busy && index == state.messages.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: AfterAiThinking(),
                );
              }
              final message = state.messages[index];
              final align =
                  message.isUser ? Alignment.centerRight : Alignment.centerLeft;
              final bg = message.isUser
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest;
              return Align(
                alignment: align,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(12),
                  constraints: const BoxConstraints(maxWidth: 340),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(message.text),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: AfterTextField(
                  controller: _input,
                  hint: ref.tr('assistant.hint'),
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: 8),
              AfterButton(
                label: ref.tr('assistant.send'),
                variant: AfterButtonVariant.ai,
                onPressed: state.busy ? null : _send,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _send() async {
    final text = _input.text;
    _input.clear();
    await ref.read(assistantControllerProvider.notifier).send(text);
  }
}