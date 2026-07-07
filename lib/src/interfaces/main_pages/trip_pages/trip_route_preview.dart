import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/utils/responsive.dart';
import 'package:flutter/material.dart';

class TripRoutePreview extends StatelessWidget {
  const TripRoutePreview({
    super.key,
    required this.pickup,
    required this.dropoff,
    this.pickupSubtitle,
    this.dropoffSubtitle,
    this.compact = false,
  });

  final String pickup;
  final String dropoff;
  final String? pickupSubtitle;
  final String? dropoffSubtitle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final iconSize = context.rs(compact ? 16 : 18);
    final connectorHeight = context.rs(compact ? 18 : 22);
    final addressStyle = compact
        ? kCaption13R.copyWith(color: kSecondaryTextColor, height: 1.25)
        : kCaption14R.copyWith(height: 1.25);
    final addressGap = context.rs(compact ? 14 : 18);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(Icons.location_on, size: iconSize, color: kActiveGreen),
            _DashedConnector(height: connectorHeight),
            Icon(Icons.location_on, size: iconSize, color: kDropBlue),
          ],
        ),
        SizedBox(width: context.rs(8)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(pickup, style: addressStyle, maxLines: 2),
              if (pickupSubtitle != null) ...[
                SizedBox(height: context.rs(2)),
                Text(
                  pickupSubtitle!,
                  style: kCaption12R.copyWith(color: kMutedText),
                ),
              ],
              SizedBox(
                height: pickupSubtitle != null
                    ? context.rs(10)
                    : addressGap,
              ),
              Text(dropoff, style: addressStyle, maxLines: 2),
              if (dropoffSubtitle != null) ...[
                SizedBox(height: context.rs(2)),
                Text(
                  dropoffSubtitle!,
                  style: kCaption12R.copyWith(color: kMutedText),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DashedConnector extends StatelessWidget {
  const _DashedConnector({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final dashHeight = context.rs(3);
    final dashGap = context.rs(2);
    final dashCount = (height / (dashHeight + dashGap)).floor().clamp(2, 8);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.rs(2)),
      child: Column(
        children: List.generate(dashCount, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: index == dashCount - 1 ? 0 : dashGap),
            child: Container(
              width: context.rs(1.5),
              height: dashHeight,
              color: kLineGrey,
            ),
          );
        }),
      ),
    );
  }
}
