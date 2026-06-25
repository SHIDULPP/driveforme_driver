import 'package:driveforme_driver/src/data/models/trip_location_model.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Default map center (Kochi) when geocoding is unavailable.
const kDefaultMapCenter = LatLng(9.9312, 76.2673);

class LocationService {
  const LocationService();

  Future<TripLocation> resolveLocation(TripLocation location) async {
    if (location.hasCoordinates || !location.hasAddress) {
      return location;
    }

    final coords = await geocodeAddress(location.address);
    if (coords == null) return location;

    return location.copyWith(
      latitude: coords.latitude,
      longitude: coords.longitude,
    );
  }

  Future<LatLng?> geocodeAddress(String address) async {
    final query = address.trim();
    if (query.isEmpty) return null;

    try {
      final results = await locationFromAddress(query);
      if (results.isEmpty) return null;
      final first = results.first;
      return LatLng(first.latitude, first.longitude);
    } catch (_) {
      return null;
    }
  }
}
