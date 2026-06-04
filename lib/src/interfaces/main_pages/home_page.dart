import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

const _kHomeHeaderBlue = Color(0xFF1E5C8D);
const _kHomeHeaderButtonBlue = Color(0xFF2A6FA3);
const _kOnlineCardBg = Color(0xFF1A4F75);
const _kPromoCardBg = Color(0xFFFEFAF2);

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
              top: MediaQuery.sizeOf(context).height * 0.28,
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
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    child: Column(
                      children: [
                        const _TodaysEarningsCard(),
                        const SizedBox(height: 14),
                        _TripPreferenceCard(
                          isShortTrip: _isShortTrip,
                          onChanged: (isShort) =>
                              setState(() => _isShortTrip = isShort),
                        ),
                        const SizedBox(height: 14),
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
  const _HomeHeader({
    required this.isOnline,
    required this.onOnlineChanged,
  });

  final bool isOnline;
  final ValueChanged<bool> onOnlineChanged;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return ClipPath(
      clipper: _HomeHeaderClipper(),
      child: Container(
        color: _kHomeHeaderBlue,
        padding: EdgeInsets.fromLTRB(20, topPadding + 12, 20, 28),
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
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: kWhite,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Edappally, Lulu Mall',
                              style: kCaption14R.copyWith(
                                color: kWhite.withValues(alpha: 0.92),
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
                  height: 44,
                  width: 44,
                  decoration: const BoxDecoration(
                    color: _kHomeHeaderButtonBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: kWhite,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _OnlineStatusCard(
              isOnline: isOnline,
              onChanged: onOnlineChanged,
            ),
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
    path.lineTo(size.width, size.height - 24);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height + 18,
      0,
      size.height - 24,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _OnlineStatusCard extends StatelessWidget {
  const _OnlineStatusCard({
    required this.isOnline,
    required this.onChanged,
  });

  final bool isOnline;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _kOnlineCardBg.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Image.asset(
                  'assets/pngs/live_photo_image.png',
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  height: 14,
                  width: 14,
                  decoration: BoxDecoration(
                    color: isOnline ? kActiveGreen : kMutedText,
                    shape: BoxShape.circle,
                    border: Border.all(color: kWhite, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You are Online',
                  style: kStyle(
                    kSemiBold,
                    kSize16,
                    color: kWhite,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Ready to accept orders',
                  style: kCaption13R.copyWith(
                    color: kWhite.withValues(alpha: 0.75),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isOnline,
            onChanged: onChanged,
            activeThumbColor: kWhite,
            activeTrackColor: kOrange,
            inactiveThumbColor: kWhite,
            inactiveTrackColor: kMutedText,
          ),
        ],
      ),
    );
  }
}

class _TodaysEarningsCard extends StatelessWidget {
  const _TodaysEarningsCard();

  static const _barHeights = [0.35, 0.55, 0.42, 0.78, 0.5, 0.68];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kBlack.withValues(alpha: 0.06),
            blurRadius: 16,
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
                height: 44,
                width: 44,
                decoration: const BoxDecoration(
                  color: kBrandBlue,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assets/svgs/wallet_icon.svg',
                  width: 22,
                  height: 18,
                  colorFilter: const ColorFilter.mode(
                    kWhite,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Today's Earnings",
                  style: kTripSubSectionSB,
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: kChevronGrey,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 14),
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
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: kActiveGreenBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '+ ₹ 235 Bonus',
                        style: kTripBadgeSB,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 56,
                width: 88,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _barHeights
                      .map(
                        (h) => Container(
                          width: 10,
                          height: 56 * h,
                          decoration: BoxDecoration(
                            color: kBrandBlue.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(4),
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kBlack.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Trip Preference', style: kTripSubSectionSB),
          const SizedBox(height: 14),
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
              const SizedBox(width: 12),
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
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                size: 16,
                color: kActiveGreen,
              ),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? kGoldAccent : kCardBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: iconColor),
            const SizedBox(height: 8),
            Text(
              title,
              style: kCaption14B,
              textAlign: TextAlign.center,
            ),
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kGoldAccent.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: kBlack.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            bottom: 0,
            top: 0,
            child: Image.asset(
              'assets/pngs/car_image.png',
              fit: BoxFit.contain,
              alignment: Alignment.centerRight,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 120, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Drive More. Earn More!',
                  style: kCaption14B.copyWith(fontSize: kSize16),
                ),
                const SizedBox(height: 6),
                Text(
                  'Complete 20 trips this week and get 1,000 extra',
                  style: kCaption13R.copyWith(
                    color: kSecondaryTextColor,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
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
