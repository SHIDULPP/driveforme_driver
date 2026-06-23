import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/models/user_model.dart';
import 'package:driveforme_driver/src/data/providers/user_provider.dart';
import 'package:driveforme_driver/src/interfaces/components/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _kMenuItems = [
  'Personal Details',
  'Documents',
  'Help & Support',
  'Notifications',
  'Refer & Earn',
  'About us',
  'FAQ',
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Text(
                  'Profile',
                  style: kStyle(
                    kMedium,
                    kSize30,
                    color: kTextColor,
                    height: 1.15,
                  ),
                ),
              ),
              Expanded(
                child: userAsync.when(
                  data: (user) => ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    children: [
                      _ProfileSummaryCard(user: user),
                      const SizedBox(height: 14),
                      const _ProfileMenuCard(),
                      const SizedBox(height: 32),
                      const _ProfileFooter(),
                    ],
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, _) => _ProfileErrorState(
                    onRetry: () => ref.invalidate(userProvider),
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

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({required this.user});

  final UserModel? user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(18),
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
          ProfileAvatar(
            imageUrl: profilePhotoUrl(user),
            size: 64,
            borderRadius: BorderRadius.circular(32),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayFullName(user),
                  style: kStyle(
                    kSemiBold,
                    kSize18,
                    color: kTextColor,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      displayRating(user),
                      style: kCaption14M.copyWith(
                        color: kTextColor,
                        fontWeight: kSemiBold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    ProfileRatingStars(rating: user?.rating ?? 5.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Container(
                        height: 4,
                        width: 4,
                        decoration: const BoxDecoration(
                          color: kMutedText,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        displayTotalTrips(user),
                        style: kCaption13R.copyWith(color: kMutedText),
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

void _onMenuTap(BuildContext context, String title) {
  switch (title) {
    case 'Personal Details':
      Navigator.pushNamed(context, 'personalInfo');
    case 'Documents':
      Navigator.pushNamed(context, 'documentsPage');
    case 'Help & Support':
      Navigator.pushNamed(context, 'helpAndSupportPage');
    case 'Notifications':
      Navigator.pushNamed(context, 'notificationsPage');
    case 'Refer & Earn':
      Navigator.pushNamed(context, 'referPage');
    case 'About us':
      Navigator.pushNamed(context, 'aboutUsPage');
    case 'FAQ':
      Navigator.pushNamed(context, 'faqPage');
  }
}

class _ProfileMenuCard extends StatelessWidget {
  const _ProfileMenuCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: kBlack.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(_kMenuItems.length, (index) {
          final isLast = index == _kMenuItems.length - 1;
          return Column(
            children: [
              _ProfileMenuTile(
                title: _kMenuItems[index],
                onTap: () => _onMenuTap(context, _kMenuItems[index]),
              ),
              if (!isLast)
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: kCardBorder,
                  indent: 16,
                  endIndent: 16,
                ),
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
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: kMenuItemM,
                ),
              ),
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
              'Could not load profile',
              style: kCaption14B,
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
