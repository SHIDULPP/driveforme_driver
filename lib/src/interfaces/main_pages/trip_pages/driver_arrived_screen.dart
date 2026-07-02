import 'dart:async';

import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/models/route_summary_model.dart';
import 'package:driveforme_driver/src/data/models/trip_model.dart';
import 'package:driveforme_driver/src/data/utils/driver_map_location.dart';
import 'package:driveforme_driver/src/data/utils/pickup_proximity.dart';
import 'package:driveforme_driver/src/data/utils/trip_lifecycle.dart';
import 'package:driveforme_driver/src/data/utils/trip_navigation.dart';
import 'package:driveforme_driver/src/data/utils/trip_screen_helpers.dart';
import 'package:driveforme_driver/src/interfaces/components/driver_navigation_sheet.dart';
import 'package:driveforme_driver/src/interfaces/components/primarybutton.dart';
import 'package:driveforme_driver/src/interfaces/components/trip_map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _kChatGreen = Color(0xFF17A34A);
const _kCallBlue = Color(0xFF4A9FD4);

class DriverArrivedScreen extends ConsumerStatefulWidget {
  const DriverArrivedScreen({
    super.key,
    this.tripMongoId = '',
  });

  final String tripMongoId;

  @override
  ConsumerState<DriverArrivedScreen> createState() =>
      _DriverArrivedScreenState();
}

