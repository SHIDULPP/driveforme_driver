import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

enum LocationAccessState { granted, denied, permanentlyDenied, serviceDisabled }

class LocationPermissionStatus {
  const LocationPermissionStatus({
    required this.accessState,
    required this.isServiceEnabled,
  });

  final LocationAccessState accessState;
  final bool isServiceEnabled;

  bool get isGranted => accessState == LocationAccessState.granted;

  bool get isFullyGranted => isGranted && isServiceEnabled;
}

class LocationPermissionService {
  const LocationPermissionService();

  Future<LocationPermissionStatus> checkStatus() async {
    final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    final permission = await Permission.location.status;

    final accessState = _mapPermissionStatus(permission);
    return LocationPermissionStatus(
      accessState: accessState,
      isServiceEnabled: isServiceEnabled,
    );
  }

  /// Requests OS location permission when still in the soft-denied state.
  ///
  /// Returns the refreshed status. Callers should open app settings only when
  /// permission is permanently denied or location services are off.
  Future<LocationPermissionStatus> requestPermission() async {
    final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      return const LocationPermissionStatus(
        accessState: LocationAccessState.serviceDisabled,
        isServiceEnabled: false,
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return LocationPermissionStatus(
      accessState: _mapGeolocatorPermission(permission),
      isServiceEnabled: true,
    );
  }

  Future<bool> openSettings() => openAppSettings();

  LocationAccessState _mapPermissionStatus(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
        return LocationAccessState.granted;
      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.restricted:
        return LocationAccessState.permanentlyDenied;
      case PermissionStatus.denied:
      case PermissionStatus.provisional:
        return LocationAccessState.denied;
    }
  }

  LocationAccessState _mapGeolocatorPermission(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return LocationAccessState.granted;
      case LocationPermission.deniedForever:
        return LocationAccessState.permanentlyDenied;
      case LocationPermission.denied:
      case LocationPermission.unableToDetermine:
        return LocationAccessState.denied;
    }
  }
}

final locationPermissionServiceProvider = Provider<LocationPermissionService>(
  (ref) => const LocationPermissionService(),
);

final locationPermissionStatusProvider =
    StateProvider<LocationPermissionStatus?>((ref) => null);
