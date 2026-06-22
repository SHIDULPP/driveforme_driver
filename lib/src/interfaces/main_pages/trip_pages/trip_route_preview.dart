import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:flutter/material.dart';

const _kDropPinBlue = Color(0xFF2B74E1);

class TripRoutePreview extends StatelessWidget {
  const TripRoutePreview({
    super.key,
    required this.pickup,
    required this.dropoff,
    this.pickupSubtitle,
    this.dropoffSubtitle,
  });

  final String pickup;
  final String dropoff;
  final String? pickupSubtitle;
  final String? dropoffSubtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            const Icon(Icons.location_on, size: 18, color: kActiveGreen),
            Container(
              width: 1.5,
              height: pickupSubtitle != null ? 34 : 22,
              margin: const EdgeInsets.symmetric(vertical: 2),
              color: kCardBorder,
            ),
            const Icon(Icons.location_on, size: 18, color: _kDropPinBlue),
          ],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(pickup, style: kCaption14R, maxLines: 2),
              if (pickupSubtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  pickupSubtitle!,
                  style: kCaption12R.copyWith(color: kMutedText),
                ),
              ],
              SizedBox(height: pickupSubtitle != null ? 10 : 18),
              Text(dropoff, style: kCaption14R, maxLines: 2),
              if (dropoffSubtitle != null) ...[
                const SizedBox(height: 2),
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
