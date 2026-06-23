import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/models/user_model.dart';
import 'package:driveforme_driver/src/data/providers/user_provider.dart';
import 'package:driveforme_driver/src/interfaces/components/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _kDividerColor = Color(0xFFEEEEEE);
const _kIconCircleBg = Color(0xFFF2F2F2);
const _kRowIconColor = Color(0xFF8E8E93);

class PersonalInfoPage extends ConsumerWidget {
  const PersonalInfoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: kWhite,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: kWhite,
        body: SafeArea(
          child: userAsync.when(
            data: (user) => _PersonalInfoContent(user: user),
            loading: () => const Column(
              children: [
                _PersonalInfoHeader(),
                Expanded(child: Center(child: CircularProgressIndicator())),
              ],
            ),
            error: (_, _) => Column(
              children: [
                const _PersonalInfoHeader(),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Could not load personal details',
                          style: kCaption14B,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () => ref.invalidate(userProvider),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PersonalInfoContent extends StatelessWidget {
  const _PersonalInfoContent({required this.user});

  final UserModel? user;

  List<_PersonalInfoField> get _fields => [
        _PersonalInfoField(
          icon: Icons.person_outline_rounded,
          label: 'Name',
          value: displayFullName(user),
        ),
        _PersonalInfoField(
          icon: Icons.mail_outline_rounded,
          label: 'Email',
          value: displayEmail(user),
        ),
        _PersonalInfoField(
          icon: Icons.phone_outlined,
          label: 'Phone',
          value: displayPhone(user),
        ),
        _PersonalInfoField(
          icon: Icons.calendar_today_outlined,
          label: 'Date of birth',
          value: displayDateOfBirth(user),
        ),
        _PersonalInfoField(
          icon: Icons.wc_outlined,
          label: 'Gender',
          value: displayGender(user),
        ),
        _PersonalInfoField(
          icon: Icons.location_on_outlined,
          label: 'Location',
          value: displayLocation(user),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _PersonalInfoHeader(),
        const SizedBox(height: 28),
        Center(
          child: ProfileAvatar(
            imageUrl: profilePhotoUrl(user),
            size: 110,
          ),
        ),
        const SizedBox(height: 36),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: _fields.length,
            separatorBuilder: (_, _) => const Divider(
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
