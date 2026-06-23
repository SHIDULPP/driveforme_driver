import 'dart:async';
import 'dart:developer';

import 'package:driveforme_driver/src/data/providers/active_trip_provider.dart';
import 'package:driveforme_driver/src/data/providers/trip_provider.dart';
import 'package:driveforme_driver/src/data/services/secure_storage_service.dart';
import 'package:driveforme_driver/src/data/services/trip_socket_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class DriverLocationService {
  final TripSocketService _socket;
  final SecureStorageService _storage;

  Timer? _timer;
  bool _permissionDenied = false;

  DriverLocationService({
    required TripSocketService socket,
    required SecureStorageService storage,
  })  : _socket = socket,
        _storage = storage;

  Future<void> start({
    required bool isOnline,
    required bool isOnTrip,
  }) async {
    stop();
    if (!isOnline && !isOnTrip) return;

    final hasPermission = await _ensurePermission();
    if (!hasPermission) return;

    await _emitCurrentLocation(isOnTrip: isOnTrip);
    _timer = Timer.periodic(const Duration(seconds: 12), (_) {
      _emitCurrentLocation(isOnTrip: isOnTrip);
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<bool> _ensurePermission() async {
    if (_permissionDenied) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _permissionDenied = true;
      log('Location permission denied', name: 'DriverLocationService');
      return false;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    return true;
  }

  Future<void> _emitCurrentLocation({required bool isOnTrip}) async {
    try {
      final driverId = await _storage.getUserId();
      if (driverId == null || driverId.isEmpty) return;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      _socket.updateLocation(
        driverId: driverId,
        latitude: position.latitude,
        longitude: position.longitude,
        status: isOnTrip ? 'busy' : 'online',
      );
    } catch (e) {
      log('Failed to emit location: $e', name: 'DriverLocationService');
    }
  }

  Future<Position?> getCurrentPosition() async {
    final hasPermission = await _ensurePermission();
    if (!hasPermission) return null;
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
    } catch (_) {
      return null;
    }
  }
}

final driverLocationServiceProvider = Provider<DriverLocationService>((ref) {
  final service = DriverLocationService(
    socket: ref.watch(tripSocketServiceProvider),
    storage: ref.watch(secureStorageServiceProvider),
  );

  ref.listen(driverOnlineProvider, (previous, next) {
    final activeTrip = ref.read(activeTripProvider);
    final isOnTrip = activeTrip?.trip?.isInProgress == true;
    if (next || isOnTrip) {
      service.start(isOnline: next, isOnTrip: isOnTrip);
    } else {
      service.stop();
    }
  });

  ref.listen(activeTripProvider, (previous, next) {
    final isOnline = ref.read(driverOnlineProvider);
    final isOnTrip = next?.trip?.isInProgress == true;
    if (isOnline || isOnTrip) {
      service.start(isOnline: isOnline, isOnTrip: isOnTrip);
    } else {
      service.stop();
    }
  });

  ref.onDispose(service.stop);
  return service;
});
