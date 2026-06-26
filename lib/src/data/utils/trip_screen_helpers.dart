import 'package:driveforme_driver/src/data/apis/trip_api.dart';
import 'package:driveforme_driver/src/data/models/api_response.dart';
import 'package:driveforme_driver/src/data/models/trip_model.dart';
import 'package:driveforme_driver/src/data/providers/active_trip_provider.dart';
import 'package:driveforme_driver/src/data/services/navigation_services.dart';
import 'package:driveforme_driver/src/data/services/secure_storage_service.dart';
import 'package:driveforme_driver/src/data/utils/trip_lifecycle.dart';
import 'package:driveforme_driver/src/data/utils/trip_navigation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Trip fetch/cache helpers backed by a long-lived [Ref].
///
/// Use [tripScreenServiceProvider] instead of passing [WidgetRef] into async
/// helpers — [WidgetRef] becomes invalid when the screen is popped, which
/// breaks poll timers that finish after navigation.
class TripScreenService {
  TripScreenService(this._ref);

  final Ref _ref;

  Future<TripModel?> fetchAndCacheTrip(String tripMongoId) async {
    if (tripMongoId.isEmpty) return null;

    final tripApi = _ref.read(tripApiProvider);
    final activeTripNotifier = _ref.read(activeTripProvider.notifier);

    final response = await tripApi.getTripById(tripMongoId);
    if (!response.success || response.data == null) return null;

    final trip = response.data!;
    if (isActiveTripStatus(trip.status) && !trip.isCancelled) {
      await activeTripNotifier.setActiveTrip(tripMongoId, trip: trip);
    } else if (trip.isCancelled) {
      await activeTripNotifier.clear();
    }
    return trip;
  }

  Future<ApiResponse<TripModel>> cancelTrip(
    String tripMongoId, {
    String? reason,
  }) async {
    if (tripMongoId.isEmpty) {
      return ApiResponse.error('Trip id is missing.');
    }

    final tripApi = _ref.read(tripApiProvider);
    final activeTripNotifier = _ref.read(activeTripProvider.notifier);
    final secureStorage = _ref.read(secureStorageServiceProvider);

    final response = await tripApi.cancelTrip(
      tripMongoId,
      reason: reason ?? 'Cancelled by driver',
    );

    if (!response.success) return response;

    await secureStorage.clearActiveTripId();
    await activeTripNotifier.clear();
    return response;
  }
}

final tripScreenServiceProvider = Provider<TripScreenService>((ref) {
  return TripScreenService(ref);
});

/// Navigates away when the trip leaves [expectedStatuses].
///
/// Returns `true` if navigation was performed.
bool navigateIfTripLeftExpectedStatus({
  required TripModel trip,
  required Set<String> expectedStatuses,
}) {
  if (expectedStatuses.contains(trip.status)) return false;

  if (trip.isCancelled) {
    navigateToHomeAfterActiveTripEnds();
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
