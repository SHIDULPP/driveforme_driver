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

bool isActiveTripStatus(String status) => _activeTripStatuses.contains(status);

TripNavigationTarget? tripNavigationTarget(TripModel trip) {
  switch (trip.status) {
    case 'driver_assigned':
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
