import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/sos/sos_shared.dart';
import 'package:flutter/material.dart';

class SosHelpOnWayPage extends StatelessWidget {
  final String referenceNumber;
  final String locationLine1;
  final String locationLine2;
  final String supportPhone;

  const SosHelpOnWayPage({
    super.key,
    this.referenceNumber = 'SOS - 2014 - 9568',
    this.locationLine1 = 'MG Road, Eranakulam',
    this.locationLine2 = 'Kochi, Kerala, 9.9312 N, 76.2673 E',
    this.supportPhone = '+91 6282359916',
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: kSosScreenBg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _HelpOnWayHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                children: [
                  _ReferenceCard(referenceNumber: referenceNumber),
                  const SizedBox(height: 12),
                  _LocationCard(line1: locationLine1, line2: locationLine2),
                  const SizedBox(height: 12),
                  _SupportCard(phone: supportPhone),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, bottomInset + 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _BottomActionButton(
                        backgroundColor: kSosRed,
                        title: 'Call 112',
                        subtitle: 'Emergency Services',
                        titleColor: kWhite,
                        subtitleColor: kWhite,
                        borderColor: kSosRed,
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _BottomActionButton(
                        backgroundColor: kWhite,
                        title: 'I am safe',
                        subtitle: 'Cancel SOS alert',
                        titleColor: kTextColor,
                        subtitleColor: kMutedText,
                        borderColor: kCardBorder,
                        onTap: () => Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'Trip has been paused. Your data has been saved. Support team will contact you shortly',
                    textAlign: TextAlign.center,
                    style: kStyle(
                      kRegular,
                      kSize12,
                      color: kMutedText,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpOnWayHeader extends StatelessWidget {
  const _HelpOnWayHeader();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: kSosRed,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: SosBackButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: kWhite.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: const BoxDecoration(
                      color: kWhite,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: kSosRed,
                      size: 32,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Help is on the way',
                textAlign: TextAlign.center,
                style: kStyle(kSemiBold, kSize24, color: kWhite, height: 1.15),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: kStyle(
                      kRegular,
                      kSize14,
                      color: kWhite,
                      height: 1.35,
                    ),
                    children: const [
                      TextSpan(text: 'Emergency services notified . '),
                      TextSpan(
                        text: 'Drive4me',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: ' support alerted'),
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
}

class _ReferenceCard extends StatelessWidget {
  final String referenceNumber;

  const _ReferenceCard({required this.referenceNumber});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: kSosRefCardBg,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: kSosRed, width: 1),
      ),
      child: Column(
        children: [
          Text(
            'SOS REFERENCE NUMBER',
            style: kStyle(
              kSemiBold,
              kSize11,
              color: kSosRed,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            referenceNumber,
            textAlign: TextAlign.center,
            style: kStyle(kSemiBold, kSize20, color: kSosRedDark, height: 1.1),
          ),
          const SizedBox(height: 8),
          Text(
            'Quote this when speaking to emergency services',
            textAlign: TextAlign.center,
            style: kStyle(kRegular, kSize12, color: kSosRed, height: 1.3),
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final String line1;
  final String line2;

  const _LocationCard({required this.line1, required this.line2});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: kCardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR SHARED LOCATION',
            style: kStyle(
              kSemiBold,
              kSize11,
              color: kMutedText,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            line1,
            style: kStyle(kSemiBold, kSize16, color: kTextColor, height: 1.15),
          ),
          const SizedBox(height: 4),
          Text(
            line2,
            style: kStyle(kRegular, kSize13, color: kMutedText, height: 1.25),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: kActiveGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Live location being shared',
                style: kStyle(kMedium, kSize13, color: kActiveGreen),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  final String phone;

  const _SupportCard({required this.phone});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: kCardBorder, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: kSosSupportIconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.phone_in_talk_rounded,
              color: kTripCtaBlue,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Drive4me Support',
                  style: kStyle(kSemiBold, kSize15, color: kTextColor),
                ),
                const SizedBox(height: 3),
                Text(
                  '24/7 emergency line . $phone',
                  style: kStyle(
                    kRegular,
                    kSize12,
                    color: kTextColor,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: kTripCtaBlue,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 11,
                ),
                child: Text(
                  'Call Now',
                  style: kStyle(kSemiBold, kSize13, color: kWhite),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActionButton extends StatelessWidget {
  final Color backgroundColor;
  final Color borderColor;
  final Color titleColor;
  final Color subtitleColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _BottomActionButton({
    required this.backgroundColor,
    required this.borderColor,
    required this.titleColor,
    required this.subtitleColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: kStyle(
                  kSemiBold,
                  kSize17,
                  color: titleColor,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: kStyle(
                  kRegular,
                  kSize12,
                  color: subtitleColor,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
