import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/interfaces/components/primarybutton.dart';
import 'package:flutter/material.dart';

const _kNavigateBlue = Color(0xFF205D91);
const _kShortTripBadgeBg = Color(0xFFF3F4EE);
const _kDropPinBlue = Color(0xFF2B74E1);
const _kScheduledBadgeBg = Color(0xFFFFF3E8);
const _kScheduledBadgeText = Color(0xFFC6934B);
const _kCompletedBadgeBg = Color(0xFFE8F2FA);
const _kCompletedBadgeText = Color(0xFF2B74E1);
const _kCancelledBadgeBg = Color(0xFFFEECEC);
const _kCancelledBadgeText = Color(0xFFE32626);

enum TripCardStatus { ongoing, upcoming, completed, cancelled }

enum TripRouteStyle { standard, cancelledBolt }

class TripLocationInfo {
  const TripLocationInfo({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}

class TripStatInfo {
  const TripStatInfo({required this.label, required this.value});

  final String label;
  final String value;
}

class TripCardData {
  const TripCardData({
    required this.status,
    required this.pickup,
    required this.drop,
    required this.buttonLabel,
    this.tripTypeLabel = 'SHORT TRIP',
    this.dateLabel,
    this.completedAtLabel,
    this.earningsAmount,
    this.statusPillLabel,
    this.infoRowText,
    this.countdownPrefix,
    this.countdownValue,
    this.stats = const [],
    this.totalEarned,
    this.routeStyle = TripRouteStyle.standard,
    this.buttonIcon,
  });

  final TripCardStatus status;
  final String tripTypeLabel;
  final String? dateLabel;
  final String? completedAtLabel;
  final TripLocationInfo pickup;
  final TripLocationInfo drop;
  final String? earningsAmount;
  final String? statusPillLabel;
  final String? infoRowText;
  final String? countdownPrefix;
  final String? countdownValue;
  final List<TripStatInfo> stats;
  final String? totalEarned;
  final String buttonLabel;
  final Widget? buttonIcon;
  final TripRouteStyle routeStyle;

  static const _defaultStats = [
    TripStatInfo(label: 'Distance', value: '12 km'),
    TripStatInfo(label: 'Duration', value: '2 hrs'),
    TripStatInfo(label: 'Vehicle Type', value: 'Manual'),
  ];

  static TripCardData dummyOngoing() {
    return const TripCardData(
      status: TripCardStatus.ongoing,
      pickup: TripLocationInfo(
        title: 'Edappally, Lulu Mall',
        subtitle: 'Pickup, 12 km away',
      ),
      drop: TripLocationInfo(
        title: 'Infopark, Kakkanad',
        subtitle: 'Drop, 20 km away',
      ),
      earningsAmount: '₹ 235',
      statusPillLabel: 'Heading to pickup',
      infoRowText: '10 mins to pickup • 3 km away',
      buttonLabel: 'Navigate',
      buttonIcon: _NavigateButtonIcon(),
    );
  }

  static TripCardData dummyUpcoming() {
    return const TripCardData(
      status: TripCardStatus.upcoming,
      dateLabel: 'Date : April 30, 09:00 AM',
      pickup: TripLocationInfo(
        title: 'Edappally, Lulu Mall',
        subtitle: 'Pickup Location',
      ),
      drop: TripLocationInfo(
        title: 'Infopark, Kakkanad',
        subtitle: 'Drop Location',
      ),
      earningsAmount: '₹ 235',
      stats: _defaultStats,
      countdownPrefix: 'Starts in ',
      countdownValue: '12 hrs 20 min',
      buttonLabel: 'View Trip Details',
    );
  }

  static TripCardData dummyCompleted() {
    return const TripCardData(
      status: TripCardStatus.completed,
      dateLabel: 'Date : April 30, 09:00 AM',
      completedAtLabel: 'Completed at : 11:05 AM',
      pickup: TripLocationInfo(
        title: 'Edappally, Lulu Mall',
        subtitle: 'Pickup Location',
      ),
      drop: TripLocationInfo(
        title: 'Infopark, Kakkanad',
        subtitle: 'Drop Location',
      ),
      stats: _defaultStats,
      totalEarned: '₹ 2,035',
      buttonLabel: 'View Trip Details',
    );
  }

  static TripCardData dummyCancelled() {
    return const TripCardData(
      status: TripCardStatus.cancelled,
      dateLabel: 'Date : April 30, 09:00 AM',
      pickup: TripLocationInfo(
        title: 'Edappally, Lulu Mall',
        subtitle: 'Pickup Location',
      ),
      drop: TripLocationInfo(
        title: 'Infopark, Kakkanad',
        subtitle: 'Drop Location',
      ),
      stats: _defaultStats,
      routeStyle: TripRouteStyle.cancelledBolt,
      buttonLabel: 'View Trip Details',
    );
  }
}

class _NavigateButtonIcon extends StatelessWidget {
  const _NavigateButtonIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      width: 28,
      decoration: const BoxDecoration(color: kWhite, shape: BoxShape.circle),
      child: const Icon(
        Icons.navigation_rounded,
        size: 16,
        color: _kNavigateBlue,
      ),
    );
  }
}

