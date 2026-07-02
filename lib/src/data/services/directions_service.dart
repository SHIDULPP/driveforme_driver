import 'dart:convert';
import 'dart:developer';

import 'package:driveforme_driver/src/data/models/route_summary_model.dart';
import 'package:driveforme_driver/src/data/models/trip_location_model.dart';
import 'package:driveforme_driver/src/data/services/location_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class DirectionsService {
  final http.Client _client;
  final LocationService _locationService;

  DirectionsService({
    http.Client? client,
    LocationService? locationService,
  })  : _client = client ?? http.Client(),
        _locationService = locationService ?? const LocationService();

  String get _apiKey =>
      dotenv.env['GOOGLE_PLACES_API_KEY'] ??
      dotenv.env['GOOGLE_MAPS_ANDROID_KEY'] ??
      dotenv.env['GOOGLE_MAPS_IOS_KEY'] ??
      '';

  Future<RouteSummary?> routeSummaryBetween({
    required TripLocation origin,
    required TripLocation destination,
  }) async {
    final from = await _locationService.resolveLocation(origin);
    final to = await _locationService.resolveLocation(destination);
    final fromPoint = from.latLng;
    final toPoint = to.latLng;
    if (fromPoint == null || toPoint == null) return null;

    if (_apiKey.isEmpty) return null;

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/directions/json',
      {
        'origin': '${fromPoint.latitude},${fromPoint.longitude}',
        'destination': '${toPoint.latitude},${toPoint.longitude}',
        'mode': 'driving',
        'key': _apiKey,
      },
    );

    try {
      final response = await _client.get(uri);
      if (response.statusCode != 200) return null;

      final body = json.decode(response.body);
      if (body is! Map<String, dynamic> || body['status'] != 'OK') {
        log('Directions API: ${body is Map ? body['status'] : 'invalid'}',
            name: 'DirectionsService');
        return null;
      }

      final routes = body['routes'];
      if (routes is! List || routes.isEmpty) return null;

      final route = routes.first;
      if (route is! Map) return null;

      final legs = route['legs'];
      if (legs is! List || legs.isEmpty) return null;

      final leg = legs.first;
      if (leg is! Map) return null;

      final distance = leg['distance'];
      final duration = leg['duration'];
      final distanceMeters =
          distance is Map ? (distance['value'] as num?)?.toDouble() : null;
      final durationSeconds =
          duration is Map ? (duration['value'] as num?)?.toInt() : null;

      if (distanceMeters == null || durationSeconds == null) return null;

      final durationMinutes = (durationSeconds / 60).ceil().clamp(1, 10080);

      return RouteSummary(
        distanceKm: double.parse((distanceMeters / 1000).toStringAsFixed(1)),
        durationMinutes: durationMinutes,
        durationLabel: _formatDuration(durationMinutes),
      );
    } catch (e) {
      log('Directions request failed: $e', name: 'DirectionsService');
      return null;
    }
  }

  Future<List<LatLng>> routeBetween(LatLng origin, LatLng destination) async {
    if (_apiKey.isEmpty) return const [];

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/directions/json',
      {
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'mode': 'driving',
        'key': _apiKey,
      },
    );

    try {
      final response = await _client.get(uri);
      if (response.statusCode != 200) return const [];

      final body = json.decode(response.body);
      if (body is! Map<String, dynamic> || body['status'] != 'OK') {
        log('Directions API: ${body is Map ? body['status'] : 'invalid'}',
            name: 'DirectionsService');
        return const [];
      }

      final routes = body['routes'];
      if (routes is! List || routes.isEmpty) return const [];

      final route = routes.first;
      if (route is! Map) return const [];

      final overviewPolyline = route['overview_polyline'];
      if (overviewPolyline is! Map) return const [];

      final encoded = overviewPolyline['points']?.toString() ?? '';
      if (encoded.isEmpty) return const [];

      return decodePolyline(encoded);
    } catch (e) {
      log('Directions request failed: $e', name: 'DirectionsService');
      return const [];
    }
  }

  static String _formatDuration(int minutes) {
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final remaining = minutes % 60;
    if (remaining == 0) return hours == 1 ? '1 hr' : '$hours hrs';
    return '$hours hr $remaining min';
  }

  static List<LatLng> decodePolyline(String encoded) {
    final points = <LatLng>[];
    var index = 0;
    var lat = 0;
    var lng = 0;

    while (index < encoded.length) {
      var shift = 0;
      var result = 0;
      int byte;

      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);

      final deltaLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += deltaLat;

      shift = 0;
      result = 0;

      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);

      final deltaLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += deltaLng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }

  void dispose() => _client.close();
}
