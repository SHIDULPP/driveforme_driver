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
                  style: kSubHeadingR.copyWith(
                    color: kChevronGrey,
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
                        style: kHeadTitleSB.copyWith(
                          height: 1.22,
                          color: kTextColor,
                        ),
                      ),
                      TextSpan(
                        text: 'D4me',
                        style: kHeadTitleSB.copyWith(
                          height: 1.22,
                          color: kGoldAccent,
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
                  'Drive when your want,Get paid weekly,\nNo vehicle needed',
                  style: kCaption14R.copyWith(height: 1.4, color: kChevronGrey),
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
                child: SizedBox(
                  // height: 68,
                  width: double.infinity,
                  child: primaryButton(
                    label: 'Get Started',
                    buttonHeight: MediaQuery.of(context).size.height * 0.065,
                    fontSize: kSize20,
                    buttonColor: kBrandBlue,
                    labelColor: kWhite,
                    onPressed: () {
                      Navigator.pushNamed(context, 'registration');
                    },
                  ),
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
