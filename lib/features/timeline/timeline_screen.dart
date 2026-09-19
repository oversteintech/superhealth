import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/l10n/app_strings.dart';
import '../../data/providers/record_providers.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(timelineEventsProvider);
    return Scaffold(
      appBar: AfterAppBar(title: Text(ref.tr('features.timeline'))),
      body: async.when(
        loading: () => const Center(child: AfterLoading()),
        error: (e, _) => Center(child: Text('$e')),
        data: (events) {
          if (events.isEmpty) {
            return AfterEmptyState(
              title: ref.tr('timeline.empty_title'),
              subtitle: ref.tr('timeline.empty_body'),
            );
          }
          final format = DateFormat.yMMMd().add_Hm();
          return AfterScaffoldBody(
            child: ListView.separated(
              itemCount: events.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return AfterInlineBanner(
                    message: ref.tr('timeline.disclaimer'),
                    icon: Icons.info_outline,
                  );
                }
                final event = events[index - 1];
                return AfterCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(event.title),
                    subtitle: Text(
                      '${format.format(event.occurredAt.toLocal())}\n'
                      '${event.sourceLabel}'
                      '${event.detail.isEmpty ? '' : '\n${event.detail}'}',
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
