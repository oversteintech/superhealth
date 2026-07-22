import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/app_strings.dart';
import '../common/widgets/empty_placeholder.dart';
import 'notifications_controller.dart';

class NotificationInboxScreen extends ConsumerWidget {
  const NotificationInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AfterAppBar(title: Text(ref.tr('notifications.title'))),
      body: async.when(
        loading: () => const Center(child: AfterLoading()),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) {
          if (items.isEmpty) {
            return EmptyPlaceholder(
              title: ref.tr('notifications.empty_title'),
              message: ref.tr('notifications.empty_body'),
            );
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: Icon(
                  item.isRead
                      ? Icons.notifications_none
                      : Icons.notifications_active,
                  color: item.isRead
                      ? null
                      : Theme.of(context).colorScheme.primary,
                ),
                title: Text(item.title),
                subtitle: Text(item.body),
                onTap: () => ref
                    .read(notificationsProvider.notifier)
                    .markRead(item.id),
              );
            },
          );
        },
      ),
    );
  }
}