import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/utils/responsive.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/bank_and_withdraw/verified_badge.dart';
import 'package:flutter/material.dart';

class BankLogoAvatar extends StatelessWidget {
  const BankLogoAvatar({
    super.key,
    required this.bankName,
    this.size,
    this.showVerifiedDot = false,
  });

  final String bankName;
  final double? size;
  final bool showVerifiedDot;

  @override
  Widget build(BuildContext context) {
    final avatarSize = size ?? context.rs(44);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: avatarSize,
          width: avatarSize,
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kCardBorder),
          ),
          alignment: Alignment.center,
          child: Text(
            bankName.length >= 4 ? bankName.substring(0, 4).toUpperCase() : bankName,
            style: kStyle(
              kBold,
              kSize11,
              color: kBrandBlue,
              height: 1,
            ),
          ),
        ),
        if (showVerifiedDot)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              height: context.rs(16),
              width: context.rs(16),
              decoration: const BoxDecoration(
                color: kActiveGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                size: context.rs(10),
                color: kWhite,
              ),
            ),
          ),
      ],
    );
  }
}

class BankAccountCard extends StatelessWidget {
  const BankAccountCard({
    super.key,
    required this.bankName,
    required this.maskedAccountNumber,
    required this.holderName,
    this.onChange,
    this.showChange = false,
    this.compact = false,
  });

  final String bankName;
  final String maskedAccountNumber;
  final String holderName;
  final VoidCallback? onChange;
  final bool showChange;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.rs(compact ? 12 : 14)),
      decoration: BoxDecoration(
        color: kWithdrawBankCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kCardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BankLogoAvatar(bankName: bankName, showVerifiedDot: true),
          SizedBox(width: context.rs(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        bankName,
                        style: kCaption14B.copyWith(height: 1.2),
                      ),
                    ),
                    if (showChange)
                      GestureDetector(
                        onTap: onChange,
                        behavior: HitTestBehavior.opaque,
                        child: Text(
                          'Change >',
                          style: kStyle(
                            kMedium,
                            kSize13,
                            color: kBrandBlue,
                            height: 1.2,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: context.rs(3)),
                Text(
                  maskedAccountNumber,
                  style: kCaption12R.copyWith(
                    color: kSecondaryTextColor,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: context.rs(2)),
                Text(
                  holderName,
                  style: kCaption12R.copyWith(
                    color: kMutedText,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: context.rs(8)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              VerifiedBadge(compact: true),
            ],
          ),
        ],
      ),
    );
  }
}
