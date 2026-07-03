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
}

final locationPermissionServiceProvider = Provider<LocationPermissionService>(
  (ref) => const LocationPermissionService(),
);

final locationPermissionStatusProvider =
    StateProvider<LocationPermissionStatus?>((ref) => null);
