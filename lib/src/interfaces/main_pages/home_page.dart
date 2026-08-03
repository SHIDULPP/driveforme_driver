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

const _kHomeHeaderBlue = Color(0xFF1E518B);
const _kOnlineCardBg = Color(0xFF164A72);
const _kPromoCardBg = Color(0xFFFEFAF2);
const _kToggleOrange = Color(0xFFE68C3A);
const _kEarningsBarBlue = Color(0xFF1E5C8D);

/// Content height inside the blue header (greeting + online card + inner padding).
double _headerContentHeight(BuildContext context) => context.rs(148);

/// How far the center of the header curve extends below the content box.
double _headerCurveDepth(BuildContext context) => context.rs(64);

/// Visible gap between the online status card and today's earnings card.
double _onlineToEarningsGap(BuildContext context) => context.rs(12);

/// Height of the online status row at the bottom of the header.
double _onlineCardHeight(BuildContext context) => context.rs(58);

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
    final horizontal = context.horizontalPadding;
    final headerContentHeight = _headerContentHeight(context);
    final headerCurveDepth = _headerCurveDepth(context);
    final earningsCardTop = _earningsCardTop(context, topPadding);
    final scrollTopPadding = earningsCardTop;
    final mapTop = topPadding + headerContentHeight - context.rs(12);
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
                    SizedBox(height: context.rs(10)),
                    _TripPreferenceCard(
                      isShortTrip: isShortTrip,
                      onChanged: (isShort) => setTripPreference(ref, isShort),
                    ),
                    SizedBox(height: context.rs(10)),
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
              top: topPadding + context.rs(6),
              right: context.rs(18),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => NavigationService().pushNamed('notificationsPage'),
                child: SizedBox(width: context.rs(44), height: context.rs(44)),
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
        topPadding + contentHeight + curveDepth + context.rs(20);
    final horizontal = context.horizontalPadding;

    return SizedBox(
      height: totalHeight,
      child: ClipPath(
        clipper: _HomeHeaderClipper(curveDepth: curveDepth),
        child: Container(
          color: _kHomeHeaderBlue,
          padding: EdgeInsets.fromLTRB(
            horizontal,
            topPadding + context.rs(8),
            horizontal,
            curveDepth + context.rs(18),
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
                            style: kStyle(
                              kSemiBold,
                              kSize22,
                              color: kWhite,
                              height: 1.15,
                            ),
                          ),
                          SizedBox(height: context.rs(4)),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: context.rs(15),
                                color: kWhite.withValues(alpha: 0.9),
                              ),
                              SizedBox(width: context.rs(4)),
                              Expanded(
                                child: Text(
                                  location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: kCaption14R.copyWith(
                                    color: kWhite.withValues(alpha: 0.85),
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: context.rs(6)),
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
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: context.rs(40),
                          width: context.rs(40),
                          decoration: BoxDecoration(
                            color: kWhite.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Image.asset(
                            'assets/gifs/notification.gif',
                            width: context.rs(22),
                            height: context.rs(22),
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
                                style: kCaption11R.copyWith(
                                  color: kWhite,
                                  fontWeight: kSemiBold,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: context.rs(12)),
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

class _OnlineStatusCard extends StatelessWidget {
  const _OnlineStatusCard({required this.isOnline, required this.onChanged});

  final bool isOnline;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.rs(12),
        vertical: context.rs(7),
      ),
      decoration: BoxDecoration(
        color: _kOnlineCardBg.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(context.rs(18)),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(context.rs(22)),
                child: Image.asset(
                  'assets/pngs/live_photo_image.png',
                  width: context.rs(40),
                  height: context.rs(40),
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  height: context.rs(10),
                  width: context.rs(10),
                  decoration: BoxDecoration(
                    color: isOnline ? kActiveGreen : kMutedText,
                    shape: BoxShape.circle,
                    border: Border.all(color: kWhite, width: 2),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: context.rs(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOnline ? 'You are Online' : 'You are Offline',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: kStyle(
                    kSemiBold,
                    kSize14,
                    color: kWhite,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: context.rs(2)),
                Text(
                  isOnline
                      ? 'Ready to accept requests'
                      : 'You will not receive requests',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: kCaption12R.copyWith(
                    color: kWhite.withValues(alpha: 0.7),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.84,
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

class _TodaysEarningsCard extends ConsumerWidget {
  const _TodaysEarningsCard();

  static const _barHeights = [0.38, 0.58, 0.45, 0.82, 0.52, 0.68, 0.62];
  static const _earningsTabIndex = 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final earningsLabel = ref
        .watch(userProvider)
        .when(
          data: (user) => formatTodayEarnings(user),
          loading: () => '₹ —',
          error: (_, _) => formatTodayEarnings(null),
        );

    return Material(
      color: Colors.transparent,
      elevation: 6,
      shadowColor: kBlack.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(context.rs(16)),
      child: InkWell(
        onTap: () =>
            ref.read(navBarIndexProvider.notifier).state = _earningsTabIndex,
        borderRadius: BorderRadius.circular(context.rs(16)),
        child: Container(
          padding: EdgeInsets.all(context.rs(12)),
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.circular(context.rs(16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: context.rs(22),
                    width: context.rs(34),
                    decoration: const BoxDecoration(
                      color: kBrandBlue,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      'assets/svgs/wallet_icon.svg',
                      width: context.rs(17),
                      height: context.rs(14),
                      colorFilter: const ColorFilter.mode(
                        kWhite,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  SizedBox(width: context.rs(8)),
                  Expanded(
                    child: Text("Today's Earnings", style: kTripSubSectionSB),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: kChevronGrey,
                    size: context.rs(20),
                  ),
                ],
              ),
              SizedBox(height: context.rs(6)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          earningsLabel,
                          style: kStyle(
                            kSemiBold,
                            kSize26,
                            color: kBrandBlue,
                            height: 1.05,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: context.rs(8)),
                  SizedBox(
                    height: context.rs(52),
                    width: context.rs(84),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _barHeights
                          .map(
                            (h) => Container(
                              width: context.rs(8),
                              height: context.rs(52) * h,
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
      padding: EdgeInsets.all(context.rs(12)),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(context.rs(14)),
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
          SizedBox(height: context.rs(10)),
          Container(
            padding: EdgeInsets.all(context.rs(4)),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(context.rs(14)),
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
          SizedBox(height: context.rs(8)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: context.rs(14),
                color: kActiveGreen,
              ),
              SizedBox(width: context.rs(6)),
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
    final imageSize = context.rs(32);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: context.rs(8),
          vertical: context.rs(8),
        ),
        decoration: BoxDecoration(
          color: isSelected ? selectedBackground : Colors.transparent,
          borderRadius: BorderRadius.circular(context.rs(10)),
          border: isSelected
              ? Border.all(color: kGoldAccent, width: 1.2)
              : null,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final useColumn = constraints.maxWidth < context.rs(110);

            final image = Image.asset(
              imagePath,
              height: imageSize,
              width: imageSize,
              fit: BoxFit.contain,
            );

            final textColumn = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: kCaption14B.copyWith(color: kTextColor),
                ),
                SizedBox(height: context.rs(2)),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: kCaption12R.copyWith(color: kTextColor, height: 1.2),
                ),
              ],
            );

            if (useColumn) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  image,
                  SizedBox(height: context.rs(8)),
                  textColumn,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                image,
                SizedBox(width: context.rs(8)),
                Expanded(child: textColumn),
              ],
            );
          },
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
    final imageWidth = context.rs(118);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _kPromoCardBg,
        borderRadius: BorderRadius.circular(context.rs(14)),
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
            width: imageWidth,
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                Positioned(
                  right: context.rs(8),
                  bottom: context.rs(8),
                  child: Image.asset(
                    'assets/pngs/car_shadow.png',
                    width: context.rs(100),
                    fit: BoxFit.contain,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: context.rs(4)),
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
            padding: EdgeInsets.fromLTRB(
              context.rs(14),
              context.rs(12),
              imageWidth - context.rs(10),
              context.rs(12),
            ),
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
                GestureDetector(
                  onTap: () => _openLearnMore(context),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: context.rs(2)),
                    child: Text(
                      'Learn more',
                      style: kStyle(
                        kMedium,
                        kSize14,
                        color: kBrandBlue,
                        height: 1.2,
                      ).copyWith(decoration: TextDecoration.underline),
                    ),
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
