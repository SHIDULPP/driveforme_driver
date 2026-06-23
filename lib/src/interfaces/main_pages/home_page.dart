import 'dart:async';

import 'package:driveforme_driver/src/data/apis/trip_api.dart';
import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/models/trip_model.dart';
import 'package:driveforme_driver/src/data/providers/loading_provider.dart';
import 'package:driveforme_driver/src/data/providers/trip_provider.dart';
import 'package:driveforme_driver/src/data/providers/user_provider.dart';
import 'package:driveforme_driver/src/data/services/navigation_services.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/trip_pages/new_trip_request_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

const _kHomeHeaderBlue = Color(0xFF1E518B);
const _kOnlineCardBg = Color(0xFF164A72);
const _kPromoCardBg = Color(0xFFFEFAF2);
const _kToggleOrange = Color(0xFFE68C3A);
const _kEarningsBarBlue = Color(0xFF1E5C8D);

/// Content height inside the blue header (greeting + online card + inner padding).
const _kHeaderContentHeight = 156.0;

/// How far the center of the header curve extends below the content box.
const _kHeaderCurveDepth = 70.0;

/// Pulls the earnings card up so ~40% sits on the blue header.
const _kEarningsCardOverlap = 58.0;

/// Height of the online status row at the bottom of the header.
const _kOnlineCardHeight = 68.0;

