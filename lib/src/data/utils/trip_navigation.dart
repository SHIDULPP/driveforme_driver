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
  if (trip.status == 'scheduled') return trip.isPickupTimeReached;
  return true;
}

/// True only for trips the driver should auto-resume after an app restart.
///
/// Uses [TripModel.status] only — do not use [TripModel.isScheduled], which also
/// matches `rideTime == 'scheduled'` and can treat finished trips as active.
bool isResumableTrip(TripModel trip) {
  if (trip.isCancelled || trip.isCompleted) return false;
  if (isActiveTripStatus(trip.status)) return true;
  return trip.status == 'scheduled' && trip.isPickupTimeReached;
}

TripNavigationTarget? tripNavigationTarget(TripModel trip) {
  switch (trip.status) {
    case 'driver_assigned':
    case 'scheduled':
      if (trip.status == 'scheduled' && !trip.isPickupTimeReached) return null;
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
