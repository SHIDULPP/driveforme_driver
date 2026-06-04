import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/interfaces/components/primarybutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _kPanelBg = Color(0xFFF5F6F8);
const _kMapTooltipBlue = Color(0xFF1A5288);
const _kRouteBlue = Color(0xFF2B74E1);
const _kPickupPulse = Color(0xFFFFE8D6);
const _kChatGreen = Color(0xFF17A34A);
const _kCallBlue = Color(0xFF4A9FD4);
const _kStatValueBlue = Color(0xFF205D91);

class DriverArrivedScreen extends StatelessWidget {
  const DriverArrivedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: kWhite,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const _MapLayer(),
            const _MapRouteOverlay(),
            const _PickupMarker(),
            const _RouteTooltip(),
            Positioned(
              top: MediaQuery.paddingOf(context).top + 8,
              left: 16,
              child: _MapBackButton(onTap: () => Navigator.maybePop(context)),
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: _BottomTripPanel(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapLayer extends StatelessWidget {
  const _MapLayer();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/pngs/map_image.png',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }
}

class _MapRouteOverlay extends StatelessWidget {
  const _MapRouteOverlay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _RouteLinePainter(), size: Size.infinite);
  }
}

class _RouteLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _kRouteBlue
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * 0.22, size.height * 0.38)
      ..quadraticBezierTo(
        size.width * 0.45,
        size.height * 0.32,
        size.width * 0.58,
        size.height * 0.42,
      )
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * 0.5,
        size.width * 0.62,
        size.height * 0.55,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PickupMarker extends StatelessWidget {
  const _PickupMarker();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: MediaQuery.sizeOf(context).width * 0.52,
      top: MediaQuery.sizeOf(context).height * 0.48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _kPickupPulse.withValues(alpha: 0.85),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _kPickupPulse,
              shape: BoxShape.circle,
            ),
          ),
          const Icon(Icons.location_on, color: kRed, size: 36),
        ],
      ),
    );
  }
}

class _RouteTooltip extends StatelessWidget {
  const _RouteTooltip();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: MediaQuery.sizeOf(context).width * 0.28,
      top: MediaQuery.sizeOf(context).height * 0.36,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _kMapTooltipBlue,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: kBlack.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: kOrange,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Heading to the pickup',
                  style: kCaption12R.copyWith(
                    color: kWhite.withValues(alpha: 0.9),
                    height: 1.1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Text(
                '0.8 km away',
                style: kStyle(kSemiBold, kSize14, color: kWhite, height: 1.15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapBackButton extends StatelessWidget {
  const _MapBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          color: kWhite,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: kBlack.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: kTextColor,
        ),
      ),
    );
  }
}

class _BottomTripPanel extends StatelessWidget {
  const _BottomTripPanel();

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: _kPanelBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipPath(
            clipper: const _PanelWaveClipper(arcDepth: 14),
            child: const ColoredBox(
              color: kTripCtaBlue,
              child: SizedBox(height: 28, width: double.infinity),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _PassengerInfoCard(),
                const SizedBox(height: 14),
                const _TripStatsRow(),
                const SizedBox(height: 20),
                primaryButton(
                  label: 'I have arrived',
                  buttonHeight: 52,
                  fontSize: kSize16,
                  buttonColor: kTripCtaBlue,
                  labelColor: kWhite,
                  onPressed: () {
                    Navigator.pushNamed(context, 'tripOtp');
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  'Tap when you reached the pickup location',
                  textAlign: TextAlign.center,
                  style: kCaption12R.copyWith(
                    color: kTripBodyMuted,
                    height: 1.35,
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

/// Top edge of the blue strip dips down in the center (wave into the panel).
class _PanelWaveClipper extends CustomClipper<Path> {
  const _PanelWaveClipper({required this.arcDepth});

  final double arcDepth;

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    return Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(w / 2, arcDepth, w, 0)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
  }

  @override
  bool shouldReclip(covariant _PanelWaveClipper oldClipper) =>
      oldClipper.arcDepth != arcDepth;
}

class _PassengerInfoCard extends StatelessWidget {
  const _PassengerInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kBlack.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/pngs/person1.png',
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ajith Kumar', style: kTripSubSectionSB),
                const SizedBox(height: 4),
                Text(
                  'Edappally, Lulu mall',
                  style: kTripLocationLabelR.copyWith(
                    color: kTripBodyMuted,
                    fontSize: kSize13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'KL 57 G 4875',
                  style: kTripLocationLabelR.copyWith(
                    color: kTripBodyMuted,
                    fontSize: kSize13,
                  ),
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
        height: 44,
        width: 44,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: kWhite, size: 22),
      ),
    );
  }
}

class _TripStatsRow extends StatelessWidget {
  const _TripStatsRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kBlack.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: const [
          Expanded(
            child: _TripStatItem(label: 'ETA', value: '4 min'),
          ),
          Expanded(
            child: _TripStatItem(label: 'REMAINING', value: '1.2 KM'),
          ),
          Expanded(
            child: _TripStatItem(label: 'ARRIVAL', value: '09:48 AM'),
          ),
        ],
      ),
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
      children: [
        Text(
          label,
          style: kCaption11R.copyWith(
            color: kTripMutedLabel,
            letterSpacing: 0.4,
            fontWeight: kMedium,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          textAlign: TextAlign.center,
          style: kStyle(
            kSemiBold,
            kSize16,
            color: _kStatValueBlue,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}
