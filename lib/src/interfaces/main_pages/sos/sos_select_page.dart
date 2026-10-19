import 'package:DriveFormeDriver/src/data/constants/color_constants.dart';
import 'package:DriveFormeDriver/src/data/constants/style_constans.dart';
import 'package:DriveFormeDriver/src/data/services/navigation_services.dart';
import 'package:DriveFormeDriver/src/data/utils/trip_lifecycle.dart';
import 'package:DriveFormeDriver/src/interfaces/main_pages/sos/sos_shared.dart';
import 'package:easy_localization/easy_localization.dart';
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
        // Keep English title for API; UI cards already use titleKey.tr().
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
                            'emergencySos'.tr(),
                            style: kStyle(kSemiBold, kSize26, color: kWhite),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'selectEmergencyType'.tr(),
                            style: kStyle(kRegular, kSize15, color: kWhite),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SosLocationPill(text: localizeSosLocationLabel(locationLabel)),
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
                    'selectEmergencyTypeCaps'.tr(),
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
                            'call112EmergencyServices'.tr(),
                            style: kStyle(kSemiBold, kSize16, color: kWhite),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'locationSharedWithCall'.tr(),
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
