import 'package:driveforme_driver/src/data/models/trip_model.dart';

class TripNavigationTarget {
  final String route;
  final Map<String, dynamic> arguments;

  const TripNavigationTarget({
    required this.route,
    required this.arguments,
  });
}

const _activeTripStatuses = {
  'driver_assigned',
  'in_progress',
};

/// Statuses where the driver is en route to pickup (includes past-due scheduled).
const pickupStageStatuses = {
  'driver_assigned',
  'scheduled',
};

bool isActiveTripStatus(String status) => _activeTripStatuses.contains(status);

bool isPickupStageStatus(TripModel trip) {
  if (!pickupStageStatuses.contains(trip.status)) return false;
  if (trip.isScheduled) return trip.isPickupTimeReached;
  return true;
}

bool isResumableTrip(TripModel trip) {
  if (trip.isCancelled) return false;
  if (isActiveTripStatus(trip.status)) return true;
  return trip.isScheduled && trip.isPickupTimeReached;
}

TripNavigationTarget? tripNavigationTarget(TripModel trip) {
  switch (trip.status) {
    case 'driver_assigned':
    case 'scheduled':
      if (trip.isScheduled && !trip.isPickupTimeReached) return null;
      return TripNavigationTarget(
        route: 'driverArrived',
        arguments: trip.toDriverArrivedArguments(),
      );
    case 'in_progress':
      return TripNavigationTarget(
        route: 'endTrip',
        arguments: trip.toEndTripArguments(),
      );
    case 'completed':
      return TripNavigationTarget(
        route: 'tripCompleted',
        arguments: trip.toTripCompletedArguments(),
      );
    case 'cancelled':
      return TripNavigationTarget(
        route: 'tripDetails',
        arguments: {'trip': trip.toTripDetailsArguments()},
      );
    default:
      return null;
  }
}
