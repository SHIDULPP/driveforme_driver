import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/utils/responsive.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/earning.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WithdrawalSuccessPage extends StatelessWidget {
  const WithdrawalSuccessPage({super.key, required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: kWhite,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: kWhite,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
            child: Column(
              children: [
                const Spacer(),
                Image.asset(
                  'assets/pngs/successful_withdraw.png',
                  height: context.rs(220),
                  fit: BoxFit.contain,
                ),
                SizedBox(height: context.rs(28)),
                Text(
                  'Amount',
                  style: kCaption14R.copyWith(color: kMutedText, height: 1.2),
                ),
                SizedBox(height: context.rs(6)),
                Text(
                  formatRupeeStat(amount),
                  style: kStyle(kMedium, kSize32, color: kTextColor, height: 1.05),
                ),
                SizedBox(height: context.rs(10)),
                Text(
                  'Withdrawal Success!',
                  style: kStyle(kSemiBold, kSize20, color: kTextColor, height: 1.2),
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
