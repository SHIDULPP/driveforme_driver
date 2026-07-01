import 'dart:async';

import 'package:driveforme_driver/src/data/apis/onboarding_api.dart';
import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/providers/user_provider.dart';
import 'package:driveforme_driver/src/data/services/navigation_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _kApplicationReviewBg = Color(0xFF3690FF);
const _pollInterval = Duration(seconds: 30);

class ApplicationUnderReviewPage extends ConsumerStatefulWidget {
  const ApplicationUnderReviewPage({super.key});

  @override
  ConsumerState<ApplicationUnderReviewPage> createState() =>
      _ApplicationUnderReviewPageState();
}

class _ApplicationUnderReviewPageState
    extends ConsumerState<ApplicationUnderReviewPage> {
  Timer? _pollTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkStatus());
    _pollTimer = Timer.periodic(_pollInterval, (_) => _checkStatus());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    if (_isRefreshing || !mounted) return;
    _isRefreshing = true;

    final response = await ref.read(onboardingApiProvider).getMe();
    _isRefreshing = false;

    if (!mounted) return;
    if (!response.success || response.data == null) return;

    final user = response.data!;
    final status = user.effectiveOnboardingStatus;
    if (status == 'approved') {
      ref.invalidate(userProvider);
      NavigationService().pushNamedAndRemoveUntil('navBar');
    } else if (status == 'rejected') {
      ref.invalidate(userProvider);
      NavigationService().pushNamedAndRemoveUntil('applicationRejected');
    }
  }

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
                const SizedBox(height: 24),
                // OutlinedButton(
                //   onPressed: _checkStatus,
                //   style: OutlinedButton.styleFrom(
                //     foregroundColor: kWhite,
                //     side: const BorderSide(color: kWhite),
                //   ),
                //   child: const Text('Check status'),
                // ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
