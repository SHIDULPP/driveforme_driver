import 'package:driveforme_driver/src/data/models/api_response.dart';
import 'package:driveforme_driver/src/data/models/notification_model.dart';
import 'package:driveforme_driver/src/data/providers/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationApi {
  final ApiProvider _api;

  NotificationApi(this._api);

  Future<ApiResponse<List<NotificationModel>>> getNotifications() async {
    final response = await _api.get('/notifications', requireAuth: true);

    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to load notifications.',
        response.statusCode,
      );
    }

    final items = nestedListData(response.data)
        .map(NotificationModel.fromJson)
        .toList();

    return ApiResponse.success(items, response.statusCode);
  }

  Future<ApiResponse<NotificationModel>> markAsRead(String id) async {
    final response = await _api.patch(
      '/notifications/$id/read',
      {},
      requireAuth: true,
    );

    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to mark notification as read.',
        response.statusCode,
      );
    }

    final data = nestedData(response.data);
    if (data == null) {
      return ApiResponse.error('Invalid notification response');
    }

    return ApiResponse.success(
      NotificationModel.fromJson(data),
      response.statusCode,
    );
  }

  Future<ApiResponse<void>> deleteNotification(String id) async {
    final response = await _api.delete(
      '/notifications/$id',
      requireAuth: true,
    );

    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to delete notification.',
        response.statusCode,
      );
    }

    return ApiResponse.success(null, response.statusCode);
  }

  Future<ApiResponse<void>> registerFcmToken(String fcmToken) async {
    final response = await _api.post(
      '/notifications/token',
      {'fcmToken': fcmToken},
      requireAuth: true,
    );

    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to register push token.',
        response.statusCode,
      );
    }

    return ApiResponse.success(null, response.statusCode);
  }
}

final notificationApiProvider = Provider<NotificationApi>((ref) {
  return NotificationApi(ref.watch(apiProviderProvider));
});
