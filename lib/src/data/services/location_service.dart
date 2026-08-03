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

    final position = await _resolvePosition();
    if (position == null) return null;

    final address = await _resolveAddress(position);

    return TripLocation(
      address: address.isNotEmpty
          ? address
          : '${position.latitude.toStringAsFixed(5)}, '
              '${position.longitude.toStringAsFixed(5)}',
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  Future<Position?> _resolvePosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      // Fall back to the last known fix when a fresh GPS read fails/times out.
      try {
        return await Geolocator.getLastKnownPosition();
      } catch (_) {
        return null;
      }
    }
  }

  /// Reverse-geocode coordinates. Failures must not discard a valid GPS fix.
  Future<String> _resolveAddress(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final placemark = placemarks.isNotEmpty ? placemarks.first : null;
      return _formatPlacemark(placemark);
    } catch (_) {
      return '';
    }
  }

  Future<LocationPermission?> _ensureLocationPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return null;
    }

    // Permission prompting is owned by [LocationPermissionGate] so the custom
    // sheet stays the single entry point. Here we only consume an existing grant.
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    return permission;
  }

  String _formatPlacemark(Placemark? placemark) {
    if (placemark == null) return '';

    final parts = <String>[
      if ((placemark.subLocality ?? '').trim().isNotEmpty)
        placemark.subLocality!.trim(),
      if ((placemark.locality ?? '').trim().isNotEmpty)
        placemark.locality!.trim(),
      if ((placemark.administrativeArea ?? '').trim().isNotEmpty)
        placemark.administrativeArea!.trim(),
    ];

    // Prefer neighbourhood + city. Fall back to street/name when locality is empty.
    if (parts.isEmpty) {
      if ((placemark.street ?? '').trim().isNotEmpty) {
        parts.add(placemark.street!.trim());
      }
      if ((placemark.name ?? '').trim().isNotEmpty) {
        parts.add(placemark.name!.trim());
      }
    }

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
