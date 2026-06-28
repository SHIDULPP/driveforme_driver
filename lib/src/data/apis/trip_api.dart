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

  Future<ApiResponse<List<TripModel>>> listOngoingTrips() {
    return _listTrips(status: 'in_progress');
  }

  Future<ApiResponse<List<TripModel>>> listAssignedTrips() {
    return _listTrips(status: 'driver_assigned');
  }

  Future<ApiResponse<List<TripModel>>> listCompletedTrips() {
    return _listTrips(status: 'completed');
  }

  Future<ApiResponse<List<TripModel>>> listCancelledTrips() {
    return _listTrips(status: 'cancelled');
  }

  Future<ApiResponse<List<TripModel>>> listUpcomingTrips() async {
    final response = await _listTrips(status: 'scheduled');
    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to load upcoming trips.',
        response.statusCode,
      );
    }

    final trips = (response.data ?? [])
        .where((trip) => trip.isFutureScheduled)
        .toList()
      ..sort((a, b) {
        final aDate = a.pickupAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.pickupAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aDate.compareTo(bDate);
      });

    return ApiResponse.success(trips, response.statusCode);
  }

  Future<ApiResponse<List<TripModel>>> listDueScheduledTrips() async {
    final response = await _listTrips(status: 'scheduled');
    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to load scheduled trips.',
        response.statusCode,
      );
    }

    final trips = (response.data ?? [])
        .where((trip) => trip.isScheduled && trip.isPickupTimeReached)
        .toList();

    return ApiResponse.success(trips, response.statusCode);
  }

  Future<ApiResponse<List<TripModel>>> _listTrips({
    required String status,
  }) async {
    final response = await _api.get(
      '/trips',
      requireAuth: true,
      queryParams: {'status': status},
    );

    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to load trips.',
        response.statusCode,
      );
    }

    final trips = nestedListData(response.data).map(TripModel.fromJson).toList();

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

  Future<ApiResponse<TripModel>> startTrip(String tripId, String otp) async {
    final response = await _api.post(
      '/trips/$tripId/start',
      {'otp': otp},
      requireAuth: true,
    );

    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to start trip.',
        response.statusCode,
      );
    }

    final data = nestedData(response.data);
    if (data == null) {
      return ApiResponse.error('Invalid start trip response');
    }

    return ApiResponse.success(TripModel.fromJson(data), response.statusCode);
  }

  Future<ApiResponse<TripModel>> completeTrip(String tripId) async {
    final response = await _api.post(
      '/trips/$tripId/complete',
      {},
      requireAuth: true,
    );

    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to complete trip.',
        response.statusCode,
      );
    }

    final data = nestedData(response.data);
    if (data == null) {
      return ApiResponse.error('Invalid complete trip response');
    }

    return ApiResponse.success(TripModel.fromJson(data), response.statusCode);
  }

  Future<ApiResponse<TripModel>> cancelTrip(
    String tripId, {
    String? reason,
  }) async {
    final response = await _api.post(
      '/trips/$tripId/cancel',
      {if (reason != null && reason.isNotEmpty) 'reason': reason},
      requireAuth: true,
    );

    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to cancel trip.',
        response.statusCode,
      );
    }

    final data = nestedData(response.data);
    if (data == null) {
      return ApiResponse.error('Invalid cancel trip response');
    }

    return ApiResponse.success(TripModel.fromJson(data), response.statusCode);
  }
}

final tripApiProvider = Provider<TripApi>((ref) {
  return TripApi(ref.watch(apiProviderProvider));
});
