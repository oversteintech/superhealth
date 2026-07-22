import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifications/notification_inbox_screen.dart';
import '../notifications/notifications_controller.dart';

class NotificationCenterButton extends ConsumerWidget {
  const NotificationCenterButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadNotificationCountProvider);

    return IconButton(
      tooltip: 'Notifications',
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const NotificationInboxScreen(),
          ),
        );
      },
      icon: Badge(
        isLabelVisible: unread > 0,
        label: Text('$unread'),
        child: const Icon(Icons.notifications_outlined),
      ),
    );
  }
}