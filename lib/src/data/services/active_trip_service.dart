import 'package:driveforme_driver/src/data/apis/trip_api.dart';
import 'package:driveforme_driver/src/data/services/secure_storage_service.dart';
import 'package:driveforme_driver/src/data/utils/trip_navigation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActiveTripService {
  final SecureStorageService _storage;
  final TripApi _tripApi;

  ActiveTripService({
    required SecureStorageService storage,
    required TripApi tripApi,
  }) : _storage = storage,
       _tripApi = tripApi;

  /// Resumes only the trip id last saved locally.
  ///
  /// Assigned/ongoing list fallbacks are intentionally skipped so dismissing a
  /// trip screen (or finishing a stale trip) is not undone on the next launch.
  Future<TripNavigationTarget?> resolveResumableTrip() async {
    final storedId = await _storage.getActiveTripId();
    if (storedId == null || storedId.isEmpty) return null;

    final target = await _targetFromTripId(storedId);
    if (target == null) {
      await _storage.clearActiveTripId();
    }
    return target;
  }

  Future<TripNavigationTarget?> _targetFromTripId(String tripId) async {
    final response = await _tripApi.getTripById(tripId);
    if (!response.success || response.data == null) return null;

    final trip = response.data!;
    if (!isResumableTrip(trip)) {
      await _storage.clearActiveTripId();
      return null;
    }

    return tripNavigationTarget(trip);
  }
}

final activeTripServiceProvider = Provider<ActiveTripService>((ref) {
  return ActiveTripService(
    storage: ref.watch(secureStorageServiceProvider),
    tripApi: ref.watch(tripApiProvider),
  );
});
