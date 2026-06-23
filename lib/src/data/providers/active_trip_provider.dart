import 'package:driveforme_driver/src/data/apis/trip_api.dart';
import 'package:driveforme_driver/src/data/models/trip_model.dart';
import 'package:driveforme_driver/src/data/services/secure_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class ActiveTripState {
  final String tripId;
  final TripModel? trip;

  const ActiveTripState({required this.tripId, this.trip});
}

class ActiveTripNotifier extends StateNotifier<ActiveTripState?> {
  final Ref _ref;

  ActiveTripNotifier(this._ref) : super(null);

  Future<void> setActiveTrip(String tripId, {TripModel? trip}) async {
    await _ref.read(secureStorageServiceProvider).saveActiveTripId(tripId);
    state = ActiveTripState(tripId: tripId, trip: trip);
  }

  Future<void> refresh() async {
    final current = state;
    if (current == null) return;

    final response =
        await _ref.read(tripApiProvider).getTripById(current.tripId);
    if (response.success && response.data != null) {
      state = ActiveTripState(tripId: current.tripId, trip: response.data);
    }
  }

  Future<void> clear() async {
    await _ref.read(secureStorageServiceProvider).clearActiveTripId();
    state = null;
  }
}

final activeTripProvider =
    StateNotifierProvider<ActiveTripNotifier, ActiveTripState?>((ref) {
  return ActiveTripNotifier(ref);
});
