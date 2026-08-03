import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/providers/nav_provider.dart';
import 'package:driveforme_driver/src/data/providers/notification_provider.dart';
import 'package:driveforme_driver/src/data/providers/trip_provider.dart';
import 'package:driveforme_driver/src/data/providers/user_provider.dart';
import 'package:driveforme_driver/src/data/services/active_trip_service.dart';
import 'package:driveforme_driver/src/data/services/driver_location_service.dart';
import 'package:driveforme_driver/src/data/services/navigation_services.dart';
import 'package:driveforme_driver/src/data/services/trip_socket_service.dart';
import 'package:driveforme_driver/src/data/providers/trip_history_provider.dart';
import 'package:driveforme_driver/src/data/providers/wallet_provider.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/home_page.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/earning.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/profile_page.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/trips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Figma inactive nav icons — medium grey.
const _kNavInactiveIcon = Color(0xFF888888);

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
    ),
    _NavBarItemData(
      label: 'Trips',
      iconPath: 'assets/svgs/trips_icon.svg',
    ),
    _NavBarItemData(
      label: 'Earnings',
      iconPath: 'assets/svgs/wallet_icon.svg',
    ),
    _NavBarItemData(
      label: 'Profile',
      iconPath: 'assets/svgs/profie_icon.svg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, _items.length - 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(navBarIndexProvider.notifier).state = _currentIndex;
      loadDriverOnlinePreference(ref);
      ref.read(driverLocationServiceProvider);
      _setupNotificationSocket();
      _resumeActiveTrip();
    });
  }

  void _selectTab(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
    ref.read(navBarIndexProvider.notifier).state = index;
    if (index == 0 || index == 3) {
      ref.invalidate(userProvider);
    } else if (index == 1) {
      ref.invalidate(tripHistoryProvider);
    } else if (index == 2) {
      ref.invalidate(walletProvider);
    }
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
    ref.listen<int>(navBarIndexProvider, (previous, next) {
      if (next != _currentIndex && next >= 0 && next < _items.length) {
        _selectTab(next);
      }
    });

    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final horizontalMargin = _NavBarMetrics.horizontalMargin(context);

    return Scaffold(
      backgroundColor: kScreenBg,
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: const [HomePage(), TripsPage(), EarningPage(), ProfilePage()],
      ),
      bottomNavigationBar: Padding(
        // Figma floats ~16–25px from screen bottom; don't stack a large extra
        // gap on top of the system safe-area inset.
        padding: EdgeInsets.fromLTRB(
          horizontalMargin,
          0,
          horizontalMargin,
          bottomInset > 0 ? bottomInset : _NavBarMetrics.bottomGap,
        ),
        child: _FloatingNavBar(
          items: _items,
          currentIndex: _currentIndex,
          onItemSelected: _selectTab,
        ),
      ),
    );
  }
}

class _NavBarMetrics {
  /// Visual bar height — compact vs prior 80 which read oversized on device.
  static const double barHeight = 64;
  static const double bottomGap = 16;
  static const double activeCircleSize = 36;
  static const double activeIconSize = 20;
  static const double activeIconTextGap = 8;
  static const double inactiveSlotWidth = 64;
  static const double inactiveIconSize = 24;

  static double horizontalMargin(BuildContext context) {
    return (MediaQuery.sizeOf(context).width * (16 / 393)).clamp(16.0, 24.0);
  }
}

class _NavBarItemData {
  const _NavBarItemData({
    required this.label,
    required this.iconPath,
  });

  final String label;
  final String iconPath;
}

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({
    required this.items,
    required this.currentIndex,
    required this.onItemSelected,
  });

  final List<_NavBarItemData> items;
  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: Container(
        height: _NavBarMetrics.barHeight,
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(100),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 15.3,
              offset: Offset.zero,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = currentIndex == index;

            if (isSelected) {
              return Flexible(
                fit: FlexFit.loose,
                child: _ActiveNavPill(
                  item: item,
                  onTap: () => onItemSelected(index),
                ),
              );
            }

            return SizedBox(
              width: _NavBarMetrics.inactiveSlotWidth,
              height: _NavBarMetrics.barHeight,
              child: _InactiveTabIcon(
                item: item,
                onTap: () => onItemSelected(index),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _ActiveNavPill extends StatelessWidget {
  const _ActiveNavPill({required this.item, required this.onTap});

  final _NavBarItemData item;
  final VoidCallback onTap;

  static const _labelStyle = TextStyle(
    fontFamily: 'ClashGrotesk',
    fontWeight: FontWeight.w600,
    fontSize: 12,
    color: kWhite,
    height: 1.0,
    letterSpacing: 0.12,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(100),
          child: Container(
            padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
            decoration: BoxDecoration(
              color: kBrandBlue,
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: kBrandBlue.withValues(alpha: 0.25),
                  blurRadius: 2,
                  offset: Offset.zero,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: _NavBarMetrics.activeCircleSize,
                  width: _NavBarMetrics.activeCircleSize,
                  decoration: BoxDecoration(
                    color: kFigmaNeutral.withValues(alpha: 0.15),
                    border: Border.all(
                      color: kWhite.withValues(alpha: 0.13),
                      width: 0.63,
                    ),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  // White SVG — matches Figma (colored GIFs were washing the pill).
                  child: SvgPicture.asset(
                    item.iconPath,
                    width: _NavBarMetrics.activeIconSize,
                    height: _NavBarMetrics.activeIconSize,
                    fit: BoxFit.contain,
                    colorFilter: const ColorFilter.mode(
                      kWhite,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(width: _NavBarMetrics.activeIconTextGap),
                Flexible(
                  child: Text(
                    item.label,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: _labelStyle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InactiveTabIcon extends StatelessWidget {
  const _InactiveTabIcon({required this.item, required this.onTap});

  final _NavBarItemData item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Center(
        child: SvgPicture.asset(
          item.iconPath,
          width: _NavBarMetrics.inactiveIconSize,
          height: _NavBarMetrics.inactiveIconSize,
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
