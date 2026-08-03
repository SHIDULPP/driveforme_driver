import 'package:driveforme_driver/src/data/apis/trip_api.dart';
import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/models/trip_model.dart';
import 'package:driveforme_driver/src/data/providers/loading_provider.dart';
import 'package:driveforme_driver/src/data/providers/current_location_provider.dart';
import 'package:driveforme_driver/src/data/providers/nav_provider.dart';
import 'package:driveforme_driver/src/data/providers/notification_provider.dart';
import 'package:driveforme_driver/src/data/providers/trip_provider.dart';
import 'package:driveforme_driver/src/data/providers/user_provider.dart';
import 'package:driveforme_driver/src/data/utils/trip_lifecycle.dart';
import 'package:driveforme_driver/src/data/services/navigation_services.dart';
import 'package:driveforme_driver/src/data/utils/responsive.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/trip_pages/new_trip_request_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Figma header / primary blue (`#1D5C92` family used on this screen).
const _kHomeHeaderBlue = Color(0xFF1D5C92);
const _kPromoCardBg = Color(0xFFFEFAF2);
const _kToggleAccent = Color(0xFFCE9141);
const _kEarningsBarBlue = Color(0xFF1D5C92);
const _kEarningsBarTrack = Color(0xFFE8EFF8);

/// Content height inside the blue header (greeting + online card + inner padding).
/// Figma header frame ≈ 258 including status bar; content area below status ≈ 214.
double _headerContentHeight(BuildContext context) => 188;

/// How far the center of the header curve extends below the content box.
double _headerCurveDepth(BuildContext context) => 56;

/// Visible gap between the online status card and today's earnings card.
double _onlineToEarningsGap(BuildContext context) => 12;

/// Height of the online status row at the bottom of the header (Figma = 62).
double _onlineCardHeight(BuildContext context) => 62;

double _onlineCardTop(BuildContext context, double topPadding) =>
    topPadding +
    context.rs(8) +
    _headerContentHeight(context) -
    _onlineCardHeight(context);

