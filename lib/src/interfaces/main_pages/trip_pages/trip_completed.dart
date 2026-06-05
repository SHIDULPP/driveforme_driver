import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/interfaces/components/primarybutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _kHeaderGreen = Color(0xFF17A34A);
const _kTotalEarnedBg = Color(0xFF128C3A);
const _kExtraTimeRowBg = Color(0xFFFFF3E8);
const _kExtraTimeText = Color(0xFFC6934B);
const _kTotalAmountBlue = Color(0xFF205D91);

class TripCompletedScreen extends StatelessWidget {
  const TripCompletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final sheetTop = screenHeight * 0.52;

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
                        'Edappally, Lulu mall  →  Infopark, Kakkanad  02 h 5 min',
                        textAlign: TextAlign.center,
                        style: kCaption14R.copyWith(
                          color: kWhite.withValues(alpha: 0.95),
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const _TotalEarnedBadge(),
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
                      const _PaymentSummaryCard(),
                      const Spacer(),
                      primaryButton(
                        label: 'Mark as Collected',
                        buttonHeight: 52,
                        fontSize: kSize16,
                        buttonColor: kTripCtaBlue,
                        labelColor: kWhite,
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context,
                            'cashCollected',
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
  const _TotalEarnedBadge();

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
            '₹ 235',
            style: kStyle(kSemiBold, kSize24, color: kWhite, height: 1.05),
          ),
        ],
      ),
    );
  }
}

class _PaymentSummaryCard extends StatelessWidget {
  const _PaymentSummaryCard();

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
                const _PaymentRow(label: 'Base fare (2 hrs)', amount: '₹ 235'),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _DashedDivider(),
          ),
          const _PaymentRow(
            label: 'Extra Time (30 min)',
            amount: '₹ 120',
            highlighted: true,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: const _PaymentRow(
              label: 'Total Amount',
              amount: '₹ 355',
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
