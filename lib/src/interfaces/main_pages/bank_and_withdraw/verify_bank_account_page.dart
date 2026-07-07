import 'dart:async';

import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/services/navigation_services.dart';
import 'package:driveforme_driver/src/data/utils/responsive.dart';
import 'package:driveforme_driver/src/data/models/bank_account_ui_model.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/bank_and_withdraw/withdraw_scaffold.dart';
import 'package:flutter/material.dart';

class VerifyBankAccountPage extends StatefulWidget {
  const VerifyBankAccountPage({super.key, required this.account});

  final BankAccountUiModel account;

  @override
  State<VerifyBankAccountPage> createState() => _VerifyBankAccountPageState();
}

class _VerifyBankAccountPageState extends State<VerifyBankAccountPage> {
  double _progress = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (!mounted) return;
      setState(() {
        _progress += 0.01;
        if (_progress >= 1) {
          _progress = 1;
          timer.cancel();
          Future.delayed(const Duration(milliseconds: 400), () {
            if (!mounted) return;
            NavigationService().pushNamedReplacement(
              'bankAddedSuccess',
              arguments: {'account': widget.account},
            );
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percent = (_progress * 100).round();

    return WithdrawScaffold(
      title: 'Verifying Account',
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
        child: Column(
          children: [
            SizedBox(height: context.rs(24)),
            Image.asset(
              'assets/pngs/verify_bank.png',
              height: context.rs(180),
              fit: BoxFit.contain,
            ),
            SizedBox(height: context.rs(20)),
            Text(
              'Verifying Your Account',
              style: kStyle(kSemiBold, kSize20, color: kTextColor, height: 1.2),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.rs(8)),
            Text(
              'Please wait while we verify your account details',
              style: kCaption14R.copyWith(
                color: kSecondaryTextColor,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            SizedBox(
              height: context.rs(150),
              width: context.rs(150),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: _progress,
                      strokeWidth: context.rs(10),
                      backgroundColor: kEarningsChartBarInactive,
                      color: kBrandBlue,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$percent%',
                        style: kStyle(
                          kBold,
                          kSize28,
                          color: kTextColor,
                          height: 1,
                        ),
                      ),
                      SizedBox(height: context.rs(4)),
                      Text(
                        'Verifying....',
                        style: kCaption13R.copyWith(color: kMutedText),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: context.rs(48)),
          ],
        ),
      ),
    );
  }
}
