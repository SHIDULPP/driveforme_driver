import 'dart:async';

import 'package:driveforme_driver/src/data/apis/trip_api.dart';
import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/models/trip_model.dart';
import 'package:driveforme_driver/src/data/providers/loading_provider.dart';
import 'package:driveforme_driver/src/data/providers/trip_provider.dart';
import 'package:driveforme_driver/src/data/utils/driver_map_location.dart';
import 'package:driveforme_driver/src/data/utils/trip_lifecycle.dart';
import 'package:driveforme_driver/src/data/services/navigation_services.dart';
import 'package:driveforme_driver/src/interfaces/components/trip_map_view.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/trip_pages/trip_route_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _kHeaderBlue = Color(0xFF1A5288);
const _kDeclineRed = Color(0xFFE32626);
const _kChatGreen = Color(0xFF17A34A);
const _kCallBlue = Color(0xFF4A9FD4);
const _kTripTypeBadgeBg = Color(0xFFF3F4EE);

class TripRequestDetailsPage extends ConsumerStatefulWidget {
  const TripRequestDetailsPage({super.key, required this.trip});

  final TripModel trip;

  @override
  ConsumerState<TripRequestDetailsPage> createState() =>
      _TripRequestDetailsPageState();
}

class _TripRequestDetailsPageState extends ConsumerState<TripRequestDetailsPage>
    with DriverMapLocationMixin {
  late TripModel _trip;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
    startDriverLocationTracking();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_trip.isExpired) {
        _handleDecline();
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    stopDriverLocationTracking();
    super.dispose();
  }

  Future<void> _handleAccept() async {
    ref.read(loadingProvider.notifier).startLoading();
    final response = await ref.read(tripApiProvider).acceptTrip(_trip.id);
    ref.read(loadingProvider.notifier).stopLoading();

    if (!mounted) return;

    if (!response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? 'Failed to accept trip.')),
      );
      return;
    }

    ref.read(availableTripsProvider.notifier).removeTrip(_trip.id);
    final acceptedTrip = response.data ?? _trip;
    NavigationService().pop();
    await navigateToActiveTrip(ref, acceptedTrip);
  }

  void _handleDecline() {
    dismissTripRequest(ref, _trip.id);
    if (mounted) NavigationService().pop();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: kScreenBg,
        body: Stack(
          fit: StackFit.expand,
          children: [
            TripMapView(
              pickup: _trip.pickupLocation,
              dropoff: _trip.dropoffLocation,
              driverLocation: driverMapLocation,
              mode: TripMapMode.toPickup,
            ),
            Positioned(
              right: 16,
              bottom: MediaQuery.sizeOf(context).height * 0.42,
              child: MapNavigateButton(target: _trip.pickupLocation),
            ),
            Column(
              children: [
                SizedBox(height: topPadding + 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _CircleIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => NavigationService().pop(),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: kWhite,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: kBlack.withValues(alpha: 0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          _trip.displayEarnings,
                          style: kStyle(
                            kSemiBold,
                            kSize16,
                            color: kBrandBlue,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                const Spacer(),
                _RequestSheet(
                  trip: _trip,
                  onAccept: _handleAccept,
                  onDecline: _handleDecline,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestSheet extends StatelessWidget {
  const _RequestSheet({
    required this.trip,
    required this.onAccept,
    required this.onDecline,
  });

  final TripModel trip;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              color: _kHeaderBlue,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Text(
              'New Request ${trip.countdownLabel} min',
              textAlign: TextAlign.center,
              style: kStyle(kSemiBold, kSize15, color: kWhite),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding + 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/pngs/live_photo_image.png',
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
                          Text(trip.customerDisplayName, style: kCaption14B),
                          const SizedBox(height: 2),
                          Text(
                            '${trip.distanceLabel} away • ${trip.durationLabel}',
                            style: kCaption12R.copyWith(color: kMutedText),
                          ),
                          if (trip.vehicleNumber.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              trip.vehicleNumber,
                              style: kCaption12R.copyWith(color: kMutedText),
                            ),
                          ],
                        ],
                      ),
                    ),
                    _ContactButton(
                      icon: Icons.chat_bubble_outline_rounded,
                      color: _kChatGreen,
                      onTap: () => openChatScreen(
                        receiverId: trip.customerId,
                        receiverName: trip.customerDisplayName,
                        tripId: trip.id,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _ContactButton(
                      icon: Icons.call_rounded,
                      color: _kCallBlue,
                      onTap: () => launchPhoneCall(trip.customerPhone),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kCardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _kTripTypeBadgeBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          trip.tripTypeBadgeLabel,
                          style: kCaption12R.copyWith(
                            color: kSecondaryTextColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TripRoutePreview(
                              pickup: trip.pickupAddress,
                              dropoff: trip.dropoffAddress ?? trip.pickupAddress,
                              pickupSubtitle: trip.pickupDistanceSubtitle,
                              dropoffSubtitle: trip.pickupDistanceSubtitle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                trip.displayEarnings,
                                style: kStyle(
                                  kSemiBold,
                                  kSize22,
                                  color: kBrandBlue,
                                ),
                              ),
                              Text(
                                'you earn',
                                style: kCaption12R.copyWith(color: kMutedText),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _DetailStat(
                              label: 'Distance',
                              value: trip.distanceLabel,
                            ),
                          ),
                          Expanded(
                            child: _DetailStat(
                              label: 'Duration',
                              value: trip.durationLabel,
                            ),
                          ),
                          Expanded(
                            child: _DetailStat(
                              label: 'Vehicle Type',
                              value: trip.vehicleTypeLabel,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Auto expire if no action in ${trip.countdownLabel} min',
                  textAlign: TextAlign.center,
                  style: kCaption12R.copyWith(color: _kDeclineRed),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onDecline,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _kDeclineRed,
                          side: const BorderSide(color: _kDeclineRed, width: 1.2),
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(
                          'Reject',
                          style: kStyle(kSemiBold, kSize15, color: _kDeclineRed),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onAccept,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kBrandBlue,
                          foregroundColor: kWhite,
                          minimumSize: const Size.fromHeight(48),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(
                          'Accept',
                          style: kStyle(kSemiBold, kSize15, color: kWhite),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailStat extends StatelessWidget {
  const _DetailStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: kCaption12R.copyWith(color: kMutedText)),
        const SizedBox(height: 4),
        Text(
          value,
          style: kStyle(kSemiBold, kSize14, color: kBrandBlue),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kWhite,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: kBlack.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          height: 40,
          width: 40,
          child: Icon(icon, size: 18, color: kTextColor),
        ),
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.12),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          height: 40,
          width: 40,
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}
