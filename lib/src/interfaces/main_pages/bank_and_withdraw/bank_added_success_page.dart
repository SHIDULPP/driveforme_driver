import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/services/navigation_services.dart';
import 'package:driveforme_driver/src/data/utils/responsive.dart';
import 'package:driveforme_driver/src/interfaces/components/primarybutton.dart';
import 'package:driveforme_driver/src/data/models/bank_account_ui_model.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/bank_and_withdraw/bank_account_card.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/bank_and_withdraw/withdraw_scaffold.dart';
import 'package:flutter/material.dart';

class BankAddedSuccessPage extends StatelessWidget {
  const BankAddedSuccessPage({super.key, required this.account});

  final BankAccountUiModel account;

  @override
  Widget build(BuildContext context) {
    return WithdrawScaffold(
      title: 'Verifying Account',
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          context.horizontalPadding,
          context.rs(16),
          context.horizontalPadding,
          context.rs(24),
        ),
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              height: context.rs(88),
              width: context.rs(88),
              decoration: const BoxDecoration(
                color: kActiveGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                color: kWhite,
                size: context.rs(48),
              ),
            ),
          ),
          SizedBox(height: context.rs(18)),
          Text(
            'Bank Account Added Successfully!',
            style: kStyle(kSemiBold, kSize20, color: kTextColor, height: 1.25),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.rs(8)),
          Text(
            'Your bank account has been verified and is ready to receive your earnings.',
            style: kCaption14R.copyWith(
              color: kSecondaryTextColor,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.rs(20)),
          BankAccountCard(
            bankName: account.bankName,
            maskedAccountNumber: account.maskedAccountNumber,
            holderName: account.holderName,
          ),
        ],
      ),
      bottom: SafeArea(
        minimum: EdgeInsets.fromLTRB(
          context.horizontalPadding,
          0,
          context.horizontalPadding,
          context.rs(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            primaryButton(
              label: 'Withdraw Earnings',
              buttonColor: kBrandBlue,
              onPressed: () {
                Navigator.of(context).popUntil(
                  (route) =>
                      route.settings.name == 'withdrawEarnings' ||
                      route.settings.name == 'navBar',
                );
                NavigationService().pushNamed('withdrawAmount');
              },
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil(
                  (route) =>
                      route.settings.name == 'withdrawEarnings' ||
                      route.settings.name == 'navBar',
                );
              },
              child: Text(
                'Go Back',
                style: kStyle(kMedium, kSize15, color: kBrandBlue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