class TripCard extends StatelessWidget {
  const TripCard({
    super.key,
    required this.data,
    this.onButtonPressed,
    this.onMenuPressed,
  });

  final TripCardData data;
  final VoidCallback? onButtonPressed;
  final VoidCallback? onMenuPressed;

  bool get _showDateRow =>
      data.dateLabel != null || data.completedAtLabel != null;

  bool get _showEarningsColumn => data.earningsAmount != null;

  bool get _showStats => data.stats.isNotEmpty;

  bool get _showDividerBeforeStats =>
      data.status == TripCardStatus.upcoming ||
      data.status == TripCardStatus.completed ||
      data.status == TripCardStatus.cancelled;

  bool get _showDividerAfterStats =>
      data.status == TripCardStatus.completed ||
      data.status == TripCardStatus.cancelled;

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
          _TripCardHeader(
            status: data.status,
            tripTypeLabel: data.tripTypeLabel,
            onMenuPressed: onMenuPressed,
          ),
          if (_showDateRow) ...[
            const SizedBox(height: 12),
            _TripDateTimeRow(
              dateLabel: data.dateLabel,
              completedAtLabel: data.completedAtLabel,
            ),
          ] else
            const SizedBox(height: 16),
          if (_showDateRow) const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TripRouteTimeline(style: data.routeStyle),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TripLocationBlock(
                      title: data.pickup.title,
                      subtitle: data.pickup.subtitle,
                    ),
                    const SizedBox(height: 18),
                    _TripLocationBlock(
                      title: data.drop.title,
                      subtitle: data.drop.subtitle,
                    ),
                  ],
                ),
              ),
              if (_showEarningsColumn) ...[
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      data.earningsAmount!,
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
            ],
          ),
          if (data.statusPillLabel != null) ...[
            const SizedBox(height: 14),
            _OngoingStatusPill(label: data.statusPillLabel!),
          ],
          if (data.status == TripCardStatus.ongoing &&
              data.infoRowText != null) ...[
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
                  data.infoRowText!,
                  style: kCaption13R.copyWith(
                    color: kActiveGreen,
                    fontWeight: kMedium,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ],
          if (_showDividerBeforeStats) ...[
            const SizedBox(height: 14),
            const _DashedDivider(),
            const SizedBox(height: 14),
          ],
          if (_showStats) _TripStatsRow(stats: data.stats),
          if (data.countdownValue != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  height: 22,
                  width: 22,
                  decoration: BoxDecoration(
                    color: kActiveGreenBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: kActiveGreen,
                  ),
                ),
                const SizedBox(width: 8),
                RichText(
                  text: TextSpan(
                    style: kCaption13R.copyWith(
                      color: kActiveGreen,
                      fontWeight: kMedium,
                      height: 1.2,
                    ),
                    children: [
                      TextSpan(text: data.countdownPrefix ?? 'Starts in '),
                      TextSpan(
                        text: data.countdownValue,
                        style: kCaption13SB.copyWith(color: kActiveGreen),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          if (_showDividerAfterStats) ...[
            const SizedBox(height: 14),
            const _DashedDivider(),
            const SizedBox(height: 14),
          ],
          if (data.totalEarned != null)
            Row(
              children: [
                Text('Total Earned', style: kCaption14B),
                const Spacer(),
                Text(
                  data.totalEarned!,
                  style: kStyle(
                    kSemiBold,
                    kSize18,
                    color: _kNavigateBlue,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          primaryButton(
            label: data.buttonLabel,
            buttonHeight: 52,
            fontSize: kSize16,
            buttonColor: _kNavigateBlue,
            labelColor: kWhite,
            icon: data.buttonIcon,
            onPressed: onButtonPressed,
          ),
        ],
      ),
    );
  }
}

class _TripCardHeader extends StatelessWidget {
  const _TripCardHeader({
    required this.status,
    required this.tripTypeLabel,
    this.onMenuPressed,
  });

  final TripCardStatus status;
  final String tripTypeLabel;
  final VoidCallback? onMenuPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatusBadge(status: status),
        const SizedBox(width: 8),
        _ShortTripBadge(label: tripTypeLabel),
        const Spacer(),
        IconButton(
          onPressed: onMenuPressed,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(
            Icons.more_horiz_rounded,
            color: kTextColor,
            size: 22,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final TripCardStatus status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case TripCardStatus.ongoing:
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
              Text('NOW', style: kTripBadgeSB),
            ],
          ),
        );
      case TripCardStatus.upcoming:
        return _DotStatusBadge(
          label: 'SCHEDULED',
          backgroundColor: _kScheduledBadgeBg,
          dotColor: _kScheduledBadgeText,
          textColor: _kScheduledBadgeText,
        );
      case TripCardStatus.completed:
        return _DotStatusBadge(
          label: 'COMPLETED',
          backgroundColor: _kCompletedBadgeBg,
          dotColor: _kCompletedBadgeText,
          textColor: _kCompletedBadgeText,
        );
      case TripCardStatus.cancelled:
        return _DotStatusBadge(
          label: 'CANCELLED',
          backgroundColor: _kCancelledBadgeBg,
          dotColor: _kCancelledBadgeText,
          textColor: _kCancelledBadgeText,
        );
    }
  }
}

class _DotStatusBadge extends StatelessWidget {
  const _DotStatusBadge({
    required this.label,
    required this.backgroundColor,
    required this.dotColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color dotColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 6,
            width: 6,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: kStyle(kSemiBold, kSize11, color: textColor, height: 1.1),
          ),
        ],
      ),
    );
  }
}

