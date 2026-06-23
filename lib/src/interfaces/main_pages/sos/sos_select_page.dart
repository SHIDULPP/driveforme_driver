import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/services/navigation_services.dart';
import 'package:driveforme_driver/src/data/utils/trip_lifecycle.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/sos/sos_shared.dart';
import 'package:flutter/material.dart';

class SosSelectPage extends StatelessWidget {
  final String locationLabel;
  final String? tripId;

  const SosSelectPage({
    super.key,
    this.locationLabel = 'Live location shared',
    this.tripId,
  });

  void _openCountdown(BuildContext context, SosEmergencyOption option) {
    NavigationService().pushNamedReplacement(
      'sos_countdown',
      arguments: {
        'locationLabel': locationLabel,
        'sosType': option.title,
        'tripId': tripId,
        'pickupAddress': locationLabel,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: kSosScreenBg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: kSosRed,
            padding: EdgeInsets.fromLTRB(16, topInset + 8, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SosBackButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/pngs/sos_image.png',
                      height: 88,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Emergency SOS',
                            style: kStyle(kSemiBold, kSize26, color: kWhite),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Select the type of emergency',
                            style: kStyle(kRegular, kSize15, color: kWhite),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SosLocationPill(text: locationLabel),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SELECT EMERGENCY TYPE',
                    style: kStyle(
                      kSemiBold,
                      kSize12,
                      color: kTripMutedLabel,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...kDefaultSosOptions.map(
                    (option) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SosEmergencyTypeCard(
                        option: option,
                        onTap: () => _openCountdown(context, option),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, bottomInset + 12),
            child: Column(
              children: [
                Material(
                  color: kSosRed,
                  borderRadius: BorderRadius.circular(28),
                  child: InkWell(
                    onTap: () => launchPhoneCall('112'),
                    borderRadius: BorderRadius.circular(28),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.phone, color: kWhite, size: 22),
                          const SizedBox(width: 10),
                          Text(
                            'Call 112 - Emergency Services',
                            style: kStyle(kSemiBold, kSize16, color: kWhite),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your location is automatically shared with call',
                  textAlign: TextAlign.center,
                  style: kStyle(kRegular, kSize12, color: kMutedText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
