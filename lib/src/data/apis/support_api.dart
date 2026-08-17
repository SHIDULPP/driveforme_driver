import 'package:driveforme_driver/src/data/models/api_response.dart';
import 'package:driveforme_driver/src/data/providers/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupportApi {
  final ApiProvider _api;

  SupportApi(this._api);

  Future<ApiResponse<Map<String, dynamic>>> createTicket({
    required String category,
    required String subject,
    required String description,
    String? tripMongoId,
  }) {
    return _api.post(
      '/support/tickets',
      {
        'category': category,
        'subject': subject,
        'description': description,
        if (tripMongoId != null && tripMongoId.isNotEmpty)
          'tripId': tripMongoId,
      },
      requireAuth: true,
    );
  }
}

final supportApiProvider = Provider<SupportApi>((ref) {
  return SupportApi(ref.watch(apiProviderProvider));
});

bool isMongoObjectId(String value) => RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(value);
