import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/utils/responsive.dart';
import 'package:flutter/material.dart';

class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.rs(compact ? 8 : 10),
        vertical: context.rs(compact ? 4 : 5),
      ),
      decoration: BoxDecoration(
        color: kWithdrawSecureBadgeBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_rounded,
            size: context.rs(compact ? 12 : 14),
            color: kActiveGreen,
          ),
          SizedBox(width: context.rs(4)),
          Text(
            'Verified',
            style: kStyle(
              kSemiBold,
              compact ? kSize11 : kSize12,
              color: kActiveGreen,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class SecureBadge extends StatelessWidget {
  const SecureBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.rs(8),
        vertical: context.rs(4),
      ),
      decoration: BoxDecoration(
        color: kWithdrawSecureBadgeBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_rounded,
            size: context.rs(12),
            color: kActiveGreen,
          ),
          SizedBox(width: context.rs(4)),
          Text(
            'Secure and safe',
            style: kStyle(
              kMedium,
              kSize11,
              color: kActiveGreen,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
