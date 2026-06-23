import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/utils/trip_lifecycle.dart';
import 'package:driveforme_driver/src/interfaces/components/primarybutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _kDividerColor = Color(0xFFEEEEEE);
const _kCallButtonBlue = Color(0xFF1A5A8E);
const _kSupportPhone = '+916282359916';

class HelpAndSupportPage extends StatelessWidget {
  const HelpAndSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: kWhite,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: kWhite,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _HelpAndSupportHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Image.asset(
                        'assets/pngs/help_support_image.png',
                        height: 160,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Need help booking a driver?',
                        textAlign: TextAlign.center,
                        style: kStyle(
                          kSemiBold,
                          kSize22,
                          color: kTextColor,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Call our team and get instant assistance.',
                        textAlign: TextAlign.center,
                        style: kCaption14R.copyWith(
                          color: kTripBodyMuted,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: _kDividerColor,
                      ),
                      const SizedBox(height: 24),
                      primaryButton(
                        label: 'Call Toll-Free Number',
                        buttonHeight: 52,
                        fontSize: kSize16,
                        buttonColor: _kCallButtonBlue,
                        labelColor: kWhite,
                        icon: Transform.rotate(
                          angle: -0.15,
                          child: const Icon(
                            Icons.phone_rounded,
                            color: kWhite,
                            size: 22,
                          ),
                        ),
                        onPressed: () => launchPhoneCall(_kSupportPhone),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Connect with our booking team instantly.',
                        textAlign: TextAlign.center,
                        style: kCaption13R.copyWith(
                          color: kMutedText,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: _kDividerColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelpAndSupportHeader extends StatelessWidget {
  const _HelpAndSupportHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: kTextColor,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            'Help & Support',
            style: kStyle(kMedium, kSize18, color: kTextColor, height: 1.2),
          ),
        ],
      ),
    );
  }
}
