import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/infrastructure_providers.dart';
import '../../domain/entities/app_notification.dart';

final notificationsProvider =
    AsyncNotifierProvider<NotificationsController, List<AppNotification>>(
  NotificationsController.new,
);

final unreadNotificationCountProvider = Provider<int>((ref) {
  final async = ref.watch(notificationsProvider);
  return async.maybeWhen(
    data: (items) => items.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
});

class NotificationsController extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() {
    return ref.watch(healthRepositoryProvider).getNotifications();
  }

  Future<void> markRead(String id) async {
    await ref.read(healthRepositoryProvider).markNotificationRead(id);
    ref.invalidateSelf();
  }
}