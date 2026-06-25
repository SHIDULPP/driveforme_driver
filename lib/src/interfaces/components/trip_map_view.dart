import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/models/trip_location_model.dart';
import 'package:driveforme_driver/src/data/services/directions_service.dart';
import 'package:driveforme_driver/src/data/services/location_service.dart';
import 'package:driveforme_driver/src/data/utils/map_navigation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum TripMapMode {
  /// Route from driver → pickup.
  toPickup,

  /// Route from driver → dropoff, or pickup → dropoff if driver unavailable.
  toDropoff,

  /// Route from pickup → dropoff.
  fullRoute,
}

class TripMapView extends StatefulWidget {
  final TripLocation? pickup;
  final TripLocation? dropoff;
  final TripLocation? driverLocation;
  final TripMapMode mode;
  final bool showDropoff;
  final bool showRoute;

  const TripMapView({
    super.key,
    this.pickup,
    this.dropoff,
    this.driverLocation,
    this.mode = TripMapMode.toPickup,
    this.showDropoff = true,
    this.showRoute = true,
  });

  TripLocation? get navigationTarget {
    switch (mode) {
      case TripMapMode.toPickup:
        return pickup;
      case TripMapMode.toDropoff:
        return dropoff ?? pickup;
      case TripMapMode.fullRoute:
        return dropoff ?? pickup;
    }
  }

  @override
  State<TripMapView> createState() => _TripMapViewState();
}

class _TripMapViewState extends State<TripMapView> {
  static const _locationService = LocationService();
  final DirectionsService _directionsService = DirectionsService();

  GoogleMapController? _mapController;
  TripLocation? _resolvedPickup;
  TripLocation? _resolvedDropoff;
  TripLocation? _resolvedDriver;
  List<LatLng> _routePoints = const [];
  bool _isResolving = true;
  int _resolveGeneration = 0;

  @override
  void initState() {
    super.initState();
    _resolveMapData();
  }