class _DriverArrivedScreenState extends ConsumerState<DriverArrivedScreen>
    with DriverMapLocationMixin {
  static const _pollInterval = Duration(seconds: 4);
  static const _locationInterval = Duration(seconds: 4);

  TripModel? _trip;
  Timer? _pollTimer;
  bool _navigatedAway = false;
  late final TripScreenService _tripService;
  RouteSummary? _routeSummary;

  String get _distanceLabel =>
      _routeSummary?.distanceLabel ?? _trip?.distanceLabel ?? '—';

  String get _etaLabel =>
      _routeSummary?.durationLabel ?? _trip?.durationLabel ?? '—';

  bool get _canArrive {
    final trip = _trip;
    if (trip == null) return false;
    return isWithinPickupRadius(
      driver: driverMapLocation?.latLng,
      pickup: trip.pickupLocation.latLng,
    );
  }

  @override
  void initState() {
    super.initState();
    _tripService = ref.read(tripScreenServiceProvider);
    startDriverLocationTracking(interval: _locationInterval);
    _loadTrip();
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    stopDriverLocationTracking();
    super.dispose();
  }

  Future<void> _loadTrip() async {
    final trip = await _tripService.fetchAndCacheTrip(widget.tripMongoId);
    if (!mounted || trip == null) return;
    setState(() => _trip = trip);
  }

  void _startPolling() {
    if (widget.tripMongoId.isEmpty) return;
    _pollTripStatus();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _pollTripStatus());
  }

  Future<void> _pollTripStatus() async {
    if (_navigatedAway || !mounted || widget.tripMongoId.isEmpty) return;

    final trip = await _tripService.fetchAndCacheTrip(widget.tripMongoId);
    if (!mounted || _navigatedAway || trip == null) return;

    if (navigateIfTripLeftExpectedStatus(
      trip: trip,
      expectedStatuses: pickupStageStatuses,
    )) {
      _navigatedAway = true;
      return;
    }

    setState(() => _trip = trip);
  }

  void _onRouteSummary(RouteSummary? summary) {
    if (!mounted || summary == null) return;
    setState(() => _routeSummary = summary);
  }

  void _goToOtp(TripModel trip) {
    if (!_canArrive) return;
    _navigatedAway = true;
    _pollTimer?.cancel();
    Navigator.pushNamed(
      context,
      'tripOtp',
      arguments: trip.toOtpArguments(),
    );
  }

  Future<void> _handleCancel() async {
    _pollTimer?.cancel();
    _navigatedAway = true;

    final trip = await cancelTripWithDialog(
      context: context,
      ref: ref,
      tripMongoId: widget.tripMongoId,
    );
    if (!mounted) return;

    if (trip == null) {
      _navigatedAway = false;
      _startPolling();
      return;
    }

    navigateToHomeAfterActiveTripEnds();
  }

  @override
  Widget build(BuildContext context) {
    final trip = _trip;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: kWhite,
        body: trip == null
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                fit: StackFit.expand,
                children: [
                  TripMapView(
                    pickup: trip.pickupLocation,
                    dropoff: trip.dropoffLocation,
                    driverLocation: driverMapLocation,
                    mode: TripMapMode.toPickup,
                    followDriver: true,
                    onRouteSummary: _onRouteSummary,
                  ),
                  Positioned(
                    right: 16,
                    top: MediaQuery.paddingOf(context).top + 60,
                    child: MapNavigateButton(target: trip.pickupLocation),
                  ),
                  Positioned(
                    top: MediaQuery.paddingOf(context).top + 8,
                    left: 16,
                    child: _MapBackButton(
                      onTap: () => Navigator.maybePop(context),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: DriverNavigationSheet(
                      title: 'Navigate to pickup',
                      subtitle: trip.pickupAddress,
                      distanceLabel: _distanceLabel,
                      etaLabel: _etaLabel,
                      footer: Column(
                        children: [
                          primaryButton(
                            label: 'I have arrived',
                            buttonHeight: 52,
                            fontSize: kSize16,
                            buttonColor: kTripCtaBlue,
                            labelColor: kWhite,
                            onPressed:
                                _canArrive ? () => _goToOtp(trip) : null,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _canArrive
                                ? 'Tap when you reached the pickup location'
                                : 'Approach pickup to unlock',
                            textAlign: TextAlign.center,
                            style: kCaption12R.copyWith(
                              color: kTripBodyMuted,
                              height: 1.35,
                            ),
                          ),
                          TextButton(
                            onPressed: _handleCancel,
                            child: Text(
                              'Cancel trip',
                              style: kCaption14M.copyWith(color: kRed),
                            ),
                          ),
                        ],
                      ),
                      child: _PassengerInfoCard(trip: trip),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _MapBackButton extends StatelessWidget {
  const _MapBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          color: kWhite,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: kBlack.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: kTextColor,
        ),
      ),
    );
  }
}

class _PassengerInfoCard extends StatelessWidget {
  const _PassengerInfoCard({required this.trip});

  final TripModel trip;

  @override
  Widget build(BuildContext context) {
    final vehicleLine = trip.vehicleNumber.isNotEmpty
        ? trip.vehicleNumber
        : (trip.vehicleName.isNotEmpty ? trip.vehicleName : '');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kBlack.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/pngs/person1.png',
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trip.customerDisplayName, style: kTripSubSectionSB),
                const SizedBox(height: 4),
                Text(
                  trip.pickupAddress,
                  style: kTripLocationLabelR.copyWith(
                    color: kTripBodyMuted,
                    fontSize: kSize13,
                  ),
                ),
                if (vehicleLine.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    vehicleLine,
                    style: kTripLocationLabelR.copyWith(
                      color: kTripBodyMuted,
                      fontSize: kSize13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          _ContactActionButton(
            color: _kChatGreen,
            icon: Icons.chat_bubble_outline_rounded,
            onTap: () => openChatScreen(
              receiverId: trip.customerId,
              receiverName: trip.customerDisplayName,
              tripId: trip.id,
            ),
          ),
          const SizedBox(width: 10),
          _ContactActionButton(
            color: _kCallBlue,
            icon: Icons.phone_rounded,
            onTap: () => launchPhoneCall(trip.customerPhone),
          ),
        ],
      ),
    );
  }
}

class _ContactActionButton extends StatelessWidget {
  const _ContactActionButton({
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: kWhite, size: 22),
      ),
    );
  }
}
