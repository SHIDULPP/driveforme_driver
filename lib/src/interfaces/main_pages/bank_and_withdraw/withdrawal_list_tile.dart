import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/utils/responsive.dart';
import 'package:driveforme_driver/src/data/models/withdrawal_ui_model.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/earning.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WithdrawalListTile extends StatelessWidget {
  const WithdrawalListTile({super.key, required this.withdrawal});

  final WithdrawalUiModel withdrawal;

  @override
  Widget build(BuildContext context) {
    final statusColor = withdrawal.isFailed ? kSosRed : kActiveGreen;
    final dateLabel = DateFormat('MMM d, yyyy').format(withdrawal.date);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.rs(14),
        vertical: context.rs(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: context.rs(44),
            width: context.rs(44),
            decoration: BoxDecoration(
              color: withdrawal.isFailed
                  ? kEarningsPlatformFeeIconBg
                  : kEarningsWithdrawIconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_rounded,
              color: withdrawal.isFailed ? kSosRed : kActiveGreen,
              size: context.rs(21),
            ),
          ),
          SizedBox(width: context.rs(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatRupeeStat(withdrawal.amount),
                  style: kCaption14B.copyWith(height: 1.2),
                ),
                SizedBox(height: context.rs(3)),
                Text(
                  '${withdrawal.bankName} ${withdrawal.maskedAccount}',
                  style: kCaption12R.copyWith(
                    color: kSecondaryTextColor,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                withdrawal.isFailed ? 'Failed' : 'Completed',
                style: kStyle(
                  kSemiBold,
                  kSize13,
                  color: statusColor,
                  height: 1.2,
                ),
              ),
              SizedBox(height: context.rs(3)),
              Text(
                dateLabel,
                style: kCaption12R.copyWith(
                  color: kSecondaryTextColor,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WithdrawalsEmptyState extends StatelessWidget {
  const WithdrawalsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.rs(28)),
      child: Column(
        children: [
          Image.asset(
            'assets/pngs/available_balance.png',
            width: context.rs(100),
            height: context.rs(100),
            fit: BoxFit.contain,
          ),
          SizedBox(height: context.rs(12)),
          Text(
            'No Withdrawals yet',
            style: kCaption14B.copyWith(height: 1.2),
          ),
        ],
      ),
    );
  }
}

class NoBankEmptyState extends StatelessWidget {
  const NoBankEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.rs(24)),
      child: Column(
        children: [
          Image.asset(
            'assets/pngs/no_bank_added.png',
            width: context.rs(220),
            height: context.rs(140),
            fit: BoxFit.contain,
          ),
          SizedBox(height: context.rs(16)),
          Text(
            'No Bank Account Added',
            style: kStyle(kSemiBold, kSize18, color: kTextColor, height: 1.2),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.rs(8)),
          Text(
            'Add your bank account details to withdraw your earnings directly to your account.',
            style: kCaption14R.copyWith(
              color: kSecondaryTextColor,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
