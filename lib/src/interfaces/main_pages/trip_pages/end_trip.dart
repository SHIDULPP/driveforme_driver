import 'dart:async';

import 'package:driveforme_driver/src/data/apis/trip_api.dart';
import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/providers/active_trip_provider.dart';
import 'package:driveforme_driver/src/data/providers/loading_provider.dart';
import 'package:driveforme_driver/src/data/services/navigation_services.dart';
import 'package:driveforme_driver/src/data/models/route_summary_model.dart';
import 'package:driveforme_driver/src/data/models/trip_model.dart';
import 'package:driveforme_driver/src/data/utils/driver_map_location.dart';
import 'package:driveforme_driver/src/data/utils/trip_navigation.dart';
import 'package:driveforme_driver/src/data/utils/trip_screen_helpers.dart';
import 'package:driveforme_driver/src/data/providers/wallet_provider.dart';
import 'package:driveforme_driver/src/interfaces/components/driver_navigation_sheet.dart';
import 'package:driveforme_driver/src/interfaces/components/trip_map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  RouteSummary? _routeSummary;
  late final TripScreenService _tripService;

  String get _distanceLabel =>
      _routeSummary?.distanceLabel ?? _trip?.distanceLabel ?? '—';

  String get _etaLabel =>
      _routeSummary?.durationLabel ?? _trip?.durationLabel ?? '—';

  @override
  void initState() {
    super.initState();
    _tripService = ref.read(tripScreenServiceProvider);
    startDriverLocationTracking(interval: const Duration(seconds: 4));
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

  void _onRouteSummary(RouteSummary? summary) {
    if (!mounted || summary == null) return;
    setState(() => _routeSummary = summary);
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
    final price = trip?.displayPrice ?? '—';
    final navigationTarget = trip?.dropoffLocation ?? trip?.pickupLocation;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

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
                    followDriver: true,
                    onRouteSummary: _onRouteSummary,
                  ),
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
                    top: topPadding + 8,
                    right: 16,
                    child: _EarningsCard(price: price),
                  ),
                  Positioned(
                    right: 16,
                    bottom: 200 + bottomInset,
                    child: _SosButton(
                      tripMongoId: widget.tripMongoId,
                      locationLabel: headingTo,
                    ),
                  ),
                  Positioned(
                    right: 20,
                    bottom: 130 + bottomInset,
                    child: FloatingActionButton.extended(
                      onPressed: _completeTrip,
                      backgroundColor: kTripCtaBlue,
                      elevation: 4,
                      icon: const Icon(Icons.flag_rounded, color: kWhite),
                      label: Text(
                        'End Trip',
                        style: kCaption14M.copyWith(
                          color: kWhite,
                          fontWeight: kSemiBold,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: DriverNavigationSheet(
                      title: 'Navigate to destination',
                      subtitle: headingTo,
                      distanceLabel: _distanceLabel,
                      etaLabel: _etaLabel,
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
