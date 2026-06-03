import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Background sampled
const _kApplicationReviewBg = Color(0xFF3690FF);

class ApplicationUnderReviewPage extends StatelessWidget {
  const ApplicationUnderReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _kApplicationReviewBg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                SizedBox(height: size.height * 0.10),
                SizedBox(
                  height: size.height * 0.36,
                  child: Center(
                    child: Image.asset(
                      'assets/pngs/application_review.png',
                      width: size.width * 0.66,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.075),
                Text(
                  'Application Under Review',
                  textAlign: TextAlign.center,
                  style: kStyle(kSemiBold, kSize24, color: kWhite, height: 1.2),
                ),
                const SizedBox(height: 14),
                Text(
                  "We're verifying your details to get\nyou started",
                  textAlign: TextAlign.center,
                  style: kStyle(kRegular, kSize16, color: kWhite, height: 1.45),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
