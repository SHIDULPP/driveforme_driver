import 'package:driveforme_driver/src/data/apis/notification_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationTokenService {
  // ignore: unused_field — reserved for FCM token POST when firebase_messaging is added
  final NotificationApi _notificationApi;

  NotificationTokenService(this._notificationApi);

  /// Registers the device FCM token with the backend.
  ///
  /// Skips silently until firebase_messaging is configured.
  Future<void> registerTokenIfAvailable() async {
    return;
  }
}

final notificationTokenServiceProvider =
    Provider<NotificationTokenService>((ref) {
  return NotificationTokenService(ref.watch(notificationApiProvider));
});
