import 'package:driveforme_driver/src/data/models/api_response.dart';
import 'package:driveforme_driver/src/data/models/trip_model.dart';
import 'package:driveforme_driver/src/data/providers/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TripApi {
  final ApiProvider _api;

  TripApi(this._api);

  Future<ApiResponse<List<TripModel>>> listAvailableTrips({
    String? tripType,
  }) async {
    final queryParams = <String, String>{};
    if (tripType != null && tripType.isNotEmpty) {
      queryParams['tripType'] = tripType;
    }

    final response = await _api.get(
      '/trips/available',
      requireAuth: true,
      queryParams: queryParams.isEmpty ? null : queryParams,
    );

    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to load available trips.',
        response.statusCode,
      );
    }

    final trips = nestedListData(response.data)
        .map(TripModel.fromJson)
        .where((trip) => !trip.isExpired)
        .toList();

    return ApiResponse.success(trips, response.statusCode);
  }

  Future<ApiResponse<TripModel>> getTripById(String tripId) async {
    final response = await _api.get(
      '/trips/$tripId',
      requireAuth: true,
    );

    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to load trip.',
        response.statusCode,
      );
    }

    final data = nestedData(response.data);
    if (data == null) {
      return ApiResponse.error('Invalid trip response');
    }

    return ApiResponse.success(TripModel.fromJson(data), response.statusCode);
  }

  Future<ApiResponse<TripModel>> acceptTrip(String tripId) async {
    final response = await _api.post(
      '/trips/$tripId/accept',
      {},
      requireAuth: true,
    );

    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to accept trip.',
        response.statusCode,
      );
    }

    final data = nestedData(response.data);
    if (data == null) {
      return ApiResponse.error('Invalid accept trip response');
    }

    return ApiResponse.success(TripModel.fromJson(data), response.statusCode);
  }
}

final tripApiProvider = Provider<TripApi>((ref) {
  return TripApi(ref.watch(apiProviderProvider));
});