  @override
  void didUpdateWidget(covariant TripMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pickup != widget.pickup ||
        oldWidget.dropoff != widget.dropoff ||
        oldWidget.driverLocation != widget.driverLocation ||
        oldWidget.mode != widget.mode ||
        oldWidget.showDropoff != widget.showDropoff ||
        oldWidget.showRoute != widget.showRoute) {
      _resolveMapData();
    }
  }

  Future<void> _resolveMapData() async {
    final generation = ++_resolveGeneration;

    if (mounted) {
      setState(() => _isResolving = true);
    }

    final pickup = widget.pickup ?? const TripLocation.empty();
    final dropoff = widget.dropoff;
    final driver = widget.driverLocation;

    final resolvedPickup = await _locationService.resolveLocation(pickup);
    TripLocation? resolvedDropoff;
    if (widget.showDropoff && dropoff != null) {
      resolvedDropoff = await _locationService.resolveLocation(dropoff);
    }

    TripLocation? resolvedDriver;
    if (driver != null) {
      resolvedDriver = await _locationService.resolveLocation(driver);
    }

    final routePoints = widget.showRoute
        ? await _resolveRoute(
            resolvedPickup: resolvedPickup,
            resolvedDropoff: resolvedDropoff,
            resolvedDriver: resolvedDriver,
          )
        : <LatLng>[];

    if (!mounted || generation != _resolveGeneration) return;

    setState(() {
      _resolvedPickup = resolvedPickup;
      _resolvedDropoff = resolvedDropoff;
      _resolvedDriver = resolvedDriver;
      _routePoints = routePoints;
      _isResolving = false;
    });

    _fitCamera();
  }

  Future<List<LatLng>> _resolveRoute({
    required TripLocation resolvedPickup,
    required TripLocation? resolvedDropoff,
    required TripLocation? resolvedDriver,
  }) async {
    final driver = resolvedDriver?.latLng;
    final pickup = resolvedPickup.latLng;
    final dropoff = resolvedDropoff?.latLng;

    switch (widget.mode) {
      case TripMapMode.toPickup:
        if (driver != null && pickup != null) {
          return _directionsService.routeBetween(driver, pickup);
        }
        return const [];
      case TripMapMode.toDropoff:
        if (driver != null && dropoff != null) {
          return _directionsService.routeBetween(driver, dropoff);
        }
        if (pickup != null && dropoff != null) {
          return _directionsService.routeBetween(pickup, dropoff);
        }
        return const [];
      case TripMapMode.fullRoute:
        if (pickup != null &&
            dropoff != null &&
            (pickup.latitude != dropoff.latitude ||
                pickup.longitude != dropoff.longitude)) {
          return _directionsService.routeBetween(pickup, dropoff);
        }
        return const [];
    }
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};
    final pickup = _resolvedPickup?.latLng;
    if (pickup != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: pickup,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );
    }

    final dropoff = _resolvedDropoff?.latLng;
    if (dropoff != null &&
        widget.showDropoff &&
        (pickup == null ||
            pickup.latitude != dropoff.latitude ||
            pickup.longitude != dropoff.longitude)) {
      markers.add(
        Marker(
          markerId: const MarkerId('dropoff'),
          position: dropoff,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    final driver = _resolvedDriver?.latLng;
    if (driver != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: driver,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );
    }

    return markers;
  }

  Set<Polyline> _buildPolylines() {
    if (_routePoints.length < 2) return const {};

    return {
      Polyline(
        polylineId: const PolylineId('trip_route'),
        points: _routePoints,
        color: const Color(0xFF165A91),
        width: 5,
      ),
    };
  }

  LatLng _initialTarget() {
    return _resolvedDriver?.latLng ??
        _resolvedPickup?.latLng ??
        _resolvedDropoff?.latLng ??
        kDefaultMapCenter;
  }

  void _fitCamera() {
    if (!mounted || _mapController == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final controller = _mapController;
      if (controller == null) return;

      final points = <LatLng>[
        if (_resolvedPickup?.latLng != null) _resolvedPickup!.latLng!,
        if (_resolvedDropoff?.latLng != null) _resolvedDropoff!.latLng!,
        if (_resolvedDriver?.latLng != null) _resolvedDriver!.latLng!,
        ..._routePoints,
      ];

      try {
        if (points.isEmpty) {
          controller.animateCamera(
            CameraUpdate.newLatLngZoom(kDefaultMapCenter, 12),
          );
          return;
        }

        if (points.length == 1) {
          controller.animateCamera(
            CameraUpdate.newLatLngZoom(points.first, 14),
          );
          return;
        }

        var bounds = LatLngBounds(
          southwest: points.first,
          northeast: points.first,
        );
        for (final point in points.skip(1)) {
          bounds = _expandBounds(bounds, point);
        }

        controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 56));
      } catch (_) {
        // Map was disposed before the camera animation ran.
      }
    });
  }

  LatLngBounds _expandBounds(LatLngBounds bounds, LatLng point) {
    return LatLngBounds(
      southwest: LatLng(
        point.latitude < bounds.southwest.latitude
            ? point.latitude
            : bounds.southwest.latitude,
        point.longitude < bounds.southwest.longitude
            ? point.longitude
            : bounds.southwest.longitude,
      ),
      northeast: LatLng(
        point.latitude > bounds.northeast.latitude
            ? point.latitude
            : bounds.northeast.latitude,
        point.longitude > bounds.northeast.longitude
            ? point.longitude
            : bounds.northeast.longitude,
      ),
    );
  }

  @override
  void dispose() {
    _resolveGeneration++;
    _mapController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _initialTarget(),
            zoom: 14,
          ),
          markers: _buildMarkers(),
          polylines: _buildPolylines(),
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
          rotateGesturesEnabled: false,
          onMapCreated: (controller) {
            _mapController = controller;
            _fitCamera();
          },
        ),
        if (_isResolving)
          const ColoredBox(
            color: kSearchFieldBg,
            child: Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ),
          ),
      ],
    );
  }
}

class MapNavigateButton extends StatelessWidget {
  const MapNavigateButton({
    super.key,
    required this.target,
    this.resolvedTarget,
  });

  final TripLocation? target;
  final TripLocation? resolvedTarget;

  @override
  Widget build(BuildContext context) {
    final location = resolvedTarget ?? target;
    if (location == null || !location.hasCoordinates) {
      return const SizedBox.shrink();
    }

    return Material(
      color: kWhite,
      elevation: 3,
      shadowColor: kBlack.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: () => launchMapNavigation(location),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.navigation_rounded, size: 18, color: kBrandBlue),
              const SizedBox(width: 6),
              Text(
                'Navigate',
                style: TextStyle(
                  color: kBrandBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
