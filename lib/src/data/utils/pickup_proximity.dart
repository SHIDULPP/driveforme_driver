import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const kPickupProximityRadiusMeters = 150.0;

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
