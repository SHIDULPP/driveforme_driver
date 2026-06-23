import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/providers/user_provider.dart';
import 'package:driveforme_driver/src/data/providers/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReferPage extends ConsumerWidget {
  const ReferPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final walletAsync = ref.watch(walletProvider);

    final referralCode = walletAsync.maybeWhen(
      data: (wallet) => wallet.referralCode,
      orElse: () => '',
    );
    final fallbackCode = userAsync.maybeWhen(
      data: (user) => user?.referralCode ?? '',
      orElse: () => '',
    );
    final code = referralCode.isNotEmpty ? referralCode : fallbackCode;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: kWhite,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: kWhite,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _ReferPageHeader(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Image.asset(
                        'assets/pngs/drive_forme_logo.png',
                        height: 72,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Invite drivers and vehicle owners',
                        textAlign: TextAlign.center,
                        style: kStyle(kSemiBold, kSize20, color: kTextColor),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Share your referral code. When someone signs up with it, '
                        'you earn a referral bonus credited to your wallet.',
                        textAlign: TextAlign.center,
                        style: kCaption14R.copyWith(
                          color: kTripBodyMuted,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Your referral code',
                        style: kCaption13R.copyWith(color: kMutedText),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: kScreenBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: kCardBorder),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                code.isNotEmpty ? code : '—',
                                style: kStyle(
                                  kSemiBold,
                                  kSize22,
                                  color: kBrandBlue,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: code.isEmpty
                                  ? null
                                  : () => _copyCode(context, code),
                              icon: const Icon(
                                Icons.copy_rounded,
                                color: kBrandBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Bonus amount is set by the platform and credited after '
                        'your referral completes their first trip.',
                        textAlign: TextAlign.center,
                        style: kCaption12R.copyWith(color: kMutedText),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _copyCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Referral code copied.')),
    );
  }
}

class _ReferPageHeader extends StatelessWidget {
  const _ReferPageHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: kTextColor,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            'Refer & Earn',
            style: kStyle(
              kMedium,
              kSize18,
              color: kTextColor,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
