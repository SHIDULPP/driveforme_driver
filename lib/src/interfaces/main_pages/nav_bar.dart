import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/home_page.dart';
import 'package:driveforme_driver/src/data/providers/wallet_provider.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/earning.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/profile_page.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/trips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NavBar extends ConsumerStatefulWidget {
  const NavBar({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  ConsumerState<NavBar> createState() => _NavBarState();
}

class _NavBarState extends ConsumerState<NavBar> {
  late int _currentIndex;

  static const _items = <_NavBarItemData>[
    _NavBarItemData(
      label: 'Home',
      iconPath: 'assets/svgs/home_icon.svg',
      iconWidth: 23,
      iconHeight: 24,
    ),
    _NavBarItemData(
      label: 'Trips',
      iconPath: 'assets/svgs/trips_icon.svg',
      iconWidth: 20,
      iconHeight: 25,
    ),
    _NavBarItemData(
      label: 'Earnings',
      iconPath: 'assets/svgs/wallet_icon.svg',
      iconWidth: 26,
      iconHeight: 21,
    ),
    _NavBarItemData(
      label: 'Profile',
      iconPath: 'assets/svgs/profie_icon.svg',
      iconWidth: 25,
      iconHeight: 25,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, _items.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScreenBg,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomePage(),
          TripsPage(),
          EarningPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: _FloatingNavBar(
          items: _items,
          currentIndex: _currentIndex,
          onItemSelected: (index) {
            if (_currentIndex != index) {
              setState(() => _currentIndex = index);
              if (index == 2) {
                ref.invalidate(walletProvider);
              }
            }
          },
        ),
      ),
    );
  }
}

class _NavBarItemData {
  const _NavBarItemData({
    required this.label,
    required this.iconPath,
    required this.iconWidth,
    required this.iconHeight,
  });

  final String label;
  final String iconPath;
  final double iconWidth;
  final double iconHeight;
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
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: kBlack.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          return Expanded(
            child: _NavBarTab(
              item: items[index],
              isSelected: currentIndex == index,
              onTap: () => onItemSelected(index),
            ),
          );
        }),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 10 : 4,
            vertical: isSelected ? 4 : 6,
          ),
          decoration: BoxDecoration(
            color: isSelected ? kBrandBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Center(
            child: isSelected
                ? FittedBox(
                    fit: BoxFit.scaleDown,
                    child: _ActiveTabContent(item: item),
                  )
                : _InactiveTabIcon(item: item),
          ),
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            color: kWhite.withValues(alpha: 0.22),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            item.iconPath,
            width: item.iconWidth,
            height: item.iconHeight,
            fit: BoxFit.contain,
            colorFilter: const ColorFilter.mode(kWhite, BlendMode.srcIn),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          item.label,
          style: kStyle(kSemiBold, kSize14, color: kWhite, height: 1.1),
        ),
      ],
    );
  }
}

class _InactiveTabIcon extends StatelessWidget {
  const _InactiveTabIcon({required this.item});

  final _NavBarItemData item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: 40,
      child: Center(
        child: SvgPicture.asset(
          item.iconPath,
          width: item.iconWidth,
          height: item.iconHeight,
          fit: BoxFit.contain,
          colorFilter: const ColorFilter.mode(kMutedText, BlendMode.srcIn),
        ),
      ),
    );
  }
}
