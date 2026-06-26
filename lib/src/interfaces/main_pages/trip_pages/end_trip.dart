import 'dart:async';

import 'package:driveforme_driver/src/data/apis/trip_api.dart';
import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/providers/active_trip_provider.dart';
import 'package:driveforme_driver/src/data/providers/loading_provider.dart';
import 'package:driveforme_driver/src/data/services/navigation_services.dart';
import 'package:driveforme_driver/src/data/models/trip_model.dart';
import 'package:driveforme_driver/src/data/utils/driver_map_location.dart';
import 'package:driveforme_driver/src/data/utils/trip_navigation.dart';
import 'package:driveforme_driver/src/data/utils/trip_screen_helpers.dart';
import 'package:driveforme_driver/src/data/providers/wallet_provider.dart';
import 'package:driveforme_driver/src/interfaces/components/primarybutton.dart';
import 'package:driveforme_driver/src/interfaces/components/trip_map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _kPanelBg = Color(0xFFF5F6F8);
const _kMapTooltipBlue = Color(0xFF1A5288);
const _kStatValueBlue = Color(0xFF205D91);
const _kTripStatusCardBg = Color(0xFF1C1C1E);
const _kEarningsOrange = Color(0xFFC6934B);

class EndTripScreen extends ConsumerStatefulWidget {
  const EndTripScreen({
    super.key,
    this.tripMongoId = '',
  });

  final String tripMongoId;

  @override
  ConsumerState<EndTripScreen> createState() => _EndTripScreenState();
}

