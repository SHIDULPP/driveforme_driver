import 'package:driveforme_driver/src/data/models/api_response.dart';
import 'package:driveforme_driver/src/data/models/sos_model.dart';
import 'package:driveforme_driver/src/data/providers/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SosApi {
  final ApiProvider _api;

  SosApi(this._api);

  Future<ApiResponse<SosModel>> createSosAlert({
    required SosLocation location,
    required String sosType,
    String? tripId,
  }) async {
    final response = await _api.post(
      '/sos',
      {
        'location': location.toJson(),
        'sosType': sosType,
        if (tripId != null && tripId.isNotEmpty) 'tripId': tripId,
      },
      requireAuth: true,
    );

    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to send SOS alert.',
        response.statusCode,
      );
    }

    final data = nestedData(response.data);
    if (data == null) {
      return ApiResponse.error('Invalid SOS response');
    }

    return ApiResponse.success(SosModel.fromJson(data), response.statusCode);
  }

  Future<ApiResponse<List<SosModel>>> listMyAlerts() async {
    final response = await _api.get('/sos', requireAuth: true);

    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to load SOS alerts.',
        response.statusCode,
      );
    }

    final items =
        nestedListData(response.data).map(SosModel.fromJson).toList();

    return ApiResponse.success(items, response.statusCode);
  }
}

final sosApiProvider = Provider<SosApi>((ref) {
  return SosApi(ref.watch(apiProviderProvider));
});
