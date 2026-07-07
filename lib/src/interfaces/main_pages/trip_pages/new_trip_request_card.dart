import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/models/trip_model.dart';
import 'package:driveforme_driver/src/data/utils/responsive.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/trip_pages/trip_route_preview.dart';
import 'package:flutter/material.dart';

class NewTripRequestCard extends StatelessWidget {
  const NewTripRequestCard({
    super.key,
    required this.trip,
    required this.onAccept,
    required this.onDecline,
    this.onTap,
  });

  final TripModel trip;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cardRadius = context.rs(18);
    final buttonRadius = context.rs(12);
    final buttonHeight = context.rs(46);

    return Material(
      color: Colors.transparent,
      elevation: 6,
      shadowColor: kBlack.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(cardRadius),
        child: Container(
          padding: EdgeInsets.all(context.rs(14)),
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.circular(cardRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'New Trip request',
                      style: kTripSubSectionSB,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.rs(10),
                      vertical: context.rs(4),
                    ),
                    decoration: BoxDecoration(
                      color: kChipGreyBg,
                      borderRadius: BorderRadius.circular(context.rs(20)),
                    ),
                    child: Text(
                      trip.tripTypeChipLabel,
                      style: kTripChipR.copyWith(color: kSecondaryTextColor),
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.rs(12)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PassengerAvatar(size: context.rs(44)),
                  SizedBox(width: context.rs(10)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.customerDisplayName,
                          style: kCaption14B,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: context.rs(8)),
                        TripRoutePreview(
                          compact: true,
                          pickup: trip.pickupAddress,
                          dropoff: trip.dropoffAddress ?? trip.pickupAddress,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.rs(12)),
              _TripStatsBar(trip: trip),
              SizedBox(height: context.rs(12)),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDecline,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kSosRed,
                        side: BorderSide(color: kSosRed, width: context.rs(1)),
                        minimumSize: Size.fromHeight(buttonHeight),
                        padding: EdgeInsets.symmetric(horizontal: context.rs(8)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(buttonRadius),
                        ),
                      ),
                      child: Text(
                        'Decline ride',
                        style: kStyle(kMedium, kSize14, color: kSosRed),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  SizedBox(width: context.rs(10)),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kTripCtaBlue,
                        foregroundColor: kWhite,
                        minimumSize: Size.fromHeight(buttonHeight),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: context.rs(8)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(buttonRadius),
                        ),
                      ),
                      child: Text(
                        'Accept Ride',
                        style: kStyle(kSemiBold, kSize14, color: kWhite),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PassengerAvatar extends StatelessWidget {
  const _PassengerAvatar({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: kTripRequestAvatarRing, width: context.rs(1.5)),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/pngs/live_photo_image.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _TripStatsBar extends StatelessWidget {
  const _TripStatsBar({required this.trip});

  final TripModel trip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: context.rs(10),
        horizontal: context.rs(4),
      ),
      decoration: BoxDecoration(
        color: kTripRequestStatsBg,
        borderRadius: BorderRadius.circular(context.rs(10)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _StatColumn(
                label: 'Distance',
                value: trip.distanceLabel,
              ),
            ),
            _StatDivider(),
            Expanded(
              child: _StatColumn(
                label: 'Duration',
                value: trip.durationLabel,
              ),
            ),
            _StatDivider(),
            Expanded(
              child: _StatColumn(
                label: 'you earn',
                value: trip.displayEarnings,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return VerticalDivider(
      width: context.rs(1),
      thickness: context.rs(1),
      color: kCardBorder.withValues(alpha: 0.8),
      indent: context.rs(2),
      endIndent: context.rs(2),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.rs(6)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: kTripLocationLabelR,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: context.rs(4)),
          Text(
            value,
            textAlign: TextAlign.center,
            style: kTripDurationPriceB.copyWith(fontSize: kSize15),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
