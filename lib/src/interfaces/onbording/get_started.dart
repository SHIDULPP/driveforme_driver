import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/interfaces/animations/index.dart' as anim;
import 'package:driveforme_driver/src/interfaces/components/primarybutton.dart';
import 'package:flutter/material.dart';

class DriverPartnerLandingPage extends StatelessWidget {
  const DriverPartnerLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScreenBg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 90),

            /// LOGO
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: anim.AnimatedWidgetWrapper(
                animationType: anim.AppAnimationType.fadeScaleUp,
                duration: anim.AnimationDuration.normal,
                delayMilliseconds: 400,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/pngs/drive_forme_logo.png',
                      width: 180,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ),

            /// SUB TITLE
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: anim.AnimatedWidgetWrapper(
                animationType: anim.AppAnimationType.fadeScaleUp,
                duration: anim.AnimationDuration.normal,
                delayMilliseconds: 400,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Private Car Driver',
                      style: kSubHeadingR.copyWith(color: kChevronGrey),
                    ),
                  ],
                ),
              ),
            ),

            /// TITLE
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: anim.AnimatedWidgetWrapper(
                animationType: anim.AppAnimationType.fadeScaleUp,
                duration: anim.AnimationDuration.normal,
                delayMilliseconds: 400,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Earn by driving\nwith ',
                            style: kHeadTitleSB.copyWith(
                              height: 1.25,
                              color: kTextColor,
                            ),
                          ),
                          TextSpan(
                            text: 'D4me',
                            style: kHeadTitleSB.copyWith(
                              height: 1.25,
                              color: kGoldAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// DESCRIPTION
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: anim.AnimatedWidgetWrapper(
                animationType: anim.AppAnimationType.fadeScaleUp,
                duration: anim.AnimationDuration.normal,
                delayMilliseconds: 400,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Drive when you want, Get paid weekly,\nNo vehicle needed',
                      style: kCaption14R.copyWith(
                        height: 1.5,
                        color: kChevronGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// ILLUSTRATION
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: anim.AnimatedWidgetWrapper(
                animationType: anim.AppAnimationType.fadeScaleUp,
                duration: anim.AnimationDuration.normal,
                delayMilliseconds: 400,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/pngs/car_shadow.png',
                      width: MediaQuery.of(context).size.width * .85,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ),

            /// BUTTON
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: anim.AnimatedWidgetWrapper(
                animationType: anim.AppAnimationType.fadeScaleUp,
                duration: anim.AnimationDuration.normal,
                delayMilliseconds: 400,
                child: primaryButton(
                  label: 'Get Started',
                  buttonHeight: 56,
                  fontSize: 16,
                  onPressed: () {
                    Navigator.pushNamed(context, 'GetStarted');
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
