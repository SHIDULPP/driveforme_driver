import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/providers/user_provider.dart';
import 'package:driveforme_driver/src/data/providers/wallet_provider.dart';
import 'package:driveforme_driver/src/data/utils/responsive.dart';
import 'package:driveforme_driver/src/interfaces/components/primarybutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _kPromoBorder = Color(0xFFE8C98A);
const _kPromoBg = Color(0xFFF9F9FB);
const _kCodeDashedBorder = Color(0xFFCE9141);

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
              _ReferPageHeader(
                onHelp: () => Navigator.pushNamed(context, 'faqPage'),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    context.horizontalPadding,
                    context.rs(12),
                    context.horizontalPadding,
                    context.rs(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _InviteEarnBanner(),
                      SizedBox(height: context.rs(16)),
                      _ReferralCodeCard(
                        code: code,
                        onCopy: code.isEmpty
                            ? null
                            : () => _copyCode(context, code),
                        onShare: code.isEmpty
                            ? null
                            : () => _shareInvite(context, code),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  context.horizontalPadding,
                  context.rs(8),
                  context.horizontalPadding,
                  context.rs(16),
                ),
                child: primaryButton(
                  label: 'Invite',
                  onPressed: code.isEmpty
                      ? null
                      : () => _shareInvite(context, code),
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

  void _shareInvite(BuildContext context, String code) {
    final message =
        'Join Drive For Me as a driver and earn! Use my referral code: $code';
    Clipboard.setData(ClipboardData(text: message));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invite message copied. Share it with friends!')),
    );
  }
}

String _formatReferralCode(String code) {
  if (code.isEmpty) return '—';
  return code.trim().toUpperCase().split('').join(' ');
}

class _ReferPageHeader extends StatelessWidget {
  const _ReferPageHeader({required this.onHelp});

  final VoidCallback onHelp;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 0),
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
          const Spacer(),
          IconButton(
            onPressed: onHelp,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            icon: Container(
              height: 28,
              width: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: kBrandBlue, width: 1.5),
              ),
              child: const Icon(
                Icons.question_mark_rounded,
                size: 16,
                color: kBrandBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InviteEarnBanner extends StatelessWidget {
  const _InviteEarnBanner();

  @override
  Widget build(BuildContext context) {
    final bannerHeight = context.rs(152);

    return Container(
      height: bannerHeight,
      decoration: BoxDecoration(
        color: _kPromoBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kPromoBorder, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 11,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                context.rs(20),
                context.rs(18),
                context.rs(6),
                context.rs(18),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: kStyle(
                        kSemiBold,
                        kSize22,
                        color: kTextColor,
                        height: 1.15,
                      ),
                      children: const [
                        TextSpan(text: 'Invite & '),
                        TextSpan(
                          text: 'Earn',
                          style: TextStyle(color: kBrandBlue),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.rs(10)),
                  Text(
                    'Earn ₹100 for every successful Driver referral',
                    style: kCaption13R.copyWith(
                      color: kTripBodyMuted,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 10,
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: context.rs(4)),
                child: Image.asset(
                  'assets/pngs/referandearnimage.png',
                  height: bannerHeight,
                  fit: BoxFit.contain,
                  alignment: Alignment.centerRight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferralCodeCard extends StatelessWidget {
  const _ReferralCodeCard({
    required this.code,
    this.onCopy,
    this.onShare,
  });

  final String code;
  final VoidCallback? onCopy;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.rs(16)),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kCardBorder),
        boxShadow: [
          BoxShadow(
            color: kBlack.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Referral Code',
            style: kCaption12R.copyWith(color: kMutedText),
          ),
          SizedBox(height: context.rs(12)),
          Row(
            children: [
              Expanded(
                child: CustomPaint(
                  painter: _DashedBorderPainter(
                    color: _kCodeDashedBorder.withValues(alpha: 0.75),
                    radius: 28,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: context.rs(18),
                      vertical: context.rs(14),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _formatReferralCode(code),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: kStyle(
                              kSemiBold,
                              kSize18,
                              color: kTextColor,
                              height: 1.2,
                            ).copyWith(letterSpacing: 2),
                          ),
                        ),
                        if (onCopy != null)
                          GestureDetector(
                            onTap: onCopy,
                            child: Icon(
                              Icons.copy_rounded,
                              size: context.rs(20),
                              color: kGoldAccent,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: context.rs(12)),
              if (onShare != null)
                GestureDetector(
                  onTap: onShare,
                  child: Icon(
                    Icons.send_rounded,
                    size: context.rs(22),
                    color: kBrandBlue,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) => false;
}
