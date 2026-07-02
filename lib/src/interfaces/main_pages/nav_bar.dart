import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/providers/notification_provider.dart';
import 'package:driveforme_driver/src/data/providers/trip_provider.dart';
import 'package:driveforme_driver/src/data/providers/user_provider.dart';
import 'package:driveforme_driver/src/data/services/active_trip_service.dart';
import 'package:driveforme_driver/src/data/services/driver_location_service.dart';
import 'package:driveforme_driver/src/data/services/navigation_services.dart';
import 'package:driveforme_driver/src/data/services/trip_socket_service.dart';
import 'package:driveforme_driver/src/data/providers/trip_history_provider.dart';
import 'package:driveforme_driver/src/data/providers/wallet_provider.dart';
import 'package:driveforme_driver/src/data/utils/responsive.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/home_page.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/earning.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/profile_page.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/trips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Inactive nav icon tint — darker charcoal per Figma (#5A5E60 family).
const _kNavInactiveIcon = Color(0xFF5A5E60);

class NavBar extends ConsumerStatefulWidget {
  const NavBar({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  ConsumerState<NavBar> createState() => _NavBarState();
}

class _NavBarState extends ConsumerState<NavBar> {
  late int _currentIndex;
  bool _checkedActiveTrip = false;

  static const _items = <_NavBarItemData>[
    _NavBarItemData(
      label: 'Home',
      iconPath: 'assets/svgs/home_icon.svg',
      activeGif: 'assets/gifs/home_icon.gif',
      iconWidth: 22,
      iconHeight: 22,
    ),
    _NavBarItemData(
      label: 'Trips',
      iconPath: 'assets/svgs/trips_icon.svg',
      activeGif: 'assets/gifs/trips.gif',
      iconWidth: 20,
      iconHeight: 22,
    ),
    _NavBarItemData(
      label: 'Earnings',
      iconPath: 'assets/svgs/wallet_icon.svg',
      activeGif: 'assets/gifs/wallet.gif',
      iconWidth: 22,
      iconHeight: 18,
    ),
    _NavBarItemData(
      label: 'Profile',
      iconPath: 'assets/svgs/profie_icon.svg',
      activeGif: 'assets/gifs/profile.gif',
      iconWidth: 22,
      iconHeight: 22,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, _items.length - 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadDriverOnlinePreference(ref);
      ref.read(driverLocationServiceProvider);
      _setupNotificationSocket();
      _resumeActiveTrip();
    });
  }

  Future<void> _setupNotificationSocket() async {
    final socket = ref.read(tripSocketServiceProvider);
    socket.ensureConnected();
    socket.listenForNewNotifications(() {
      ref.invalidate(notificationsProvider);
    });

    final user = await ref.read(userProvider.future);
    if (!mounted || user == null) return;

    socket.joinUserRoom(user.userId);
  }

  Future<void> _resumeActiveTrip() async {
    if (_checkedActiveTrip) return;
    _checkedActiveTrip = true;

    final target = await ref
        .read(activeTripServiceProvider)
        .resolveResumableTrip();
    if (!mounted || target == null) return;

    NavigationService().pushNamed(target.route, arguments: target.arguments);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final horizontalMargin = _NavBarMetrics.horizontalMargin(context);
    final barHeight = _NavBarMetrics.barHeight(context);
    final bottomGap = _NavBarMetrics.bottomGap(context);

    return Scaffold(
      backgroundColor: kScreenBg,
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: const [HomePage(), TripsPage(), EarningPage(), ProfilePage()],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          horizontalMargin,
          0,
          horizontalMargin,
          bottomInset + bottomGap,
        ),
        child: _FloatingNavBar(
          barHeight: barHeight,
          items: _items,
          currentIndex: _currentIndex,
          onItemSelected: (index) {
            if (_currentIndex != index) {
              setState(() => _currentIndex = index);
              if (index == 0 || index == 3) {
                ref.invalidate(userProvider);
              } else if (index == 1) {
                ref.invalidate(tripHistoryProvider);
              } else if (index == 2) {
                ref.invalidate(walletProvider);
              }
            }
          },
        ),
      ),
    );
  }
}

