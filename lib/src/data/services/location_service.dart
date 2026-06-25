import 'package:driveforme_driver/src/data/models/trip_location_model.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Default map center (Kochi) when geocoding is unavailable.
const kDefaultMapCenter = LatLng(9.9312, 76.2673);

class LocationService {
  const LocationService();

  Future<TripLocation?> getCurrentLocation() async {
    final permission = await _ensureLocationPermission();
    if (permission == null) return null;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final placemark = placemarks.isNotEmpty ? placemarks.first : null;
      final address = _formatPlacemark(placemark);

      return TripLocation(
        address: address.isNotEmpty
            ? address
            : '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}',
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (_) {
      return null;
    }
  }

  Future<LocationPermission?> _ensureLocationPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    return permission;
  }

  String _formatPlacemark(Placemark? placemark) {
    if (placemark == null) return '';

    final parts = <String>[
      if ((placemark.name ?? '').trim().isNotEmpty) placemark.name!.trim(),
      if ((placemark.street ?? '').trim().isNotEmpty) placemark.street!.trim(),
      if ((placemark.subLocality ?? '').trim().isNotEmpty)
        placemark.subLocality!.trim(),
      if ((placemark.locality ?? '').trim().isNotEmpty)
        placemark.locality!.trim(),
    ];

    return parts.toSet().join(', ');
  }

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
