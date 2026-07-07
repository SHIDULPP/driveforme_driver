import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/utils/responsive.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/bank_and_withdraw/verified_badge.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/earning.dart';
import 'package:flutter/material.dart';

class AvailableEarningsCard extends StatelessWidget {
  const AvailableEarningsCard({
    super.key,
    required this.amount,
    this.showIllustration = true,
  });

  final double amount;
  final bool showIllustration;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.rs(14)),
      decoration: BoxDecoration(
        color: kWithdrawCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Available Earnings',
                  style: kEarningsSectionTitleSB,
                ),
              ),
              const SecureBadge(),
            ],
          ),
          SizedBox(height: context.rs(10)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatRupeeStat(amount),
                      style: kStyle(
                        kBold,
                        kSize28,
                        color: kEarningsStatValueBlue,
                        height: 1.05,
                      ),
                    ),
                    SizedBox(height: context.rs(10)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: context.rs(28),
                          width: context.rs(28),
                          decoration: const BoxDecoration(
                            color: kWithdrawSecureBadgeBg,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.account_balance_wallet_outlined,
                            size: context.rs(14),
                            color: kActiveGreen,
                          ),
                        ),
                        SizedBox(width: context.rs(8)),
                        Expanded(
                          child: Text(
                            'This amount is ready to be withdrawn to your bank account.',
                            style: kCaption12R.copyWith(
                              color: kSecondaryTextColor,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (showIllustration) ...[
                SizedBox(width: context.rs(8)),
                Image.asset(
                  'assets/pngs/available_balance.png',
                  width: context.rs(88),
                  height: context.rs(88),
                  fit: BoxFit.contain,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
