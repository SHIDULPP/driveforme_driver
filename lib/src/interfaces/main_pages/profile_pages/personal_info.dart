import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/models/user_model.dart';
import 'package:driveforme_driver/src/data/providers/user_provider.dart';
import 'package:driveforme_driver/src/interfaces/components/profile_avatar.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/profile_pages/edit_profile_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _kDividerColor = Color(0xFFEEEEEE);

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
          label: 'Name',
          value: displayFullName(user),
        ),
        _PersonalInfoField(
          label: 'Mobile Number',
          value: displayPhone(user),
        ),
        _PersonalInfoField(
          label: 'Email',
          value: displayEmail(user),
        ),
        _PersonalInfoField(
          label: 'Date of Birth',
          value: displayDateOfBirth(user),
        ),
        _PersonalInfoField(
          label: 'Gender',
          value: displayGender(user),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PersonalInfoHeader(
          onEdit: user == null
              ? null
              : () => EditProfileSheet.show(context, user!),
        ),
        const SizedBox(height: 28),
        Center(
          child: ProfileAvatar(
            imageUrl: profilePhotoUrl(user),
            initials: profileInitials(user),
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
              indent: 20,
              endIndent: 20,
              color: _kDividerColor,
            ),
            itemBuilder: (context, index) {
              final field = _fields[index];
              return _PersonalInfoRow(
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
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

class _PersonalInfoHeader extends StatelessWidget {
  const _PersonalInfoHeader({this.onEdit});

  final VoidCallback? onEdit;

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
            'Personal Details',
            style: kStyle(
              kMedium,
              kSize18,
              color: kTextColor,
              height: 1.2,
            ),
          ),
          const Spacer(),
          if (onEdit != null)
            IconButton(
              onPressed: onEdit,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              icon: const Icon(
                Icons.edit_outlined,
                size: 22,
                color: kBrandBlue,
              ),
            ),
        ],
      ),
    );
  }
}

class _PersonalInfoRow extends StatelessWidget {
  const _PersonalInfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
          const SizedBox(height: 6),
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
    );
  }
}
