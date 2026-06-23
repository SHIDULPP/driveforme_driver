import 'package:driveforme_driver/src/data/providers/active_trip_provider.dart';
import 'package:driveforme_driver/src/data/providers/wallet_provider.dart';
import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/interfaces/components/primarybutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

const _kHeaderGreen = Color(0xFF17A34A);
const _kTotalEarnedBg = Color(0xFF128C3A);
const _kExtraTimeRowBg = Color(0xFFFFF3E8);
const _kExtraTimeText = Color(0xFFC6934B);
const _kTotalAmountBlue = Color(0xFF205D91);

class TripCompletedScreen extends ConsumerWidget {
  const TripCompletedScreen({
    super.key,
    this.tripMongoId = '',
    this.tripId = '',
    this.routeSummary = '',
    this.elapsedDuration = '',
    this.totalEarned = '—',
    this.baseFareLabel = 'Base fare',
    this.baseFareAmount = '—',
    this.extraTimeLabel = 'Extra Time',
    this.extraTimeAmount = '—',
    this.totalAmount = '—',
    this.paymentMethod = 'cash',
  });

  final String tripMongoId;
  final String tripId;
  final String routeSummary;
  final String elapsedDuration;
  final String totalEarned;
  final String baseFareLabel;
  final String baseFareAmount;
  final String extraTimeLabel;
  final String extraTimeAmount;
  final String totalAmount;
  final String paymentMethod;

  bool get _isCashPayment =>
      paymentMethod == 'cash' || paymentMethod == 'offline';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final sheetTop = screenHeight * 0.52;
    final showExtra = extraTimeAmount != '—' && extraTimeAmount.isNotEmpty;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _kHeaderGreen,
        body: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: _kHeaderGreen,
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, topPadding + 16, 24, 0),
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.06),
                    Image.asset(
                      'assets/pngs/trip_completed_image.png',
                      height: 108,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Trip Completed!',
                      textAlign: TextAlign.center,
                      style: kStyle(
                        kSemiBold,
                        kSize30,
                        color: kWhite,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        routeSummary.isNotEmpty
                            ? '$routeSummary  $elapsedDuration'
                            : elapsedDuration,
                        textAlign: TextAlign.center,
                        style: kCaption14R.copyWith(
                          color: kWhite.withValues(alpha: 0.95),
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _TotalEarnedBadge(totalEarned: totalEarned),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: sheetTop,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 16,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 28, 20, bottomPadding + 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _PaymentSummaryCard(
                        baseFareLabel: baseFareLabel,
                        baseFareAmount: baseFareAmount,
                        extraTimeLabel: extraTimeLabel,
                        extraTimeAmount: extraTimeAmount,
                        totalAmount: totalAmount,
                        showExtra: showExtra,
                      ),
                      const Spacer(),
                      if (_isCashPayment)
                        primaryButton(
                          label: 'Mark as Collected',
                          buttonHeight: 52,
                          fontSize: kSize16,
                          buttonColor: kTripCtaBlue,
                          labelColor: kWhite,
                          onPressed: () async {
                            ref.invalidate(walletProvider);
                            Navigator.pushReplacementNamed(
                              context,
                              'cashCollected',
                              arguments: {
                                'tripMongoId': tripMongoId,
                                'collectedAmount': totalAmount,
                              },
                            );
                          },
                        )
                      else
                        primaryButton(
                          label: 'Done',
                          buttonHeight: 52,
                          fontSize: kSize16,
                          buttonColor: kTripCtaBlue,
                          labelColor: kWhite,
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
          ],
        ),
      ),
    );
  }
}

class _TotalEarnedBadge extends StatelessWidget {
  const _TotalEarnedBadge({required this.totalEarned});

  final String totalEarned;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      decoration: BoxDecoration(
        color: _kTotalEarnedBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kWhite.withValues(alpha: 0.4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'TOTAL EARNED',
            style: kCaption11R.copyWith(
              color: kWhite.withValues(alpha: 0.92),
              letterSpacing: 1,
              fontWeight: kSemiBold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            totalEarned,
            style: kStyle(kSemiBold, kSize24, color: kWhite, height: 1.05),
          ),
        ],
      ),
    );
  }
}

class _PaymentSummaryCard extends StatelessWidget {
  const _PaymentSummaryCard({
    required this.baseFareLabel,
    required this.baseFareAmount,
    required this.extraTimeLabel,
    required this.extraTimeAmount,
    required this.totalAmount,
    required this.showExtra,
  });

  final String baseFareLabel;
  final String baseFareAmount;
  final String extraTimeLabel;
  final String extraTimeAmount;
  final String totalAmount;
  final bool showExtra;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kTripCreamBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kCardBorder.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Payment Summary',
                  style: kCaption14M.copyWith(color: kTripBodyMuted),
                ),
                const SizedBox(height: 16),
                _PaymentRow(label: baseFareLabel, amount: baseFareAmount),
              ],
            ),
          ),
          if (showExtra) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _DashedDivider(),
            ),
            _PaymentRow(
              label: extraTimeLabel,
              amount: extraTimeAmount,
              highlighted: true,
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: _PaymentRow(
              label: 'Total Amount',
              amount: totalAmount,
              isTotal: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({
    required this.label,
    required this.amount,
    this.highlighted = false,
    this.isTotal = false,
  });

  final String label;
  final String amount;
  final bool highlighted;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    if (highlighted) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: _kExtraTimeRowBg,
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: kCaption14M.copyWith(color: _kExtraTimeText),
              ),
            ),
            Text(amount, style: kCaption14B.copyWith(color: _kExtraTimeText)),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: isTotal
                ? kCaption14B
                : kCaption14R.copyWith(color: kTextColor),
          ),
        ),
        Text(
          amount,
          style: isTotal
              ? kStyle(
                  kSemiBold,
                  kSize16,
                  color: _kTotalAmountBlue,
                  height: 1.1,
                )
              : kCaption14R.copyWith(color: kTextColor),
        ),
      ],
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 5.0;
        const dashSpace = 4.0;
        final dashCount = (constraints.maxWidth / (dashWidth + dashSpace))
            .floor();

        return Row(
          children: List.generate(dashCount, (index) {
            return Padding(
              padding: EdgeInsets.only(
                right: index < dashCount - 1 ? dashSpace : 0,
              ),
              child: Container(
                width: dashWidth,
                height: 1,
                color: kLineGrey.withValues(alpha: 0.9),
              ),
            );
          }),
        );
      },
    );
  }
}
