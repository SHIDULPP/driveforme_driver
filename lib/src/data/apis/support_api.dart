import 'package:DriveFormeDriver/src/data/models/support_models.dart';
import 'package:DriveFormeDriver/src/data/models/api_response.dart';
import 'package:DriveFormeDriver/src/data/providers/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupportApi {
  final ApiProvider _api;

  SupportApi(this._api);

  Future<dynamic> _data(
    Future<ApiResponse<Map<String, dynamic>>> request,
  ) async {
    final response = await request;
    if (!response.success) {
      throw SupportApiException(
        response.message ?? 'Unable to load support. Please try again.',
        response.statusCode,
      );
    }
    return response.data?['data'];
  }

  Future<List<SupportTicket>> listTickets() async {
    final data = await _data(_api.get('/support/tickets', requireAuth: true));
    return (data as List)
        .map((item) => SupportTicket(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<SupportTicket> getTicket(String id) async => SupportTicket(
    Map<String, dynamic>.from(
      await _data(_api.get('/support/tickets/$id', requireAuth: true)) as Map,
    ),
  );

  Future<List<SupportMessage>> messages(String id, {DateTime? before}) async {
    final data = await _data(
      _api.get(
        '/support/tickets/$id/messages',
        requireAuth: true,
        queryParams: {
          'limit': '50',
          if (before != null) 'before': before.toUtc().toIso8601String(),
        },
      ),
    );
    return (data as List)
        .map((item) => SupportMessage(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<SupportMessage> sendMessage(String id, String content) async =>
      SupportMessage(
        Map<String, dynamic>.from(
          await _data(
                _api.post('/support/tickets/$id/messages', {
                  'content': content.trim(),
                }, requireAuth: true),
              )
              as Map,
        ),
      );

  Future<void> markRead(String id) async {
    await _data(_api.patch('/support/tickets/$id/read', {}, requireAuth: true));
  }

  Future<ApiResponse<Map<String, dynamic>>> createTicket({
    required String category,
    required String subject,
    required String description,
    String? tripMongoId,
  }) {
    return _api.post('/support/tickets', {
      'category': category,
      'subject': subject,
      'description': description,
      if (tripMongoId != null && tripMongoId.isNotEmpty) 'tripId': tripMongoId,
    }, requireAuth: true);
  }
}

final supportApiProvider = Provider<SupportApi>((ref) {
  return SupportApi(ref.watch(apiProviderProvider));
});

bool isMongoObjectId(String value) =>
    RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(value);

class SupportApiException implements Exception {
  const SupportApiException(this.message, this.statusCode);
  final String message;
  final int? statusCode;
  @override
  String toString() => message;
}
