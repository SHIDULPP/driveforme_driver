import 'package:driveforme_driver/src/data/providers/active_trip_provider.dart';
import 'package:driveforme_driver/src/data/providers/wallet_provider.dart';
import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/interfaces/components/primarybutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _kScreenGreen = Color(0xFF17A34A);

class CashCollectedScreen extends ConsumerWidget {
  const CashCollectedScreen({
    super.key,
    this.tripMongoId = '',
    this.collectedAmount = '—',
  });

  final String tripMongoId;
  final String collectedAmount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _kScreenGreen,
        body: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, topPadding, 24, bottomPadding + 20),
            child: Column(
              children: [
                const Spacer(flex: 3),
                Image.asset(
                  'assets/pngs/trip_completed_image.png',
                  height: 108,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),
                Text(
                  '$collectedAmount Collected!',
                  textAlign: TextAlign.center,
                  style: kStyle(
                    kSemiBold,
                    kSize30,
                    color: kWhite,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Payment received Successfully',
                  textAlign: TextAlign.center,
                  style: kCaption14R.copyWith(
                    color: kWhite.withValues(alpha: 0.95),
                    height: 1.35,
                  ),
                ),
                const Spacer(flex: 4),
                primaryButton(
                  label: 'Go Online for next trip',
                  buttonHeight: 52,
                  fontSize: kSize16,
                  buttonColor: kWhite,
                  labelColor: kTripCtaBlue,
                  onPressed: () async {
                    ref.invalidate(walletProvider);
                    await ref.read(activeTripProvider.notifier).clear();
                    if (!context.mounted) return;
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      'navBar',
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
