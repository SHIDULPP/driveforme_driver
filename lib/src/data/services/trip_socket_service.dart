import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Real-time trip updates from the backend Socket.IO server.
///
/// Drivers join `drivers_room` and receive:
/// - `trip_available` — new/open trip payload (populated trip document)
/// - `trip_unavailable` — `{ tripId }` when a trip is taken or closed
class TripSocketService {
  TripSocketService({required this.socketUrl});

  final String socketUrl;
  io.Socket? _socket;
  void Function(Map<String, dynamic>)? _onTripAvailable;
  void Function(String tripId)? _onTripUnavailable;

  bool get isConnected => _socket?.connected ?? false;

  void connect({
    required void Function(Map<String, dynamic>) onTripAvailable,
    required void Function(String tripId) onTripUnavailable,
  }) {
    _onTripAvailable = onTripAvailable;
    _onTripUnavailable = onTripUnavailable;

    if (_socket?.connected == true) return;

    _socket ??= io.io(
      socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket!
      ..off('connect')
      ..off('trip_available')
      ..off('trip_unavailable')
      ..on('connect', (_) {
        log('Trip socket connected', name: 'TripSocketService');
      })
      ..on('disconnect', (_) {
        log('Trip socket disconnected', name: 'TripSocketService');
      })
      ..on('trip_available', (data) {
        final map = _asMap(data);
        if (map != null) _onTripAvailable?.call(map);
      })
      ..on('trip_unavailable', (data) {
        final map = _asMap(data);
        final tripId = map?['tripId']?.toString() ?? '';
        if (tripId.isNotEmpty) _onTripUnavailable?.call(tripId);
      });

    _socket!.connect();
  }

  void joinDriversRoom() {
    void join() => _socket?.emit('join_drivers_room');

    if (_socket?.connected == true) {
      join();
      return;
    }

    _socket?.once('connect', (_) => join());
  }

  void leaveDriversRoom() {
    if (_socket?.connected == true) {
      _socket!.emit('leave_drivers_room');
    }
  }

  void updateLocation({
    required String driverId,
    required double latitude,
    required double longitude,
    String? status,
  }) {
    if (_socket?.connected != true || driverId.isEmpty) return;
    _socket!.emit('update_location', {
      'driverId': driverId,
      'latitude': latitude,
      'longitude': longitude,
      if (status != null && status.isNotEmpty) 'status': status,
    });
  }

  void joinUserRoom(String userId) {
    if (userId.isEmpty) return;

    void join() => _socket?.emit('join_user_room', {'userId': userId});

    if (_socket?.connected == true) {
      join();
      return;
    }

    _socket?.once('connect', (_) => join());
  }

  void leaveUserRoom() {
    if (_socket?.connected == true) {
      _socket!.emit('leave_user_room');
    }
  }

  void listenForNewNotifications(void Function() onNewNotification) {
    _socket?.off('new_notification');
    _socket?.on('new_notification', (_) => onNewNotification());
  }

  void disconnect() {
    leaveDriversRoom();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _onTripAvailable = null;
    _onTripUnavailable = null;
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }
}

String socketUrlFromApiBase(String apiBaseUrl) {
  final uri = Uri.parse(apiBaseUrl);
  final portPart = uri.hasPort ? ':${uri.port}' : '';
  return '${uri.scheme}://${uri.host}$portPart';
}

final tripSocketServiceProvider = Provider<TripSocketService>((ref) {
  final apiBase = dotenv.env['BASE_URL'] ?? '';
  final socketUrl = socketUrlFromApiBase(apiBase);
  final service = TripSocketService(socketUrl: socketUrl);
  ref.onDispose(service.disconnect);
  return service;
});