double _earningsCardTop(BuildContext context, double topPadding) =>
    _onlineCardTop(context, topPadding) +
    _onlineCardHeight(context) +
    _onlineToEarningsGap(context);

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(currentLocationProvider);
      loadDriverOnlinePreference(ref);
      final isShortTrip = ref.read(tripPreferenceProvider) == 'short_trip';
      setTripPreference(ref, isShortTrip);
    });
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

    ref.read(availableTripsProvider.notifier).removeTrip(trip.id);
    final acceptedTrip = response.data ?? trip;
    await navigateToActiveTrip(ref, acceptedTrip);
  }

  void _declineTrip(TripModel trip) {
    dismissTripRequest(ref, trip.id);
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final horizontal = 16.0;
    final headerContentHeight = _headerContentHeight(context);
    final headerCurveDepth = _headerCurveDepth(context);
    final earningsCardTop = _earningsCardTop(context, topPadding);
    final scrollTopPadding = earningsCardTop;
    final mapTop = topPadding + headerContentHeight - 12;
    final bottomPadding = context.scaffoldBottomPadding;
    final isOnline = ref.watch(driverOnlineProvider);
    final isShortTrip = ref.watch(tripPreferenceProvider) == 'short_trip';
    final unreadNotifications = ref.watch(unreadNotificationCountProvider);
    final availableTrips = isOnline
        ? ref.watch(availableTripsProvider)
        : const <TripModel>[];
    final currentTrip = availableTrips.isNotEmpty ? availableTrips.first : null;

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
                contentHeight: headerContentHeight,
                curveDepth: headerCurveDepth,
                onlineCardHeight: _onlineCardHeight(context),
                unreadNotificationCount: unreadNotifications,
              ),
            ),
            Positioned.fill(
              child: SingleChildScrollView(
                clipBehavior: Clip.none,
                padding: EdgeInsets.fromLTRB(
                  horizontal,
                  scrollTopPadding,
                  horizontal,
                  bottomPadding,
                ),
                child: Column(
                  children: [
                    const _TodaysEarningsCard(),
                    const SizedBox(height: 8),
                    _TripPreferenceCard(
                      isShortTrip: isShortTrip,
                      onChanged: (isShort) => setTripPreference(ref, isShort),
                    ),
                    const SizedBox(height: 8),
                    const _PromoBannerCard(),
                  ],
                ),
              ),
            ),
            Positioned(
              top: _onlineCardTop(context, topPadding),
              left: horizontal,
              right: horizontal,
              child: _OnlineStatusCard(
                isOnline: isOnline,
                onChanged: (value) => setDriverOnline(ref, value),
              ),
            ),
            if (currentTrip != null)
              Positioned(
                left: horizontal,
                right: horizontal,
                top: scrollTopPadding + context.rs(8),
                child: NewTripRequestCard(
                  trip: currentTrip,
                  onTap: () => _openTripDetails(currentTrip),
                  onAccept: () => _acceptTrip(currentTrip),
                  onDecline: () => _declineTrip(currentTrip),
                ),
              ),
            Positioned(
              top: topPadding + 26,
              right: 16,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => NavigationService().pushNamed('notificationsPage'),
                child: const SizedBox(width: 40, height: 40),
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
    required this.onlineCardHeight,
    this.unreadNotificationCount = 0,
  });

  final double contentHeight;
  final double curveDepth;
  final double onlineCardHeight;
  final int unreadNotificationCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final greeting = userAsync.when(
      data: (user) => 'Hii ${greetingFirstName(user)}!',
      loading: () => 'Hii there!',
      error: (_, _) => 'Hii there!',
    );
    final location = ref
        .watch(currentLocationProvider)
        .when(
          data: (current) => current?.displayLabel ?? 'Location unavailable',
          loading: () => 'Getting location...',
          error: (_, _) => 'Location unavailable',
        );

    final topPadding = MediaQuery.paddingOf(context).top;
    final totalHeight =
        topPadding + contentHeight + curveDepth + 20;
    final horizontal = 16.0;

    return SizedBox(
      height: totalHeight,
      child: ClipPath(
        clipper: _HomeHeaderClipper(curveDepth: curveDepth),
        child: Container(
          color: _kHomeHeaderBlue,
          padding: EdgeInsets.fromLTRB(
            horizontal,
            topPadding + 26,
            horizontal,
            curveDepth + 18,
          ),
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'ClashGrotesk',
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                              color: kWhite,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 0),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 16,
                                color: kFigmaNeutral,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'ClashGrotesk',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: kFigmaNeutral,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: kWhite.withValues(alpha: 0.1),
                            border: Border.all(
                              color: kWhite.withValues(alpha: 0.1),
                              width: 0.5,
                            ),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Image.asset(
                            'assets/gifs/notification.gif',
                            width: 24,
                            height: 24,
                            fit: BoxFit.contain,
                            gaplessPlayback: true,
                          ),
                        ),
                        if (unreadNotificationCount > 0)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFFE32626),
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Text(
                                unreadNotificationCount > 9
                                    ? '9+'
                                    : '$unreadNotificationCount',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'ClashGrotesk',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                  color: kWhite,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Spacer(),
                SizedBox(height: onlineCardHeight),
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

class _OnlineStatusCard extends ConsumerWidget {
  const _OnlineStatusCard({required this.isOnline, required this.onChanged});

  final bool isOnline;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoUrl = profilePhotoUrl(ref.watch(userProvider).value);

    return Container(
      height: 62,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: kWhite.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: kWhite.withValues(alpha: 0.11)),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipOval(
                child: photoUrl != null
                    ? Image.network(
                        photoUrl,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (_, error, stackTrace) => Image.asset(
                          'assets/pngs/live_photo_image.png',
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
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
                  height: 9,
                  width: 9,
                  decoration: BoxDecoration(
                    color: isOnline ? kActiveGreen : kMutedText,
                    shape: BoxShape.circle,
                    border: Border.all(color: _kHomeHeaderBlue, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOnline ? 'You are Online' : 'You are Offline',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'ClashGrotesk',
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    color: kWhite,
                    height: 1.2,
                  ),
                ),
                Text(
                  isOnline
                      ? 'Ready to accept requests'
                      : 'You will not receive requests',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'ClashGrotesk',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: kWhite.withValues(alpha: 0.47),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          _OnlineToggle(value: isOnline, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _OnlineToggle extends StatelessWidget {
  const _OnlineToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: 44,
        height: 24.444,
        padding: const EdgeInsets.all(2.44),
        decoration: BoxDecoration(
          color: value ? _kToggleAccent : kFigmaNeutral,
          borderRadius: BorderRadius.circular(100),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 19.556,
            height: 19.556,
            decoration: BoxDecoration(
              color: value ? kFigmaNeutral : const Color(0xFFA5A7A2),
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A272727),
                  blurRadius: 4.889,
                  offset: Offset(0, 2.444),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TodaysEarningsCard extends ConsumerWidget {
  const _TodaysEarningsCard();

  /// Relative solid fill heights matching Figma bar solids (visual approximation).
  static const _barHeights = [0.50, 0.21, 1.0, 0.50, 0.36, 0.23, 1.0];
  static const _barTrackHeights = [0.75, 1.0, 0.39, 0.75, 0.62, 1.0, 0.82];
  static const _earningsTabIndex = 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final amount = ref.watch(userProvider).when(
          data: (user) => user?.todayEarnings ?? 0,
          loading: () => null,
          error: (_, _) => 0.0,
        );
    final amountText = amount == null
        ? '—'
        : (amount == amount.truncateToDouble()
            ? amount.toInt().toString()
            : amount.toStringAsFixed(2));

    return Material(
      color: Colors.transparent,
      elevation: 4,
      shadowColor: kBlack.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () =>
            ref.read(navBarIndexProvider.notifier).state = _earningsTabIndex,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 115),
          padding: const EdgeInsets.fromLTRB(15, 21, 15, 16),
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 36,
                          width: 36,
                          decoration: const BoxDecoration(
                            color: kBrandBlue,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            'assets/svgs/wallet_icon.svg',
                            width: 20,
                            height: 20,
                            colorFilter: const ColorFilter.mode(
                              kWhite,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Today's Earnings",
                                style: TextStyle(
                                  fontFamily: 'ClashGrotesk',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: kTextColor,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    '₹',
                                    style: TextStyle(
                                      fontFamily: 'ClashGrotesk',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 24,
                                      color: kBrandBlue,
                                      height: 1.0,
                                    ),
                                  ),
                                  Text(
                                    amountText,
                                    style: const TextStyle(
                                      fontFamily: 'ClashGrotesk',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 24,
                                      color: kBrandBlue,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 45,
                    width: 106,
                    child: CustomPaint(
                      painter: _EarningsChartPainter(
                        barHeights: _barHeights,
                        trackHeights: _barTrackHeights,
                      ),
                    ),
                  ),
                ],
              ),
              const Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: kChevronGrey,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EarningsChartPainter extends CustomPainter {
  _EarningsChartPainter({
    required this.barHeights,
    required this.trackHeights,
  });

  final List<double> barHeights;
  final List<double> trackHeights;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFFE8EFF8)
      ..strokeWidth = 0.32;

    for (var i = 0; i < 4; i++) {
      final y = size.height * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    const barWidth = 8.67;
    final gap = (size.width - barWidth * 7) / 6;
    final trackPaint = Paint()..color = _kEarningsBarTrack;
    final solidPaint = Paint()..color = _kEarningsBarBlue;

    for (var i = 0; i < 7; i++) {
      final x = i * (barWidth + gap);
      final trackH = size.height * trackHeights[i].clamp(0.05, 1.0);
      final solidH = trackH * barHeights[i].clamp(0.05, 1.0);
      final trackTop = size.height - trackH;
      final solidTop = size.height - solidH;

      final trackRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, trackTop, barWidth, trackH),
        const Radius.circular(2),
      );
      final solidRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, solidTop, barWidth, solidH),
        const Radius.circular(2),
      );
      canvas.drawRRect(trackRect, trackPaint);
      canvas.drawRRect(solidRect, solidPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _EarningsChartPainter oldDelegate) => false;
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
      padding: const EdgeInsets.fromLTRB(11, 15, 11, 12),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(14),
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
          const Text(
            'Trip Preference',
            style: TextStyle(
              fontFamily: 'ClashGrotesk',
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: kTextColor,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 11),
          Container(
            padding: const EdgeInsets.all(4.5),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(14),
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
          const SizedBox(height: 11),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.verified, size: 12, color: kActiveGreen),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  'You will receive requests based on your preferences',
                  style: TextStyle(
                    fontFamily: 'ClashGrotesk',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: kMutedText,
                    height: 1.15,
                  ),
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
    const imageSize = 30.0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? selectedBackground : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: kGoldAccent, width: 1.2)
              : null,
        ),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              height: imageSize,
              width: imageSize,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'ClashGrotesk',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: kTextColor,
                      height: 1.35,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'ClashGrotesk',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: kMutedText,
                      height: 1.15,
                    ),
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

  static Future<void> _openLearnMore(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return const _PromoLearnMoreSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Figma Frame 2147227124: 361×112 — text column 146×76 @ (19,18), car on right.
    return Container(
      height: 112,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _kPromoCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kGoldAccent.withValues(alpha: 0.35)),
      ),
      child: MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.0,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(19, 18, 8, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Drive More. Earn More!',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'ClashGrotesk',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: kDarkText,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Complete 20 trips this week and get 1,000 extra',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'ClashGrotesk',
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: kDarkText.withValues(alpha: 0.55),
                        height: 1.15,
                      ),
                    ),
                    const Spacer(),
                    const _PromoLearnMoreLink(),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 168,
              height: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(right: 4, top: 8, bottom: 4),
                child: Image.asset(
                  'assets/pngs/car_image.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.centerRight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoLearnMoreLink extends StatelessWidget {
  const _PromoLearnMoreLink();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _PromoBannerCard._openLearnMore(context),
      behavior: HitTestBehavior.opaque,
      child: const Text(
        'Learn more',
        style: TextStyle(
          fontFamily: 'ClashGrotesk',
          fontWeight: FontWeight.w500,
          fontSize: 12,
          color: kBrandBlue,
          height: 1.15,
          decoration: TextDecoration.underline,
          decorationColor: kBrandBlue,
        ),
      ),
    );
  }
}

class _PromoLearnMoreSheet extends StatelessWidget {
  const _PromoLearnMoreSheet();

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        context.rs(20),
        context.rs(12),
        context.rs(20),
        bottomInset + context.rs(20),
      ),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.rs(24)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: context.rs(40),
              height: context.rs(4),
              decoration: BoxDecoration(
                color: kCardBorder,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          SizedBox(height: context.rs(18)),
          Text(
            'Drive More. Earn More!',
            style: kStyle(kSemiBold, kSize20, color: kTextColor, height: 1.2),
          ),
          SizedBox(height: context.rs(10)),
          Text(
            'Complete 20 trips this week and earn an extra ₹1,000 bonus '
            'credited to your wallet.',
            style: kCaption14R.copyWith(
              color: kSecondaryTextColor,
              height: 1.45,
            ),
          ),
          SizedBox(height: context.rs(16)),
          _PromoDetailRow(
            icon: Icons.route_outlined,
            title: 'How it works',
            body:
                'Stay online, accept trip requests, and complete 20 trips '
                'within the current week (Monday–Sunday).',
          ),
          SizedBox(height: context.rs(12)),
          _PromoDetailRow(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Bonus payout',
            body:
                'Once you hit the target, ₹1,000 is added to your wallet '
                'automatically. You can withdraw it to your bank account.',
          ),
          SizedBox(height: context.rs(12)),
          _PromoDetailRow(
            icon: Icons.info_outline_rounded,
            title: 'Note',
            body:
                'Cancelled trips do not count. Only completed trips in your '
                'selected trip preference are eligible.',
          ),
          SizedBox(height: context.rs(22)),
          SizedBox(
            width: double.infinity,
            height: context.rs(52),
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: kBrandBlue,
                foregroundColor: kWhite,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.rs(26)),
                ),
              ),
              child: Text(
                'Got it',
                style: kStyle(kSemiBold, kSize16, color: kWhite),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoDetailRow extends StatelessWidget {
  const _PromoDetailRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: context.rs(36),
          width: context.rs(36),
          decoration: BoxDecoration(
            color: kBrandBlue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(context.rs(10)),
          ),
          child: Icon(icon, size: context.rs(18), color: kBrandBlue),
        ),
        SizedBox(width: context.rs(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: kCaption14B),
              SizedBox(height: context.rs(4)),
              Text(
                body,
                style: kCaption13R.copyWith(
                  color: kSecondaryTextColor,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