double _onlineCardTop(double topPadding) =>
    topPadding + 8 + _kHeaderContentHeight - _kOnlineCardHeight;

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isOnline = true;
  bool _isShortTrip = true;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncTripPreference(_isShortTrip);
    });
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (_isOnline && mounted) {
        ref.invalidate(availableTripsProvider);
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _syncTripPreference(bool isShortTrip) {
    ref.read(tripPreferenceProvider.notifier).state = isShortTrip
        ? 'short_trip'
        : 'long_trip';
    ref.invalidate(availableTripsProvider);
  }

  void _openTripDetails(TripModel trip) {
    NavigationService().pushNamed(
      'tripRequestDetails',
      arguments: {'trip': trip},
    );
  }

  Future<void> _acceptTrip(TripModel trip) async {
    ref.read(loadingProvider.notifier).startLoading();
    final response = await ref.read(tripApiProvider).acceptTrip(trip.id);
    ref.read(loadingProvider.notifier).stopLoading();

    if (!mounted) return;

    if (!response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? 'Failed to accept trip.')),
      );
      return;
    }

    ref.invalidate(availableTripsProvider);
    NavigationService().pushNamed('driverArrived');
  }

  void _declineTrip(TripModel trip) {
    dismissTripRequest(ref, trip.id);
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final headerTotalHeight =
        topPadding + _kHeaderContentHeight + _kHeaderCurveDepth;
    final scrollTopPadding = headerTotalHeight - _kEarningsCardOverlap;
    final mapTop = topPadding + _kHeaderContentHeight - 12;
    final tripsAsync = _isOnline ? ref.watch(availableTripsProvider) : null;
    final currentTrip = tripsAsync == null
        ? null
        : tripsAsync.when(
            data: (trips) => trips.isNotEmpty ? trips.first : null,
            loading: () => null,
            error: (_, _) => null,
          );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: kScreenBg,
        body: Stack(
          clipBehavior: Clip.none,
          fit: StackFit.expand,
          children: [
            Positioned(
              top: mapTop,
              left: 0,
              right: 0,
              bottom: 0,
              child: Image.asset(
                'assets/pngs/map_image.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _HomeHeaderBackground(
                contentHeight: _kHeaderContentHeight,
                curveDepth: _kHeaderCurveDepth,
              ),
            ),
            Positioned.fill(
              child: SingleChildScrollView(
                clipBehavior: Clip.none,
                padding: EdgeInsets.fromLTRB(20, scrollTopPadding, 20, 100),
                child: Column(
                  children: [
                    const _TodaysEarningsCard(),
                    const SizedBox(height: 12),
                    _TripPreferenceCard(
                      isShortTrip: _isShortTrip,
                      onChanged: (isShort) {
                        setState(() => _isShortTrip = isShort);
                        _syncTripPreference(isShort);
                      },
                    ),
                    const SizedBox(height: 12),
                    const _PromoBannerCard(),
                  ],
                ),
              ),
            ),
            Positioned(
              top: _onlineCardTop(topPadding),
              left: 20,
              right: 20,
              child: _OnlineStatusCard(
                isOnline: _isOnline,
                onChanged: (value) => setState(() => _isOnline = value),
              ),
            ),
            if (currentTrip != null)
              Positioned(
                left: 20,
                right: 20,
                top: scrollTopPadding + 8,
                child: NewTripRequestCard(
                  trip: currentTrip,
                  onTap: () => _openTripDetails(currentTrip),
                  onAccept: () => _acceptTrip(currentTrip),
                  onDecline: () => _declineTrip(currentTrip),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeaderBackground extends ConsumerWidget {
  const _HomeHeaderBackground({
    required this.contentHeight,
    required this.curveDepth,
  });

  final double contentHeight;
  final double curveDepth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final greeting = userAsync.when(
      data: (user) => 'Hii ${greetingFirstName(user)}!',
      loading: () => 'Hii there!',
      error: (_, _) => 'Hii there!',
    );
    final location = userAsync.when(
      data: (user) => displayLocation(user),
      loading: () => 'Loading location...',
      error: (_, _) => 'Location not set',
    );

    final topPadding = MediaQuery.paddingOf(context).top;
    final totalHeight = topPadding + contentHeight + curveDepth + 20;

    return SizedBox(
      height: totalHeight,
      child: ClipPath(
        clipper: _HomeHeaderClipper(curveDepth: curveDepth),
        child: Container(
          color: _kHomeHeaderBlue,
          padding: EdgeInsets.fromLTRB(20, topPadding + 8, 20, curveDepth + 18),
          child: SizedBox(
            height: contentHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            greeting,
                            style: kStyle(
                              kSemiBold,
                              kSize22,
                              color: kWhite,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 15,
                                color: kWhite.withValues(alpha: 0.9),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  location,
                                  style: kCaption14R.copyWith(
                                    color: kWhite.withValues(alpha: 0.85),
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Row(
                          //   children: [
                          //     SvgPicture.asset(
                          //       'assets/svgs/wallet_icon.svg',
                          //       width: 15,
                          //       height: 13,
                          //       colorFilter: ColorFilter.mode(
                          //         kWhite.withValues(alpha: 0.9),
                          //         BlendMode.srcIn,
                          //       ),
                          //     ),
                          //     const SizedBox(width: 4),
                          //     Text(
                          //       walletBalance,
                          //       style: kCaption14R.copyWith(
                          //         color: kWhite.withValues(alpha: 0.85),
                          //         height: 1.2,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: kWhite.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: kWhite,
                        size: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Spacer(),
                const SizedBox(height: _kOnlineCardHeight),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom edge: sides sit higher; center dips lower (tongue over the map).
class _HomeHeaderClipper extends CustomClipper<Path> {
  _HomeHeaderClipper({required this.curveDepth});

  final double curveDepth;

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final sideInset = 0.0;
    final sideY = h - curveDepth * 0.35;
    final centerY = h;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w - sideInset, sideY)
      ..cubicTo(
        w * 0.82,
        sideY + curveDepth * 0.15,
        w * 0.62,
        centerY,
        w * 0.5,
        centerY,
      )
      ..cubicTo(
        w * 0.38,
        centerY,
        w * 0.18,
        sideY + curveDepth * 0.15,
        sideInset,
        sideY,
      )
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant _HomeHeaderClipper oldClipper) =>
      oldClipper.curveDepth != curveDepth;
}

class _OnlineStatusCard extends StatelessWidget {
  const _OnlineStatusCard({required this.isOnline, required this.onChanged});

  final bool isOnline;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _kOnlineCardBg.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Image.asset(
                  'assets/pngs/live_photo_image.png',
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  height: 12,
                  width: 12,
                  decoration: BoxDecoration(
                    color: isOnline ? kActiveGreen : kMutedText,
                    shape: BoxShape.circle,
                    border: Border.all(color: kWhite, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOnline ? 'You are Online' : 'You are Offline',
                  style: kStyle(
                    kSemiBold,
                    kSize15,
                    color: kWhite,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isOnline
                      ? 'Ready to accept orders'
                      : 'You will not receive requests',
                  style: kCaption12R.copyWith(
                    color: kWhite.withValues(alpha: 0.7),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.92,
            child: Switch(
              value: isOnline,
              onChanged: onChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              activeThumbColor: kWhite,
              activeTrackColor: _kToggleOrange,
              inactiveThumbColor: kWhite,
              inactiveTrackColor: kMutedText.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodaysEarningsCard extends StatelessWidget {
  const _TodaysEarningsCard();

  static const _barHeights = [0.38, 0.58, 0.45, 0.82, 0.52, 0.68, 0.62];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 6,
      shadowColor: kBlack.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 25,
                  width: 40,
                  decoration: const BoxDecoration(
                    color: kBrandBlue,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/svgs/wallet_icon.svg',
                    width: 20,
                    height: 17,
                    colorFilter: const ColorFilter.mode(
                      kWhite,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text("Today's Earnings", style: kTripSubSectionSB),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: kChevronGrey,
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₹ 235',
                        style: kStyle(
                          kSemiBold,
                          kSize30,
                          color: kBrandBlue,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: kActiveGreenBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('+ ₹ 235 Bonus', style: kTripBadgeSB),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 64,
                  width: 96,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _barHeights
                        .map(
                          (h) => Container(
                            width: 9,
                            height: 64 * h,
                            decoration: BoxDecoration(
                              color: _kEarningsBarBlue,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TripPreferenceCard extends StatelessWidget {
  const _TripPreferenceCard({
    required this.isShortTrip,
    required this.onChanged,
  });

  final bool isShortTrip;
  final ValueChanged<bool> onChanged;

  static const _kOptionsBorder = Color(0xFFE8E8E8);
  static const _kSelectedTripBg = Color(0xFFF9F7F0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kBlack.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Trip Preference', style: kTripSubSectionSB),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _kOptionsBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _TripOptionTile(
                    title: 'Short Trip',
                    subtitle: 'Within City',
                    imagePath: 'assets/pngs/short_trip.png',
                    isSelected: isShortTrip,
                    selectedBackground: _kSelectedTripBg,
                    onTap: () => onChanged(true),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _TripOptionTile(
                    title: 'Long Trip',
                    subtitle: 'Outstation',
                    imagePath: 'assets/pngs/long_trip.png',
                    isSelected: !isShortTrip,
                    selectedBackground: _kSelectedTripBg,
                    onTap: () => onChanged(false),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 15, color: kActiveGreen),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'You will recieve requestes based on your preferences',
                  style: kCaption12R.copyWith(color: kMutedText, height: 1.35),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TripOptionTile extends StatelessWidget {
  const _TripOptionTile({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.isSelected,
    required this.selectedBackground,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String imagePath;
  final bool isSelected;
  final Color selectedBackground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? selectedBackground : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: kGoldAccent, width: 1.2)
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(imagePath, height: 38, width: 38, fit: BoxFit.contain),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: kCaption14B.copyWith(color: kTextColor)),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: kCaption12R.copyWith(color: kTextColor, height: 1.2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoBannerCard extends StatelessWidget {
  const _PromoBannerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _kPromoCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kGoldAccent.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: kBlack.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            bottom: 0,
            top: 0,
            width: 130,
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Image.asset(
                    'assets/pngs/car_shadow.png',
                    width: 100,
                    fit: BoxFit.contain,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Image.asset(
                    'assets/pngs/car_image.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.centerRight,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 118, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Drive More. Earn More!',
                  style: kCaption14B.copyWith(fontSize: kSize16),
                ),
                const SizedBox(height: 5),
                Text(
                  'Complete 20 trips this week and get 1,000 extra',
                  style: kCaption13R.copyWith(
                    color: kSecondaryTextColor,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Learn more',
                  style: kStyle(
                    kMedium,
                    kSize14,
                    color: kBrandBlue,
                    height: 1.2,
                  ).copyWith(decoration: TextDecoration.underline),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
