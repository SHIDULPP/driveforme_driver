import 'package:driveforme_driver/src/data/apis/trip_api.dart';
import 'package:driveforme_driver/src/data/models/trip_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final tripPreferenceProvider = StateProvider<String>((ref) => 'short_trip');

final dismissedTripIdsProvider = StateProvider<Set<String>>((ref) => {});

/// Loads open trip requests for the driver from `GET /trips/available`.
final availableTripsProvider = FutureProvider<List<TripModel>>((ref) async {
  final tripType = ref.watch(tripPreferenceProvider);
  final dismissed = ref.watch(dismissedTripIdsProvider);

  final response = await ref.read(tripApiProvider).listAvailableTrips(
        tripType: tripType,
      );

  if (!response.success) {
    throw Exception(response.message ?? 'Failed to load available trips.');
  }

  return (response.data ?? [])
      .where((trip) => !dismissed.contains(trip.id))
      .toList();
});

void dismissTripRequest(WidgetRef ref, String tripId) {
  ref.read(dismissedTripIdsProvider.notifier).update(
        (ids) => {...ids, tripId},
      );
  ref.invalidate(availableTripsProvider);
}
