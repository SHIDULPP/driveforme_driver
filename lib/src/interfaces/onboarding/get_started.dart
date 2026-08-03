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
      backgroundColor: kWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 86),

              Transform.translate(
                offset: const Offset(-35, 0),
                child: anim.AnimatedWidgetWrapper(
                  animationType: anim.AppAnimationType.fadeScaleUp,
                  duration: anim.AnimationDuration.normal,
                  child: Image.asset(
                    'assets/pngs/drive_forme_logo.png',
                    width: 168,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              anim.AnimatedWidgetWrapper(
                animationType: anim.AppAnimationType.fadeSlideInFromLeft,
                duration: anim.AnimationDuration.normal,
                delayMilliseconds: 100,
                child: Text(
                  'Private Car Driver',
                  style: kStyle(
                    kRegular,
                    kSize18,
                    color: kDarkText.withValues(alpha: 0.5),
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              anim.AnimatedWidgetWrapper(
                animationType: anim.AppAnimationType.fadeSlideInFromLeft,
                duration: anim.AnimationDuration.normal,
                delayMilliseconds: 200,
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Earn by driving\nwith ',
                        style: kStyle(
                          kRegular,
                          kSize36,
                          color: kDarkText,
                          height: 1.22,
                        ),
                      ),
                      TextSpan(
                        text: 'D4me',
                        style: kStyle(
                          kRegular,
                          kSize36,
                          color: kGoldAccent,
                          height: 1.22,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              anim.AnimatedWidgetWrapper(
                animationType: anim.AppAnimationType.fadeSlideInFromLeft,
                duration: anim.AnimationDuration.normal,
                delayMilliseconds: 300,
                child: Text(
                  'Drive when you want,Get paid weekly,\nNo vehicle needed',
                  style: kStyle(
                    kLight,
                    kSize14,
                    color: kDarkText.withValues(alpha: 0.5),
                    height: 1.4,
                  ),
                ),
              ),
              const Spacer(flex: 11),

              anim.AnimatedWidgetWrapper(
                animationType: anim.AppAnimationType.fadeScaleUp,
                duration: anim.AnimationDuration.normal,
                delayMilliseconds: 400,
                child: Center(
                  child: Image.asset(
                    'assets/pngs/car_shadow.png',
                    width: MediaQuery.of(context).size.width * 0.93,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const Spacer(flex: 4),

              anim.AnimatedWidgetWrapper(
                animationType: anim.AppAnimationType.fadeScaleUp,
                duration: anim.AnimationDuration.normal,
                delayMilliseconds: 400,
                child: primaryButton(
                  label: 'Get Started',
                  buttonColor: kBrandBlue,
                  labelColor: kWhite,
                  onPressed: () {
                    Navigator.pushNamed(context, 'registration');
                  },
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }
}
