import 'package:DriveFormeDriver/src/data/constants/color_constants.dart';
import 'package:DriveFormeDriver/src/data/constants/global_variables.dart';
import 'package:DriveFormeDriver/src/data/constants/style_constans.dart';
import 'package:DriveFormeDriver/src/data/models/user_model.dart';
import 'package:DriveFormeDriver/src/data/providers/notification_provider.dart';
import 'package:DriveFormeDriver/src/data/providers/user_provider.dart';
import 'package:DriveFormeDriver/src/data/services/auth_logout_service.dart';
import 'package:DriveFormeDriver/src/data/services/navigation_services.dart';
import 'package:DriveFormeDriver/src/data/services/secure_storage_service.dart';
import 'package:DriveFormeDriver/src/data/utils/responsive.dart';
import 'package:DriveFormeDriver/src/interfaces/components/profile_avatar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _kMenuItemKeys = [
  'personalDetails',
  'documents',
  'notifications',
  'referAndEarn',
  'faq',
  'language',
];

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: kScreenBg,
        body: SafeArea(
          child: userAsync.when(
            data: (user) => ListView(
              padding: EdgeInsets.fromLTRB(
                context.horizontalPadding,
                context.rs(22),
                context.horizontalPadding,
                context.scaffoldBottomPadding,
              ),
              children: [
                _ProfileSummaryCard(user: user),
                const SizedBox(height: 8),
                const _ProfileMenuCard(),
                const SizedBox(height: 8),
                const _ProfileLogoutCard(),
                const SizedBox(height: 24),
                const _ProfileFooter(),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => _ProfileErrorState(
              onRetry: () => ref.invalidate(userProvider),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileSummaryCard extends ConsumerWidget {
  const _ProfileSummaryCard({required this.user});

  final UserModel? user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarSize = context.rs(60);
    final isVerified = user?.onboardingStatus == 'approved';
    final ratingAsync = ref.watch(effectiveDriverRatingProvider);
    final rating = ratingAsync.maybeWhen(
      data: (value) => value ?? user?.rating,
      orElse: () => user?.rating,
    );

    return Container(
      padding: EdgeInsets.all(context.rs(16)),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(context.rs(12)),
        border: Border.all(color: kCardBorder, width: 0.6),
        boxShadow: [
          BoxShadow(
            color: kBlack.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ProfileAvatar(
                imageUrl: profilePhotoUrl(user),
                initials: profileInitials(user),
                size: avatarSize,
                borderRadius: BorderRadius.circular(avatarSize / 2),
              ),
              if (isVerified)
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(1.5),
                    decoration: const BoxDecoration(
                      color: kWhite,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.verified_rounded,
                      size: context.rs(18),
                      color: kActiveGreen,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: context.rs(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayFullName(user),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: kStyle(
                    kMedium,
                    kSize18,
                    color: kTextColor,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: context.rs(3)),
                Row(
                  children: [
                    Text(
                      formatDriverRating(rating),
                      style: kStyle(kLight, kSize12, color: kDarkText),
                    ),
                    SizedBox(width: context.rs(5)),
                    ProfileRatingStars(
                      rating: rating ?? 0,
                      size: context.rs(13),
                    ),
                    SizedBox(width: context.rs(5)),
                    Container(
                      height: context.rs(4),
                      width: context.rs(4),
                      decoration: const BoxDecoration(
                        color: kMutedText,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: context.rs(5)),
                    Flexible(
                      child: Text(
                        displayTotalTrips(user),
                        style: kStyle(kLight, kSize12, color: kDarkText),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _onMenuTap(BuildContext context, WidgetRef ref, String key) {
  switch (key) {
    case 'personalDetails':
      Navigator.pushNamed(context, 'personalInfo');
    case 'documents':
      Navigator.pushNamed(context, 'documentsPage');
    case 'notifications':
      Navigator.pushNamed(context, 'notificationsPage');
    case 'referAndEarn':
      Navigator.pushNamed(context, 'referPage');
    case 'faq':
      Navigator.pushNamed(context, 'faqPage');
    case 'language':
      _showLanguageDialog(context, ref);
  }
}

void _showLanguageDialog(BuildContext context, WidgetRef ref) {
  final currentLanguage = GlobalVariables.preferredLanguage;

  showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: kWhite,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'language'.tr(),
              style: kStyle(kMedium, kSize18, color: kTextColor),
            ),
            const SizedBox(height: 20),
            _LanguageOption(
              languageName: 'english'.tr(),
              isSelected: currentLanguage == 'en',
              onSelected: () =>
                  _changeLanguage(context, ref, 'en', 'english'.tr()),
            ),
            const SizedBox(height: 10),
            _LanguageOption(
              languageName: 'malayalam'.tr(),
              isSelected: currentLanguage == 'ml',
              onSelected: () =>
                  _changeLanguage(context, ref, 'ml', 'malayalam'.tr()),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  'close'.tr(),
                  style: kStyle(kRegular, kSize14, color: kSecondaryTextColor),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _changeLanguage(
  BuildContext context,
  WidgetRef ref,
  String languageCode,
  String languageName,
) async {
  try {
    GlobalVariables.setPreferredLanguage(languageCode);
    await context.setLocale(Locale(languageCode));
    await ref
        .read(secureStorageServiceProvider)
        .setPreferredLanguage(languageCode);

    if (!context.mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${'languageChanged'.tr()} $languageName'),
        duration: const Duration(seconds: 2),
      ),
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${'errorChangingLanguage'.tr()} $e'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.languageName,
    required this.isSelected,
    required this.onSelected,
  });

  final String languageName;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isSelected) {
          Navigator.of(context).pop();
          return;
        }
        onSelected();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? kPrimaryColor.withValues(alpha: 0.08)
              : kBackgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? kPrimaryColor.withValues(alpha: 0.3)
                : kStrokeColor.withValues(alpha: 0.15),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              languageName,
              style: kStyle(
                isSelected ? kMedium : kRegular,
                kSize14,
                color: isSelected ? kPrimaryColor : kTextColor,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, size: 18, color: kPrimaryColor)
            else
              Icon(
                Icons.circle_outlined,
                size: 18,
                color: kGreyDark.withValues(alpha: 0.5),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuCard extends ConsumerWidget {
  const _ProfileMenuCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.rs(20),
        vertical: context.rs(20),
      ),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(context.rs(12)),
        boxShadow: [
          BoxShadow(
            color: kBlack.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(_kMenuItemKeys.length, (index) {
          final key = _kMenuItemKeys[index];
          final isLast = index == _kMenuItemKeys.length - 1;
          return Column(
            children: [
              _ProfileMenuTile(
                title: key.tr(),
                badgeCount: key == 'notifications' ? unreadCount : 0,
                onTap: () => _onMenuTap(context, ref, key),
              ),
              if (!isLast) SizedBox(height: context.rs(24)),
            ],
          );
        }),
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.title,
    required this.onTap,
    this.badgeCount = 0,
    this.titleColor,
  });

  final String title;
  final VoidCallback onTap;
  final int badgeCount;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: context.rs(2)),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: titleColor == null
                      ? kMenuItemM
                      : kMenuItemM.copyWith(color: titleColor),
                ),
              ),
              if (badgeCount > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: kBrandBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badgeCount > 99 ? '99+' : '$badgeCount',
                    style: kCaption11R.copyWith(
                      color: kWhite,
                      fontWeight: kSemiBold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              const Icon(
                Icons.chevron_right_rounded,
                color: kChevronGrey,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileLogoutCard extends ConsumerWidget {
  const _ProfileLogoutCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.rs(20),
        vertical: context.rs(20),
      ),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(context.rs(12)),
        boxShadow: [
          BoxShadow(
            color: kBlack.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _ProfileMenuTile(
            title: 'logout'.tr(),
            titleColor: kDangerRed,
            onTap: () => _confirmLogout(context, ref),
          ),
          SizedBox(height: context.rs(24)),
          _ProfileMenuTile(
            title: 'deleteAccount'.tr(),
            titleColor: kDangerRed,
            onTap: () => _confirmDeleteAccount(context),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('logOutTitle'.tr()),
        content: Text('logOutMessage'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('logOut'.tr()),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await ref.read(authLogoutServiceProvider).logout(ref);
    if (!context.mounted) return;
    NavigationService().pushNamedAndRemoveUntil('Phone');
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('deleteAccountTitle'.tr()),
        content: Text('deleteAccountMessage'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'delete'.tr(),
              style: const TextStyle(color: kDangerRed),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileFooter extends StatelessWidget {
  const _ProfileFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/pngs/drive_forme_logo.png',
          width: 120,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 8),
        Text(
          'v4.625.100005',
          style: kVersionR,
        ),
      ],
    );
  }
}

class _ProfileErrorState extends StatelessWidget {
  const _ProfileErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'couldNotLoadProfile'.tr(),
              style: kCaption14B,
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: Text('retry'.tr())),
          ],
        ),
      ),
    );
  }
}
