import 'package:driveforme_driver/src/data/models/trip_location_model.dart';
import 'package:driveforme_driver/src/data/services/location_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentLocationProvider = FutureProvider<TripLocation?>((ref) async {
  const service = LocationService();
  return service.getCurrentLocation();
});
