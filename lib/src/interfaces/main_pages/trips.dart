import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/interfaces/components/primarybutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _kTripsStatusBarBlue = Color(0xFF1A5288);
const _kTripsPageBg = Color(0xFFF8FAF5);
const _kTabActiveGold = Color(0xFFC19A6B);
const _kNavigateBlue = Color(0xFF205D91);
const _kShortTripBadgeBg = Color(0xFFF3F4EE);
const _kDropPinBlue = Color(0xFF2B74E1);

enum _TripTab { ongoing, upcoming, completed, cancelled }

class TripsPage extends StatefulWidget {
  const TripsPage({super.key});

  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  _TripTab _selectedTab = _TripTab.ongoing;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: _kTripsStatusBarBlue,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _kTripsPageBg,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ColoredBox(
              color: _kTripsStatusBarBlue,
              child: SafeArea(
                bottom: false,
                child: const SizedBox(height: 0),
              ),
            ),
            _TripsTabBar(
              selectedTab: _selectedTab,
              onTabSelected: (tab) => setState(() => _selectedTab = tab),
            ),
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case _TripTab.ongoing:
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: const [
            _OngoingTripCard(),
          ],
        );
      case _TripTab.upcoming:
      case _TripTab.completed:
      case _TripTab.cancelled:
        return Center(
          child: Text(
            'No ${_tabLabel(_selectedTab).toLowerCase()} trips',
            style: kCaption14R.copyWith(color: kMutedText),
          ),
        );
    }
  }

  String _tabLabel(_TripTab tab) {
    switch (tab) {
      case _TripTab.ongoing:
        return 'Ongoing';
      case _TripTab.upcoming:
        return 'Upcoming';
      case _TripTab.completed:
        return 'Completed';
      case _TripTab.cancelled:
        return 'Cancelled';
    }
  }
}

class _TripsTabBar extends StatelessWidget {
  const _TripsTabBar({
    required this.selectedTab,
    required this.onTabSelected,
  });

  final _TripTab selectedTab;
  final ValueChanged<_TripTab> onTabSelected;

  static const _tabs = _TripTab.values;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kWhite,
        border: Border(
          bottom: BorderSide(color: kCardBorder, width: 1),
        ),
      ),
      child: Row(
        children: _tabs.map((tab) {
          final isSelected = selectedTab == tab;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(tab),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _labelFor(tab),
                      style: kStyle(
                        isSelected ? kSemiBold : kMedium,
                        kSize14,
                        color: isSelected ? _kTabActiveGold : kTextColor,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      height: 2,
                      width: isSelected ? 28 : 0,
                      decoration: BoxDecoration(
                        color: _kTabActiveGold,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _labelFor(_TripTab tab) {
    switch (tab) {
      case _TripTab.ongoing:
        return 'Ongoing';
      case _TripTab.upcoming:
        return 'Upcoming';
      case _TripTab.completed:
        return 'Completed';
      case _TripTab.cancelled:
        return 'Cancelled';
    }
  }
}

class _OngoingTripCard extends StatelessWidget {
  const _OngoingTripCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kBlack.withValues(alpha: 0.05),
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
              _NowBadge(),
              const SizedBox(width: 8),
              _ShortTripBadge(),
              const Spacer(),
              IconButton(
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  color: kTextColor,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _RouteTimeline(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _LocationBlock(
                      title: 'Edappally, Lulu Mall',
                      subtitle: 'Pickup, 12 km away',
                    ),
                    const SizedBox(height: 18),
                    const _LocationBlock(
                      title: 'Infopark, Kakkanad',
                      subtitle: 'Drop, 20 km away',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹ 235',
                    style: kStyle(
                      kSemiBold,
                      kSize26,
                      color: _kNavigateBlue,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'you earn',
                    style: kCaption12R.copyWith(color: kMutedText),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: kActiveGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 20,
                  width: 20,
                  decoration: const BoxDecoration(
                    color: kWhite,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    size: 14,
                    color: kActiveGreen,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Heading to pickup',
                  style: kStyle(
                    kMedium,
                    kSize13,
                    color: kWhite,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const _DashedDivider(),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 16,
                color: kActiveGreen,
              ),
              const SizedBox(width: 6),
              Text(
                '10 mins to pickup • 3 km away',
                style: kCaption13R.copyWith(
                  color: kActiveGreen,
                  fontWeight: kMedium,
                  height: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          primaryButton(
            label: 'Navigate',
            buttonHeight: 52,
            fontSize: kSize16,
            buttonColor: _kNavigateBlue,
            labelColor: kWhite,
            icon: Container(
              height: 28,
              width: 28,
              decoration: const BoxDecoration(
                color: kWhite,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.navigation_rounded,
                size: 16,
                color: _kNavigateBlue,
              ),
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _NowBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: kActiveGreenBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 6,
            width: 6,
            decoration: const BoxDecoration(
              color: kActiveGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'NOW',
            style: kTripBadgeSB,
          ),
        ],
      ),
    );
  }
}

class _ShortTripBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _kShortTripBadgeBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.sync_alt_rounded,
            size: 14,
            color: kTextColor.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 5),
          Text(
            'SHORT TRIP',
            style: kStyle(
              kMedium,
              kSize11,
              color: kTextColor,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteTimeline extends StatelessWidget {
  const _RouteTimeline();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      child: Column(
        children: [
          Icon(Icons.location_on, size: 20, color: kActiveGreen),
          const SizedBox(height: 4),
          SizedBox(
            height: 52,
            child: CustomPaint(
              painter: _DottedLinePainter(
                color: kLineGrey,
                direction: Axis.vertical,
              ),
              size: const Size(2, 52),
            ),
          ),
          const SizedBox(height: 4),
          Icon(Icons.location_on, size: 20, color: _kDropPinBlue),
        ],
      ),
    );
  }
}

class _LocationBlock extends StatelessWidget {
  const _LocationBlock({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: kCaption14B),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: kCaption12R.copyWith(color: kMutedText),
        ),
      ],
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 1,
      child: CustomPaint(
        painter: _DottedLinePainter(color: kLineGrey, direction: Axis.horizontal),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  _DottedLinePainter({
    required this.color,
    required this.direction,
  });

  final Color color;
  final Axis direction;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 4.0;
    const dashSpace = 4.0;

    if (direction == Axis.horizontal) {
      double startX = 0;
      final y = size.height / 2;
      while (startX < size.width) {
        canvas.drawLine(Offset(startX, y), Offset(startX + dashWidth, y), paint);
        startX += dashWidth + dashSpace;
      }
    } else {
      double startY = 0;
      final x = size.width / 2;
      while (startY < size.height) {
        canvas.drawLine(Offset(x, startY), Offset(x, startY + dashWidth), paint);
        startY += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DottedLinePainter oldDelegate) => false;
}
