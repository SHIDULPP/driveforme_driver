import 'package:driveforme_driver/src/data/apis/trip_api.dart';
import 'package:driveforme_driver/src/data/models/trip_model.dart';
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

  Future<TripNavigationTarget?> resolveResumableTrip() async {
    final storedId = await _storage.getActiveTripId();
    if (storedId != null && storedId.isNotEmpty) {
      final target = await _targetFromTripId(storedId);
      if (target != null) return target;
      await _storage.clearActiveTripId();
    }

    final inProgress = await _tripApi.listOngoingTrips();
    if (inProgress.success && inProgress.data != null) {
      final trip = _firstResumableTrip(inProgress.data!);
      if (trip != null) {
        await _storage.saveActiveTripId(trip.id);
        return tripNavigationTarget(trip);
      }
    }

    final assigned = await _tripApi.listAssignedTrips();
    if (assigned.success && assigned.data != null) {
      final trip = _firstResumableTrip(assigned.data!);
      if (trip != null) {
        await _storage.saveActiveTripId(trip.id);
        return tripNavigationTarget(trip);
      }
    }

    return null;
  }

  Future<TripNavigationTarget?> _targetFromTripId(String tripId) async {
    final response = await _tripApi.getTripById(tripId);
    if (!response.success || response.data == null) return null;

    final trip = response.data!;
    if (trip.isCancelled || !isActiveTripStatus(trip.status)) {
      await _storage.clearActiveTripId();
      return null;
    }

    return tripNavigationTarget(trip);
  }

  TripModel? _firstResumableTrip(List<TripModel> trips) {
    for (final trip in trips) {
      if (!trip.isCancelled && isActiveTripStatus(trip.status)) {
        return trip;
      }
    }
    return null;
  }
}

final activeTripServiceProvider = Provider<ActiveTripService>((ref) {
  return ActiveTripService(
    storage: ref.watch(secureStorageServiceProvider),
    tripApi: ref.watch(tripApiProvider),
  );
});
