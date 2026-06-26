import 'dart:async';

import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/models/trip_model.dart';
import 'package:driveforme_driver/src/data/utils/driver_map_location.dart';
import 'package:driveforme_driver/src/data/utils/trip_lifecycle.dart';
import 'package:driveforme_driver/src/data/utils/trip_screen_helpers.dart';
import 'package:driveforme_driver/src/interfaces/components/primarybutton.dart';
import 'package:driveforme_driver/src/interfaces/components/trip_map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _kPanelBg = Color(0xFFF5F6F8);
const _kMapTooltipBlue = Color(0xFF1A5288);
const _kChatGreen = Color(0xFF17A34A);
const _kCallBlue = Color(0xFF4A9FD4);
const _kStatValueBlue = Color(0xFF205D91);

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

  TripModel? _trip;
  Timer? _pollTimer;
  bool _navigatedAway = false;
  late final TripScreenService _tripService;

  String get _distance => _trip?.distanceLabel ?? '—';

  @override
  void initState() {
    super.initState();
    _tripService = ref.read(tripScreenServiceProvider);
    startDriverLocationTracking();
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
      expectedStatuses: const {'driver_assigned'},
    )) {
      _navigatedAway = true;
      return;
    }

    setState(() => _trip = trip);
  }

  void _goToOtp(TripModel trip) {
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
                  ),
                  _RouteTooltip(distance: _distance),
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
                    child: _BottomTripPanel(
                      trip: trip,
                      onArrived: () => _goToOtp(trip),
                      onCancel: _handleCancel,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _RouteTooltip extends StatelessWidget {
  const _RouteTooltip({required this.distance});

  final String distance;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: MediaQuery.sizeOf(context).width * 0.28,
      top: MediaQuery.sizeOf(context).height * 0.36,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _kMapTooltipBlue,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: kBlack.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: kOrange,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Heading to the pickup',
                  style: kCaption12R.copyWith(
                    color: kWhite.withValues(alpha: 0.9),
                    height: 1.1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Text(
                distance,
                style: kStyle(kSemiBold, kSize14, color: kWhite, height: 1.15),
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

class _BottomTripPanel extends StatelessWidget {
  const _BottomTripPanel({
    required this.trip,
    required this.onArrived,
    required this.onCancel,
  });

  final TripModel trip;
  final VoidCallback onArrived;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: _kPanelBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipPath(
            clipper: const _PanelWaveClipper(arcDepth: 14),
            child: const ColoredBox(
              color: kTripCtaBlue,
              child: SizedBox(height: 28, width: double.infinity),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PassengerInfoCard(trip: trip),
                const SizedBox(height: 14),
                _TripStatsRow(
                  distance: trip.distanceLabel,
                  duration: trip.durationLabel,
                ),
                const SizedBox(height: 20),
                primaryButton(
                  label: 'I have arrived',
                  buttonHeight: 52,
                  fontSize: kSize16,
                  buttonColor: kTripCtaBlue,
                  labelColor: kWhite,
                  onPressed: onArrived,
                ),
                const SizedBox(height: 10),
                Text(
                  'Tap when you reached the pickup location',
                  textAlign: TextAlign.center,
                  style: kCaption12R.copyWith(
                    color: kTripBodyMuted,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onCancel,
                  child: Text(
                    'Cancel trip',
                    style: kCaption14M.copyWith(color: kRed),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelWaveClipper extends CustomClipper<Path> {
  const _PanelWaveClipper({required this.arcDepth});

  final double arcDepth;

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    return Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(w / 2, arcDepth, w, 0)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
  }

  @override
  bool shouldReclip(covariant _PanelWaveClipper oldClipper) =>
      oldClipper.arcDepth != arcDepth;
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

class _TripStatsRow extends StatelessWidget {
  const _TripStatsRow({required this.distance, required this.duration});

  final String distance;
  final String duration;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
          Expanded(
            child: _TripStatItem(label: 'DISTANCE', value: distance),
          ),
          Expanded(
            child: _TripStatItem(label: 'DURATION', value: duration),
          ),
          const Expanded(
            child: _TripStatItem(label: 'STATUS', value: 'En route'),
          ),
        ],
      ),
    );
  }
}

class _TripStatItem extends StatelessWidget {
  const _TripStatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: kCaption11R.copyWith(
            color: kTripMutedLabel,
            letterSpacing: 0.4,
            fontWeight: kMedium,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          textAlign: TextAlign.center,
          style: kStyle(
            kSemiBold,
            kSize16,
            color: _kStatValueBlue,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}
