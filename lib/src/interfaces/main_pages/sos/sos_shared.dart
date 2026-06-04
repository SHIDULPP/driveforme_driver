import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:flutter/material.dart';

class SosEmergencyOption {
  final String title;
  final String subtitle;
  final IconData icon;

  const SosEmergencyOption({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

const kDefaultSosOptions = [
  SosEmergencyOption(
    title: 'Accident / Road Emergency',
    subtitle: 'Vehicle accident, road hazard, injury',
    icon: Icons.campaign_rounded,
  ),
  SosEmergencyOption(
    title: 'Medical Emergency',
    subtitle: 'Driver or passenger needs medical help',
    icon: Icons.medical_services_rounded,
  ),
  SosEmergencyOption(
    title: 'Unsafe passenger behavior',
    subtitle: 'Threatening or aggressive vehicle owner',
    icon: Icons.local_police_rounded,
  ),
  SosEmergencyOption(
    title: 'Other Emergency',
    subtitle: 'Any other situation requiring help',
    icon: Icons.report_rounded,
  ),
];

class SosBackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SosBackButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: kWhite,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: const SizedBox(
            width: 40,
            height: 40,
            child: Icon(Icons.arrow_back_ios_new, size: 18, color: kTextColor),
          ),
        ),
      ),
    );
  }
}

class SosLocationPill extends StatelessWidget {
  final String text;

  const SosLocationPill({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: kWhite.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: kWhite,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: kStyle(kRegular, kSize13, color: kWhite, height: 1.2),
            ),
          ),
        ],
      ),
    );
  }
}

class SosEmergencyTypeCard extends StatelessWidget {
  final SosEmergencyOption option;
  final VoidCallback onTap;

  const SosEmergencyTypeCard({
    super.key,
    required this.option,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kSosCardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: kSosRedDark, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: kSosRed,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(option.icon, color: kWhite, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: kStyle(kSemiBold, kSize15, color: kSosRedDark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.subtitle,
                      style: kStyle(kRegular, kSize13, color: kSosRedDark),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: kSosRedDark,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SosWhatHappensStep extends StatelessWidget {
  final int step;
  final String text;

  const SosWhatHappensStep({super.key, required this.step, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: kSosRed,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$step',
            style: kStyle(kSemiBold, kSize14, color: kWhite),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              text,
              style: kStyle(kRegular, kSize15, color: kTextColor, height: 1.35),
            ),
          ),
        ),
      ],
    );
  }
}