class _ShortTripBadge extends StatelessWidget {
  const _ShortTripBadge({required this.label});

  final String label;

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
            label,
            style: kStyle(kMedium, kSize11, color: kTextColor, height: 1.1),
          ),
        ],
      ),
    );
  }
}

class _TripDateTimeRow extends StatelessWidget {
  const _TripDateTimeRow({this.dateLabel, this.completedAtLabel});

  final String? dateLabel;
  final String? completedAtLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (dateLabel != null)
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 15,
                color: kMutedText.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 6),
              Text(
                dateLabel!,
                style: kCaption13R.copyWith(
                  color: kTripBodyMuted,
                  fontWeight: kMedium,
                  height: 1.2,
                ),
              ),
            ],
          ),
        if (completedAtLabel != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 15,
                color: kMutedText.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 6),
              Text(
                completedAtLabel!,
                style: kCaption13R.copyWith(
                  color: kTripBodyMuted,
                  fontWeight: kMedium,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _TripRouteTimeline extends StatelessWidget {
  const _TripRouteTimeline({required this.style});

  final TripRouteStyle style;

  @override
  Widget build(BuildContext context) {
    if (style == TripRouteStyle.cancelledBolt) {
      return SizedBox(
        width: 20,
        child: Column(
          children: [
            Container(
              height: 20,
              width: 20,
              decoration: const BoxDecoration(
                color: kActiveGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bolt_rounded, size: 12, color: kWhite),
            ),
            const SizedBox(height: 4),
            Container(height: 52, width: 1.5, color: kLineGrey),
            const SizedBox(height: 4),
            const Icon(Icons.location_on, size: 20, color: _kDropPinBlue),
          ],
        ),
      );
    }

    return SizedBox(
      width: 18,
      child: Column(
        children: [
          const Icon(Icons.location_on, size: 20, color: kActiveGreen),
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
          const Icon(Icons.location_on, size: 20, color: _kDropPinBlue),
        ],
      ),
    );
  }
}

class _TripLocationBlock extends StatelessWidget {
  const _TripLocationBlock({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: kCaption14B),
        const SizedBox(height: 2),
        Text(subtitle, style: kCaption12R.copyWith(color: kMutedText)),
      ],
    );
  }
}

class _OngoingStatusPill extends StatelessWidget {
  const _OngoingStatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            label,
            style: kStyle(kMedium, kSize13, color: kWhite, height: 1.1),
          ),
        ],
      ),
    );
  }
}

class _TripStatsRow extends StatelessWidget {
  const _TripStatsRow({required this.stats});

  final List<TripStatInfo> stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: stats
          .map(
            (stat) => Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stat.label,
                    style: kCaption12R.copyWith(color: kMutedText),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stat.value,
                    style: kStyle(
                      kSemiBold,
                      kSize14,
                      color: _kNavigateBlue,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
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
        painter: _DottedLinePainter(
          color: kLineGrey,
          direction: Axis.horizontal,
        ),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  _DottedLinePainter({required this.color, required this.direction});

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
        canvas.drawLine(
          Offset(startX, y),
          Offset(startX + dashWidth, y),
          paint,
        );
        startX += dashWidth + dashSpace;
      }
    } else {
      double startY = 0;
      final x = size.width / 2;
      while (startY < size.height) {
        canvas.drawLine(
          Offset(x, startY),
          Offset(x, startY + dashWidth),
          paint,
        );
        startY += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DottedLinePainter oldDelegate) => false;
}
