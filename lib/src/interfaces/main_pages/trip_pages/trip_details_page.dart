import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/interfaces/components/primarybutton.dart';
import 'package:driveforme_driver/src/interfaces/components/trip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _kPageBg = Color(0xFFF8FAF5);
const _kNavigateBlue = Color(0xFF205D91);
const _kShortTripBadgeBg = Color(0xFFF3F4EE);
const _kDropPinBlue = Color(0xFF2B74E1);
const _kScheduledBadgeBg = Color(0xFFFFF3E8);
const _kScheduledBadgeText = Color(0xFFC6934B);
const _kCompletedBadgeBg = Color(0xFFE8F2FA);
const _kCompletedBadgeText = Color(0xFF2B74E1);
const _kCancelledBadgeBg = Color(0xFFFEECEC);
const _kCancelledBadgeText = Color(0xFFE32626);
const _kInvoiceButtonBg = Color(0xFFE6EEF5);
const _kChatGreen = Color(0xFF17A34A);
const _kCallBlue = Color(0xFF4A9FD4);

class TripTicketInfo {
  const TripTicketInfo({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  static const dummy = TripTicketInfo(
    title: 'Passenger not reachable at pickup',
    description:
        'I reached the pickup location but the passenger was not responding '
        'to calls or messages. I waited for more than 10 minutes. Please '
        'advise if this should be marked as a no-show.',
  );
}

class TripDetailsPage extends StatelessWidget {
  const TripDetailsPage({
    super.key,
    required this.trip,
    this.ticket,
  });

  final TripCardData trip;
  final TripTicketInfo? ticket;

  bool get _showBottomActions =>
      trip.status == TripCardStatus.completed ||
      trip.status == TripCardStatus.cancelled;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: _kPageBg,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _kPageBg,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _TripDetailsHeader(),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    8,
                    20,
                    _showBottomActions ? 16 : 24,
                  ),
                  children: [
                    _TripDetailsCard(trip: trip),
                    if (ticket != null) ...[
                      const SizedBox(height: 12),
                      _TripTicketCard(ticket: ticket!),
                    ],
                  ],
                ),
              ),
              if (_showBottomActions) const _TripDetailsBottomActions(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TripDetailsHeader extends StatelessWidget {
  const _TripDetailsHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: kTextColor,
            ),
          ),
          Expanded(
            child: Text(
              'Trip Details',
              textAlign: TextAlign.center,
              style: kStyle(kSemiBold, kSize18, color: kTextColor, height: 1.2),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.ios_share_rounded,
              size: 22,
              color: kTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _TripDetailsCard extends StatelessWidget {
  const _TripDetailsCard({required this.trip});

  final TripCardData trip;

  bool get _showEarningsColumn =>
      trip.status == TripCardStatus.upcoming && trip.earningsAmount != null;

  bool get _showMenu =>
      trip.status == TripCardStatus.completed ||
      trip.status == TripCardStatus.cancelled;

  bool get _showCountdown =>
      trip.status == TripCardStatus.upcoming && trip.countdownValue != null;

  bool get _showCancelButton => trip.status == TripCardStatus.upcoming;

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
              _StatusBadge(status: trip.status),
              const SizedBox(width: 8),
              _ShortTripBadge(label: trip.tripTypeLabel),
              if (_showMenu) ...[
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
            ],
          ),
          if (trip.dateLabel != null || trip.completedAtLabel != null) ...[
            const SizedBox(height: 12),
            _DateTimeRow(
              dateLabel: trip.dateLabel,
              completedAtLabel: trip.completedAtLabel,
            ),
          ],
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TripRouteTimeline(style: trip.routeStyle),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LocationBlock(
                      title: trip.pickup.title,
                      subtitle: trip.pickup.subtitle,
                    ),
                    const SizedBox(height: 18),
                    _LocationBlock(
                      title: trip.drop.title,
                      subtitle: trip.drop.subtitle,
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
                      trip.earningsAmount!,
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
          if (trip.stats.isNotEmpty) ...[
            const SizedBox(height: 14),
            const _DashedDivider(),
            const SizedBox(height: 14),
            _TripStatsRow(stats: trip.stats),
          ],
          const SizedBox(height: 14),
          const _CustomerProfileCard(),
          if (_showCountdown) ...[
            const SizedBox(height: 12),
            _CountdownRow(
              prefix: trip.countdownPrefix ?? 'Starts in ',
              value: trip.countdownValue!,
            ),
          ],
          if (trip.totalEarned != null) ...[
            const SizedBox(height: 14),
            const _DashedDivider(),
            const SizedBox(height: 14),
            Row(
              children: [
                Text('Total Earned', style: kCaption14B),
                const Spacer(),
                Text(
                  trip.totalEarned!,
                  style: kStyle(
                    kSemiBold,
                    kSize18,
                    color: _kNavigateBlue,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ],
          if (_showCancelButton) ...[
            const SizedBox(height: 16),
            primaryButton(
              label: 'Cancel trip',
              buttonHeight: 52,
              fontSize: kSize16,
              buttonColor: kWhite,
              sideColor: kRed,
              labelColor: kRed,
              onPressed: () {},
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final TripCardStatus status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
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
      case TripCardStatus.ongoing:
        return _DotStatusBadge(
          label: 'NOW',
          backgroundColor: kActiveGreenBg,
          dotColor: kActiveGreen,
          textColor: kActiveGreen,
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

class _DateTimeRow extends StatelessWidget {
  const _DateTimeRow({this.dateLabel, this.completedAtLabel});

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

class _LocationBlock extends StatelessWidget {
  const _LocationBlock({required this.title, required this.subtitle});

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

class _TripStatsRow extends StatelessWidget {
  const _TripStatsRow({required this.stats});

  final List<TripStatInfo> stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: stats
          .map(
            (stat) => Expanded(
              child: _TripStatItem(label: stat.label, value: stat.value),
            ),
          )
          .toList(),
    );
  }
}

class _TripStatItem extends StatelessWidget {
  const _TripStatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: kCaption12R.copyWith(color: kMutedText)),
        const SizedBox(height: 4),
        Text(
          value,
          style: kStyle(kSemiBold, kSize14, color: _kNavigateBlue, height: 1.1),
        ),
      ],
    );
  }
}

class _CustomerProfileCard extends StatelessWidget {
  const _CustomerProfileCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kCardBorder),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/pngs/person1.png',
              width: 52,
              height: 52,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ajith Kumar', style: kCaption14B),
                const SizedBox(height: 4),
                Text(
                  '3 km away • 12 min',
                  style: kCaption12R.copyWith(color: kMutedText),
                ),
                const SizedBox(height: 2),
                Text(
                  'KL 57 G 4875',
                  style: kCaption12R.copyWith(color: kMutedText),
                ),
              ],
            ),
          ),
          _ContactActionButton(
            color: _kChatGreen,
            icon: Icons.chat_bubble_outline_rounded,
            onTap: () {},
          ),
          const SizedBox(width: 10),
          _ContactActionButton(
            color: _kCallBlue,
            icon: Icons.phone_rounded,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _CountdownRow extends StatelessWidget {
  const _CountdownRow({required this.prefix, required this.value});

  final String prefix;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
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
              TextSpan(text: prefix),
              TextSpan(
                text: value,
                style: kCaption13SB.copyWith(color: kActiveGreen),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TripDetailsBottomActions extends StatelessWidget {
  const _TripDetailsBottomActions();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: primaryButton(
              label: 'Invoice',
              buttonHeight: 52,
              fontSize: kSize16,
              buttonColor: _kInvoiceButtonBg,
              labelColor: _kNavigateBlue,
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: primaryButton(
              label: 'Raise a ticket',
              buttonHeight: 52,
              fontSize: kSize16,
              buttonColor: _kNavigateBlue,
              labelColor: kWhite,
              onPressed: () {
                Navigator.of(context).pushNamed('raiseTicket');
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TripTicketCard extends StatelessWidget {
  const _TripTicketCard({required this.ticket});

  final TripTicketInfo ticket;

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
          Text(
            'TICKET',
            style: kStyle(
              kMedium,
              kSize11,
              color: kMutedText,
              height: 1.1,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            ticket.title,
            style: kCaption14B.copyWith(height: 1.3),
          ),
          const SizedBox(height: 8),
          Text(
            ticket.description,
            style: kCaption13R.copyWith(
              color: kTripBodyMuted,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactActionButton extends StatelessWidget {
  const _ContactActionButton({
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: kWhite, size: 20),
      ),
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