class _NavBarMetrics {
  static double barHeight(BuildContext context) => context.rs(64);
  static double bottomGap(BuildContext context) => context.rs(16);
  static double horizontalPadding(BuildContext context) => context.rs(12);
  static double verticalPadding(BuildContext context) => context.rs(6);
  static double activeCircleSize(BuildContext context) => context.rs(36);
  static double activeIconTextGap(BuildContext context) => context.rs(8);
  static double activePillRadius(BuildContext context) => context.rs(28);
  static double inactiveTapSize(BuildContext context) => context.rs(44);

  static double horizontalMargin(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return (width * 0.051).clamp(16.0, 24.0);
  }
}

class _NavBarItemData {
  const _NavBarItemData({
    required this.label,
    required this.iconPath,
    required this.activeGif,
    required this.iconWidth,
    required this.iconHeight,
  });

  final String label;
  final String iconPath;
  final String activeGif;
  final double iconWidth;
  final double iconHeight;
}

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({
    required this.barHeight,
    required this.items,
    required this.currentIndex,
    required this.onItemSelected,
  });

  final double barHeight;
  final List<_NavBarItemData> items;
  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  @override
  Widget build(BuildContext context) {
    final radius = barHeight / 2;

    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: Container(
        height: barHeight,
        padding: EdgeInsets.symmetric(
          horizontal: _NavBarMetrics.horizontalPadding(context),
          vertical: _NavBarMetrics.verticalPadding(context),
        ),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = currentIndex == index;

            return Expanded(
              child: Center(
                child: _NavBarTab(
                  item: item,
                  isSelected: isSelected,
                  onTap: () => onItemSelected(index),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavBarTab extends StatelessWidget {
  const _NavBarTab({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _NavBarItemData item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pillRadius = _NavBarMetrics.activePillRadius(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(pillRadius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: isSelected
              ? EdgeInsets.symmetric(
                  horizontal: context.rs(10),
                  vertical: context.rs(4),
                )
              : EdgeInsets.zero,
          decoration: BoxDecoration(
            color: isSelected ? kBrandBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(pillRadius),
          ),
          child: isSelected
              ? _ActiveTabContent(item: item)
              : _InactiveTabIcon(item: item),
        ),
      ),
    );
  }
}

class _ActiveTabContent extends StatelessWidget {
  const _ActiveTabContent({required this.item});

  final _NavBarItemData item;

  @override
  Widget build(BuildContext context) {
    final circleSize = _NavBarMetrics.activeCircleSize(context);
    final iconGap = _NavBarMetrics.activeIconTextGap(context);

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: circleSize,
            width: circleSize,
            decoration: BoxDecoration(
              color: kWhite.withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: _NavGifIcon(
              asset: item.activeGif,
              width: context.rs(item.iconWidth),
              height: context.rs(item.iconHeight),
            ),
          ),
          SizedBox(width: iconGap),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: kStyle(kSemiBold, kSize14, color: kWhite, height: 1.0),
          ),
        ],
      ),
    );
  }
}

class _NavGifIcon extends StatelessWidget {
  const _NavGifIcon({
    required this.asset,
    required this.width,
    required this.height,
  });

  final String asset;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: width,
      height: height,
      fit: BoxFit.contain,
      gaplessPlayback: true,
      filterQuality: FilterQuality.medium,
    );
  }
}

class _InactiveTabIcon extends StatelessWidget {
  const _InactiveTabIcon({required this.item});

  final _NavBarItemData item;

  @override
  Widget build(BuildContext context) {
    final tapSize = _NavBarMetrics.inactiveTapSize(context);

    return SizedBox(
      height: tapSize,
      width: tapSize,
      child: Center(
        child: SvgPicture.asset(
          item.iconPath,
          width: context.rs(item.iconWidth),
          height: context.rs(item.iconHeight),
          fit: BoxFit.contain,
          colorFilter: const ColorFilter.mode(
            _kNavInactiveIcon,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
