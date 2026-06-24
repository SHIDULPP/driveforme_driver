import 'package:driveforme_driver/src/data/apis/trip_api.dart';
import 'package:driveforme_driver/src/data/models/trip_model.dart';
import 'package:driveforme_driver/src/data/providers/active_trip_provider.dart';
import 'package:driveforme_driver/src/data/services/navigation_services.dart';
import 'package:driveforme_driver/src/data/utils/trip_navigation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fetches trip from API and caches it in [activeTripProvider].
Future<TripModel?> fetchAndCacheTrip(WidgetRef ref, String tripMongoId) async {
  if (tripMongoId.isEmpty) return null;

  final response = await ref.read(tripApiProvider).getTripById(tripMongoId);
  if (!response.success || response.data == null) return null;

  final trip = response.data!;
  await ref
      .read(activeTripProvider.notifier)
      .setActiveTrip(tripMongoId, trip: trip);
  return trip;
}

/// Navigates away when the trip leaves [expectedStatuses].
///
/// Returns `true` if navigation was performed.
bool navigateIfTripLeftExpectedStatus({
  required TripModel trip,
  required Set<String> expectedStatuses,
}) {
  if (expectedStatuses.contains(trip.status)) return false;

  if (trip.isCancelled) {
    NavigationService().pushNamedAndRemoveUntil('navBar');
    return true;
  }

  final target = tripNavigationTarget(trip);
  if (target == null) return false;

  NavigationService().pushNamedAndRemoveUntil(
    target.route,
    arguments: target.arguments,
  );
  return true;
}
