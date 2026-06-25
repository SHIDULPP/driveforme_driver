import 'dart:async';

import 'package:driveforme_driver/src/data/models/trip_location_model.dart';
import 'package:driveforme_driver/src/data/services/driver_location_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

mixin DriverMapLocationMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  TripLocation? _driverMapLocation;
  Timer? _driverLocationTimer;

  TripLocation? get driverMapLocation => _driverMapLocation;

  void startDriverLocationTracking({
    Duration interval = const Duration(seconds: 10),
  }) {
    _refreshDriverMapLocation();
    _driverLocationTimer?.cancel();
    _driverLocationTimer = Timer.periodic(
      interval,
      (_) => _refreshDriverMapLocation(),
    );
  }

  void stopDriverLocationTracking() {
    _driverLocationTimer?.cancel();
    _driverLocationTimer = null;
  }

  Future<void> _refreshDriverMapLocation() async {
    final position = await ref
        .read(driverLocationServiceProvider)
        .getCurrentPosition();
    if (!mounted || position == null) return;

    setState(() {
      _driverMapLocation = TripLocation.fromPosition(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    });
  }
}
