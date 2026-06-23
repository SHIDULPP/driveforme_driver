import 'package:driveforme_driver/src/data/apis/notification_api.dart';
import 'package:driveforme_driver/src/data/models/notification_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationsProvider =
    FutureProvider<List<NotificationModel>>((ref) async {
  final response = await ref.read(notificationApiProvider).getNotifications();
  if (!response.success || response.data == null) {
    throw Exception(response.message ?? 'Failed to load notifications.');
  }
  return response.data!;
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider);
  return notifications.maybeWhen(
    data: (items) => items.where((item) => !item.isRead).length,
    orElse: () => 0,
  );
});
