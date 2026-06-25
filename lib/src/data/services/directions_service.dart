import 'dart:convert';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class DirectionsService {
  final http.Client _client;

  DirectionsService({http.Client? client}) : _client = client ?? http.Client();

  String get _apiKey =>
      dotenv.env['GOOGLE_PLACES_API_KEY'] ??
      dotenv.env['GOOGLE_MAPS_ANDROID_KEY'] ??
      dotenv.env['GOOGLE_MAPS_IOS_KEY'] ??
      '';

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
