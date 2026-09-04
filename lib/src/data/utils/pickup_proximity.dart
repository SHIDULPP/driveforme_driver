import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const kPickupProximityRadiusMeters = 150.0;
const kDropoffProximityRadiusMeters = 500.0;

bool isWithinPickupRadius({
  required LatLng? driver,
  required LatLng? pickup,
  double radiusMeters = kPickupProximityRadiusMeters,
}) {
  if (driver == null || pickup == null) return true;
  final distance = Geolocator.distanceBetween(
    driver.latitude,
    driver.longitude,
    pickup.latitude,
    pickup.longitude,
  );
  return distance <= radiusMeters;
}

/// End-trip unlock: driver must be at / near the destination.
///
/// - Missing dropoff coords → allow (cannot enforce).
/// - Missing driver GPS → block until location is available.
bool isWithinDropoffRadius({
  required LatLng? driver,
  required LatLng? dropoff,
  double radiusMeters = kDropoffProximityRadiusMeters,
}) {
  if (dropoff == null) return true;
  if (driver == null) return false;
  final distance = Geolocator.distanceBetween(
    driver.latitude,
    driver.longitude,
    dropoff.latitude,
    dropoff.longitude,
  );
  return distance <= radiusMeters;
}