class _EndTripScreenState extends ConsumerState<EndTripScreen>
    with DriverMapLocationMixin {
  static const _pollInterval = Duration(seconds: 4);

  Timer? _timer;
  Timer? _pollTimer;
  TripModel? _trip;
  Duration _elapsed = Duration.zero;
  bool _navigatedAway = false;
  late final TripScreenService _tripService;

  @override
  void initState() {
    super.initState();
    _tripService = ref.read(tripScreenServiceProvider);
    startDriverLocationTracking();
    _loadTrip();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsed = _elapsedFromTrip());
    });
    _startPolling();
  }

  Duration _elapsedFromTrip() {
    final started = _trip?.startedAt;
    if (started == null) return Duration.zero;
    final diff = DateTime.now().difference(started);
    return diff.isNegative ? Duration.zero : diff;
  }

  Future<void> _loadTrip() async {
    final trip = await _tripService.fetchAndCacheTrip(widget.tripMongoId);
    if (!mounted || trip == null) return;
    setState(() {
      _trip = trip;
      _elapsed = _elapsedFromTrip();
    });
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
      expectedStatuses: const {'in_progress'},
    )) {
      _navigatedAway = true;
      return;
    }

    setState(() {
      _trip = trip;
      _elapsed = _elapsedFromTrip();
    });
  }

  Future<void> _completeTrip() async {
    if (widget.tripMongoId.isEmpty) return;

    ref.read(loadingProvider.notifier).startLoading();
    final response =
        await ref.read(tripApiProvider).completeTrip(widget.tripMongoId);
    ref.read(loadingProvider.notifier).stopLoading();

    if (!mounted) return;

    if (!response.success || response.data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? 'Failed to complete trip.')),
      );
      return;
    }

    final trip = response.data!;
    ref.invalidate(walletProvider);
    await ref.read(activeTripProvider.notifier).setActiveTrip(trip.id, trip: trip);

    final target = tripNavigationTarget(trip);
    if (target == null) return;

    _navigatedAway = true;
    NavigationService().pushNamedAndRemoveUntil(
      target.route,
      arguments: target.arguments,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pollTimer?.cancel();
    stopDriverLocationTracking();
    super.dispose();
  }

  String get _formattedTimer {
    final h = _elapsed.inHours.toString().padLeft(2, '0');
    final m = (_elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final trip = _trip;
    final topPadding = MediaQuery.paddingOf(context).top;
    final headingTo = trip?.dropoffAddress ?? trip?.pickupAddress ?? '—';
    final distance = trip?.distanceLabel ?? '—';
    final price = trip?.displayPrice ?? '—';
    final navigationTarget =
        trip?.dropoffLocation ?? trip?.pickupLocation;

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
              mode: TripMapMode.toDropoff,
            ),
            _RouteInfoBubble(headingTo: headingTo, distance: distance),
            Positioned(
              right: 16,
              top: topPadding + 60,
              child: MapNavigateButton(target: navigationTarget),
            ),
            Positioned(
              top: topPadding + 8,
              left: 16,
              child: _MapBackButton(onTap: () => Navigator.maybePop(context)),
            ),
            Positioned(
              top: topPadding + 60,
              left: 16,
              child: _TripStatusCard(timerText: _formattedTimer),
            ),
            Positioned(
              top: topPadding + 60,
              right: 16,
              child: _EarningsCard(price: price),
            ),
            Positioned(
              right: 16,
              bottom: MediaQuery.sizeOf(context).height * 0.42,
              child: _SosButton(
                tripMongoId: widget.tripMongoId,
                locationLabel: headingTo,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _EndTripBottomPanel(
                dropoff: headingTo,
                distance: distance,
                onEndTrip: _completeTrip,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteInfoBubble extends StatelessWidget {
  const _RouteInfoBubble({required this.headingTo, required this.distance});

  final String headingTo;
  final String distance;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: MediaQuery.sizeOf(context).width * 0.22,
      top: MediaQuery.sizeOf(context).height * 0.4,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _kMapTooltipBlue,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: kBlack.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
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
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '$headingTo, $distance remaining',
                style: kCaption13R.copyWith(
                  color: kWhite,
                  fontWeight: kMedium,
                  height: 1.2,
                ),
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

class _TripStatusCard extends StatelessWidget {
  const _TripStatusCard({required this.timerText});

  final String timerText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _kTripStatusCardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'TRIP IN PROGRESS',
            style: kCaption11R.copyWith(
              color: _kEarningsOrange,
              letterSpacing: 0.6,
              fontWeight: kSemiBold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            timerText,
            style: kStyle(kSemiBold, kSize22, color: kWhite, height: 1.05),
          ),
        ],
      ),
    );
  }
}

class _EarningsCard extends StatelessWidget {
  const _EarningsCard({required this.price});

  final String price;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kEarningsOrange.withValues(alpha: 0.85)),
        boxShadow: [
          BoxShadow(
            color: kBlack.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(price, style: kDriverFoundPriceSB.copyWith(fontSize: kSize20)),
          const SizedBox(height: 2),
          Text(
            'earned so far',
            style: kCaption11R.copyWith(
              color: _kEarningsOrange,
              fontWeight: kMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _SosButton extends StatelessWidget {
  const _SosButton({
    required this.tripMongoId,
    required this.locationLabel,
  });

  final String tripMongoId;
  final String locationLabel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          'sos_select',
          arguments: {
            'locationLabel': locationLabel,
            'tripId': tripMongoId,
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kSosRed.withValues(alpha: 0.85)),
          boxShadow: [
            BoxShadow(
              color: kBlack.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'SOS',
              style: kStyle(kBold, kSize16, color: kSosRed, height: 1.1),
            ),
            Text(
              'Emergency',
              style: kCaption11R.copyWith(color: kSosRed, fontWeight: kMedium),
            ),
          ],
        ),
      ),
    );
  }
}

class _EndTripBottomPanel extends StatelessWidget {
  const _EndTripBottomPanel({
    required this.dropoff,
    required this.distance,
    required this.onEndTrip,
  });

  final String dropoff;
  final String distance;
  final VoidCallback onEndTrip;

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
                _DestinationTripCard(dropoff: dropoff, distance: distance),
                const SizedBox(height: 20),
                primaryButton(
                  label: 'End Trip',
                  buttonHeight: 52,
                  fontSize: kSize16,
                  buttonColor: kTripCtaBlue,
                  labelColor: kWhite,
                  onPressed: onEndTrip,
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

class _DestinationTripCard extends StatelessWidget {
  const _DestinationTripCard({
    required this.dropoff,
    required this.distance,
  });

  final String dropoff;
  final String distance;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: kTripCtaBlue.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on,
                  color: kDropBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dropoff, style: kTripSubSectionSB),
                    const SizedBox(height: 2),
                    Text(
                      'Destination',
                      style: kTripLocationLabelR.copyWith(
                        color: kTripBodyMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _TripStatItem(label: 'REMAINING', value: distance),
              ),
              const Expanded(
                child: _TripStatItem(label: 'STATUS', value: 'On trip'),
              ),
            ],
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
