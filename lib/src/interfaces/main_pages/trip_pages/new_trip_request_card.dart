import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/models/trip_model.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/trip_pages/trip_route_preview.dart';
import 'package:flutter/material.dart';

const _kTripTypeChipBg = Color(0xFFF3F0E8);
const _kStatsBarBg = Color(0xFFF5F3EE);
const _kDeclineRed = Color(0xFFE32626);

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
    return Material(
      color: Colors.transparent,
      elevation: 8,
      shadowColor: kBlack.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'New Trip request',
                      style: kStyle(kSemiBold, kSize16, color: kTextColor),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _kTripTypeChipBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      trip.tripTypeChipLabel,
                      style: kCaption12R.copyWith(color: kSecondaryTextColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/pngs/live_photo_image.png',
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      trip.customerDisplayName,
                      style: kCaption14B,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TripRoutePreview(
                pickup: trip.pickupAddress,
                dropoff: trip.dropoffAddress ?? trip.pickupAddress,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _kStatsBarBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatColumn(
                        label: 'Distance',
                        value: trip.distanceLabel,
                      ),
                    ),
                    Expanded(
                      child: _StatColumn(
                        label: 'Duration',
                        value: trip.durationLabel,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'you earn',
                            style: kCaption12R.copyWith(color: kMutedText),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            trip.displayEarnings,
                            style: kStyle(
                              kSemiBold,
                              kSize15,
                              color: kBrandBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDecline,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _kDeclineRed,
                        side: const BorderSide(color: _kDeclineRed, width: 1.2),
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Text(
                        'Decline ride',
                        style: kStyle(kMedium, kSize14, color: _kDeclineRed),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBrandBlue,
                        foregroundColor: kWhite,
                        minimumSize: const Size.fromHeight(44),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Text(
                        'Accept Ride',
                        style: kStyle(kSemiBold, kSize14, color: kWhite),
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

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: kCaption12R.copyWith(color: kMutedText)),
        const SizedBox(height: 2),
        Text(
          value,
          style: kStyle(kSemiBold, kSize14, color: kBrandBlue),
        ),
      ],
    );
  }
}
