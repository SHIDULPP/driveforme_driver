import 'dart:async';
import 'dart:developer';

import 'package:driveforme_driver/src/data/providers/active_trip_provider.dart';
import 'package:driveforme_driver/src/data/providers/trip_provider.dart';
import 'package:driveforme_driver/src/data/services/secure_storage_service.dart';
import 'package:driveforme_driver/src/data/services/trip_socket_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class DriverLocationService {
  static const _idleInterval = Duration(seconds: 12);
  static const _onTripInterval = Duration(seconds: 4);

  final TripSocketService _socket;
  final SecureStorageService _storage;

  Timer? _timer;
  String? _activeTripId;

  DriverLocationService({
    required TripSocketService socket,
    required SecureStorageService storage,
  })  : _socket = socket,
        _storage = storage;

  Future<void> start({
    required bool isOnline,
    required bool isOnTrip,
    String? tripId,
  }) async {
    stop();
    if (!isOnline && !isOnTrip) return;

    _activeTripId = tripId;
    final hasPermission = await _ensurePermission();
    if (!hasPermission) return;

    await _emitCurrentLocation(isOnTrip: isOnTrip);
    _timer = Timer.periodic(
      isOnTrip ? _onTripInterval : _idleInterval,
      (_) => _emitCurrentLocation(isOnTrip: isOnTrip),
    );
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _activeTripId = null;
  }

  Future<bool> _ensurePermission() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
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
        tripId: _activeTripId,
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

bool _isActivelyOnTrip(ActiveTripState? activeTrip) {
  final trip = activeTrip?.trip;
  if (trip != null) return trip.isOngoingForDriver;
  return activeTrip?.tripId.isNotEmpty == true;
}

final driverLocationServiceProvider = Provider<DriverLocationService>((ref) {
  ref.keepAlive();
  final service = DriverLocationService(
    socket: ref.watch(tripSocketServiceProvider),
    storage: ref.watch(secureStorageServiceProvider),
  );

  void syncTracking() {
    final isOnline = ref.read(driverOnlineProvider);
    final activeTrip = ref.read(activeTripProvider);
    final isOnTrip = _isActivelyOnTrip(activeTrip);
    if (isOnline || isOnTrip) {
      service.start(
        isOnline: isOnline,
        isOnTrip: isOnTrip,
        tripId: isOnTrip ? activeTrip?.tripId : null,
      );
    } else {
      service.stop();
    }
  }

  ref.listen(driverOnlineProvider, (previous, next) => syncTracking());
  ref.listen(activeTripProvider, (previous, next) => syncTracking());
  syncTracking();

  ref.onDispose(service.stop);
  return service;
});
