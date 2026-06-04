import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

const _kHomeHeaderBlue = Color(0xFF1A5288);
const _kHomeHeaderButtonBlue = Color(0xFF2B6A9A);
const _kOnlineCardBg = Color(0xFF164A72);
const _kPromoCardBg = Color(0xFFFEFAF2);
const _kTripSelectedBg = Color(0xFFFFF6EB);
const _kToggleOrange = Color(0xFFF2994A);
const _kEarningsBarBlue = Color(0xFF1E5C8D);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isOnline = true;
  bool _isShortTrip = true;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: kScreenBg,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: MediaQuery.sizeOf(context).height * 0.24,
              left: 0,
              right: 0,
              bottom: 0,
              child: Image.asset(
                'assets/pngs/map_image.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HomeHeader(
                  isOnline: _isOnline,
                  onOnlineChanged: (value) => setState(() => _isOnline = value),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    child: Column(
                      children: [
                        const _TodaysEarningsCard(),
                        const SizedBox(height: 12),
                        _TripPreferenceCard(
                          isShortTrip: _isShortTrip,
                          onChanged: (isShort) =>
                              setState(() => _isShortTrip = isShort),
                        ),
                        const SizedBox(height: 12),
                        const _PromoBannerCard(),
                      ],
                    ),
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

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.isOnline, required this.onOnlineChanged});

  final bool isOnline;
  final ValueChanged<bool> onOnlineChanged;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return ClipPath(
      clipper: _HomeHeaderClipper(),
      child: Container(
        color: _kHomeHeaderBlue,
        padding: EdgeInsets.fromLTRB(20, topPadding + 8, 20, 32),
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
                        'Hii Kumar!',
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
                              'Edappally, Lulu Mall',
                              style: kCaption14R.copyWith(
                                color: kWhite.withValues(alpha: 0.85),
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: _kHomeHeaderButtonBlue.withValues(alpha: 0.85),
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
            const SizedBox(height: 16),
            _OnlineStatusCard(isOnline: isOnline, onChanged: onOnlineChanged),
          ],
        ),
      ),
    );
  }
}

class _HomeHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - 28);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height + 22,
      0,
      size.height - 28,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
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
        color: _kOnlineCardBg.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14),
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
                  'Ready to accept orders',
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kBlack.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 40,
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
                  colorFilter: const ColorFilter.mode(kWhite, BlendMode.srcIn),
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
          Row(
            children: [
              Expanded(
                child: _TripOptionTile(
                  title: 'Short Trip',
                  subtitle: 'Within City',
                  icon: Icons.directions_car_filled_rounded,
                  iconColor: kRed,
                  isSelected: isShortTrip,
                  onTap: () => onChanged(true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TripOptionTile(
                  title: 'Long Trip',
                  subtitle: 'Outstation',
                  icon: Icons.add_road_rounded,
                  iconColor: kActiveGreen,
                  isSelected: !isShortTrip,
                  onTap: () => onChanged(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle, size: 15, color: kActiveGreen),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'You will recieve requestes based on your preferences',
                  style: kCaption12R.copyWith(
                    color: kSecondaryTextColor,
                    height: 1.35,
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
    required this.icon,
    required this.iconColor,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? _kTripSelectedBg : kWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? kGoldAccent : kCardBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: iconColor),
            const SizedBox(height: 6),
            Text(title, style: kCaption14B, textAlign: TextAlign.center),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: kCaption12R.copyWith(color: kMutedText),
              textAlign: TextAlign.center,
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
