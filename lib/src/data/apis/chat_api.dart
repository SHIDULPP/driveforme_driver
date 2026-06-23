import 'package:driveforme_driver/src/data/models/api_response.dart';
import 'package:driveforme_driver/src/data/models/chat_message_model.dart';
import 'package:driveforme_driver/src/data/models/conversation_model.dart';
import 'package:driveforme_driver/src/data/providers/api_provider.dart';
import 'package:driveforme_driver/src/data/services/secure_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatApi {
  final ApiProvider _api;
  final SecureStorageService _storage;

  ChatApi(this._api, this._storage);

  Future<ApiResponse<ChatMessageModel>> sendMessage({
    required String receiverId,
    required String content,
  }) async {
    final response = await _api.post(
      '/chat/send',
      {'receiverId': receiverId, 'content': content.trim()},
      requireAuth: true,
    );

    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to send message.',
        response.statusCode,
      );
    }

    final data = nestedData(response.data);
    if (data == null) {
      return ApiResponse.error('Invalid send message response');
    }

    final userId = await _storage.getUserId();
    return ApiResponse.success(
      ChatMessageModel.fromJson(data, currentUserId: userId),
      response.statusCode,
    );
  }

  Future<ApiResponse<List<ConversationModel>>> getConversations() async {
    final response = await _api.get('/chat/conversations', requireAuth: true);

    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to load conversations.',
        response.statusCode,
      );
    }

    final items = nestedListData(response.data)
        .map(ConversationModel.fromJson)
        .toList();

    return ApiResponse.success(items, response.statusCode);
  }

  Future<ApiResponse<List<ChatMessageModel>>> getMessages(
    String otherUserId,
  ) async {
    final response = await _api.get(
      '/chat/messages/$otherUserId',
      requireAuth: true,
    );

    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to load messages.',
        response.statusCode,
      );
    }

    final userId = await _storage.getUserId();
    final items = nestedListData(response.data)
        .map(
          (json) => ChatMessageModel.fromJson(json, currentUserId: userId),
        )
        .toList();

    return ApiResponse.success(items, response.statusCode);
  }
}

final chatApiProvider = Provider<ChatApi>((ref) {
  return ChatApi(
    ref.watch(apiProviderProvider),
    ref.watch(secureStorageServiceProvider),
  );
});
