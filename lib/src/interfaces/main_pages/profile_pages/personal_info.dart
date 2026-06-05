import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _kAvatarBg = Color(0xFFE8E8E8);
const _kAvatarIconColor = Color(0xFFB0B0B0);
const _kIconCircleBg = Color(0xFFF2F2F2);
const _kRowIconColor = Color(0xFF8E8E93);
const _kDividerColor = Color(0xFFEEEEEE);

class PersonalInfoPage extends StatelessWidget {
  const PersonalInfoPage({super.key});

  static const _fields = [
    _PersonalInfoField(
      icon: Icons.person_outline_rounded,
      label: 'Name',
      value: 'John Smith',
    ),
    _PersonalInfoField(
      icon: Icons.mail_outline_rounded,
      label: 'Email',
      value: 'john.smith@example.com',
    ),
    _PersonalInfoField(
      icon: Icons.phone_outlined,
      label: 'Phone',
      value: '+249 123-4567',
    ),
    _PersonalInfoField(
      icon: Icons.calendar_today_outlined,
      label: 'Date of birth',
      value: '02/02/1998',
    ),
  ];

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
              const _PersonalInfoHeader(),
              const SizedBox(height: 28),
              const _ProfileAvatarPlaceholder(),
              const SizedBox(height: 36),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: _fields.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    thickness: 1,
                    color: _kDividerColor,
                  ),
                  itemBuilder: (context, index) {
                    final field = _fields[index];
                    return _PersonalInfoRow(
                      icon: field.icon,
                      label: field.label,
                      value: field.value,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PersonalInfoField {
  const _PersonalInfoField({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _PersonalInfoHeader extends StatelessWidget {
  const _PersonalInfoHeader();

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
            'Personal Details',
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

class _ProfileAvatarPlaceholder extends StatelessWidget {
  const _ProfileAvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 110,
        width: 110,
        decoration: const BoxDecoration(
          color: _kAvatarBg,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.person_outline_rounded,
          size: 52,
          color: _kAvatarIconColor,
        ),
      ),
    );
  }
}

class _PersonalInfoRow extends StatelessWidget {
  const _PersonalInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: const BoxDecoration(
              color: _kIconCircleBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: _kRowIconColor,
            ),
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
                    kSize16,
                    color: kTextColor,
                    height: 1.25,
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
