import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:flutter/material.dart';

const _kPanelBg = Color(0xFFF5F6F8);
const _kStatValueBlue = Color(0xFF205D91);

class DriverNavigationSheet extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String distanceLabel;
  final String etaLabel;
  final Widget? child;
  final Widget? footer;

  const DriverNavigationSheet({
    super.key,
    required this.title,
    this.subtitle,
    required this.distanceLabel,
    required this.etaLabel,
    this.child,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: _kPanelBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipPath(
            clipper: const _PanelWaveClipper(arcDepth: 12),
            child: const ColoredBox(
              color: kTripCtaBlue,
              child: SizedBox(height: 20, width: double.infinity),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPadding + 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(title, style: kTripSubSectionSB),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: kTripLocationLabelR.copyWith(
                      color: kTripBodyMuted,
                      fontSize: kSize13,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                _NavigationStatsRow(
                  distanceLabel: distanceLabel,
                  etaLabel: etaLabel,
                ),
                if (child != null) ...[
                  const SizedBox(height: 14),
                  child!,
                ],
                if (footer != null) ...[
                  const SizedBox(height: 10),
                  footer!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationStatsRow extends StatelessWidget {
  const _NavigationStatsRow({
    required this.distanceLabel,
    required this.etaLabel,
  });

  final String distanceLabel;
  final String etaLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: kBlack.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _NavStatItem(
              icon: Icons.route_rounded,
              label: 'Distance',
              value: distanceLabel,
            ),
          ),
          Container(width: 1, height: 36, color: kCardBorder),
          Expanded(
            child: _NavStatItem(
              icon: Icons.access_time_rounded,
              label: 'ETA',
              value: etaLabel,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavStatItem extends StatelessWidget {
  const _NavStatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: kTripMutedLabel),
            const SizedBox(width: 4),
            Text(
              label.toUpperCase(),
              style: kCaption11R.copyWith(
                color: kTripMutedLabel,
                letterSpacing: 0.4,
                fontWeight: kMedium,
              ),
            ),
          ],
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
