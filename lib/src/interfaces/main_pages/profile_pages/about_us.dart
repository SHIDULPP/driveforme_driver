import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

const _kDividerColor = Color(0xFFEEEEEE);
const _kIconCircleBg = Color(0xFFF2F2F2);
const _kRowIconColor = Color(0xFF8E8E93);

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
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
              const _AboutUsHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      Image.asset(
                        'assets/pngs/drive_forme_logo.png',
                        height: 64,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Drive For Me',
                        textAlign: TextAlign.center,
                        style: kStyle(
                          kSemiBold,
                          kSize22,
                          color: kTextColor,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Reliable drivers, whenever and wherever you need one.',
                        textAlign: TextAlign.center,
                        style: kCaption14R.copyWith(
                          color: kTripBodyMuted,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: _kDividerColor,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Drive For Me connects skilled, verified drivers with '
                        'people who need a ride or a driver for their own '
                        'vehicle. Our mission is to make every trip safe, '
                        'transparent, and rewarding — for drivers and '
                        'customers alike.',
                        textAlign: TextAlign.center,
                        style: kCaption14R.copyWith(
                          color: kTextColor,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: _kDividerColor,
                      ),
                      _AboutUsRow(
                        icon: Icons.language_rounded,
                        label: 'Website',
                        value: 'www.driveforme.in',
                        onTap: () => _openUrl('https://www.driveforme.in'),
                      ),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: _kDividerColor,
                      ),
                      _AboutUsRow(
                        icon: Icons.mail_outline_rounded,
                        label: 'Support email',
                        value: 'support@driveforme.in',
                        onTap: () =>
                            _openUrl('mailto:support@driveforme.in'),
                      ),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: _kDividerColor,
                      ),
                      _AboutUsRow(
                        icon: Icons.description_outlined,
                        label: 'Terms & Privacy Policy',
                        value: 'View',
                        onTap: () => _openUrl('https://www.driveforme.in/legal'),
                      ),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: _kDividerColor,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'v4.625.100005',
                        style: kVersionR,
                      ),
                      const SizedBox(height: 24),
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

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _AboutUsHeader extends StatelessWidget {
  const _AboutUsHeader();

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
            'About us',
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

class _AboutUsRow extends StatelessWidget {
  const _AboutUsRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: const BoxDecoration(
                  color: _kIconCircleBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: _kRowIconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: kCaption12R.copyWith(
                        color: kMutedText,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: kStyle(
                        kSemiBold,
                        kSize15,
                        color: kBrandBlue,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: kChevronGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
