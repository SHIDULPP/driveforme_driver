import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/models/user_model.dart';
import 'package:driveforme_driver/src/data/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

const _kDividerColor = Color(0xFFEEEEEE);
const _kVerifiedBadgeBg = Color(0xFFE8F5EA);
const _kPendingBadgeBg = Color(0xFFFFF3E8);
const _kPendingBadgeText = Color(0xFFC6934B);

class DocumentsPage extends ConsumerWidget {
  const DocumentsPage({super.key});

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _DocumentsHeader(),
              const Divider(height: 1, thickness: 1, color: _kDividerColor),
              Expanded(
                child: userAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => Center(
                    child: TextButton(
                      onPressed: () => ref.invalidate(userProvider),
                      child: const Text('Retry'),
                    ),
                  ),
                  data: (user) {
                    if (user == null) {
                      return const Center(child: Text('No profile data.'));
                    }

                    final docs = _documentsFor(user);
                    if (docs.isEmpty) {
                      return Center(
                        child: Text(
                          'No documents uploaded yet.',
                          style: kCaption14R.copyWith(color: kMutedText),
                        ),
                      );
                    }

                    return ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        for (var i = 0; i < docs.length; i++) ...[
                          _DocumentRow(
                            document: docs[i],
                            onTap: () => _openDocument(context, docs[i]),
                          ),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: _kDividerColor,
                          ),
                        ],
                      ],
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

  List<_DocumentItem> _documentsFor(UserModel user) {
    final verification = user.driverVerification;
    final isApproved = user.onboardingStatus == 'approved';
    final isRejected = user.isOnboardingRejected;

    return [
      if (verification.aadhaarImageUrl.isNotEmpty)
        _DocumentItem(
          title: 'Aadhaar Card',
          url: verification.aadhaarImageUrl,
          isVerified: isApproved,
          isPending: !isApproved && !isRejected,
        ),
      if (verification.drivingLicenseImageUrl.isNotEmpty)
        _DocumentItem(
          title: 'Driving License',
          url: verification.drivingLicenseImageUrl,
          isVerified: isApproved,
          isPending: !isApproved && !isRejected,
        ),
      if (verification.livePhotoUrl.isNotEmpty)
        _DocumentItem(
          title: 'Live Photo',
          url: verification.livePhotoUrl,
          isVerified: isApproved,
          isPending: !isApproved && !isRejected,
        ),
    ];
  }

  Future<void> _openDocument(BuildContext context, _DocumentItem document) async {
    final uri = Uri.tryParse(document.url);
    if (uri == null) return;

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open document.')),
      );
    }
  }
}

class _DocumentItem {
  const _DocumentItem({
    required this.title,
    required this.url,
    required this.isVerified,
    required this.isPending,
  });

  final String title;
  final String url;
  final bool isVerified;
  final bool isPending;
}

class _DocumentsHeader extends StatelessWidget {
  const _DocumentsHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 12),
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
            'Documents',
            style: kStyle(kMedium, kSize18, color: kTextColor, height: 1.2),
          ),
        ],
      ),
    );
  }
}

class _DocumentRow extends StatelessWidget {
  const _DocumentRow({required this.document, required this.onTap});

  final _DocumentItem document;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 34,
                decoration: BoxDecoration(
                  color: kSearchFieldBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kCardBorder),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: kBrandBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title,
                      style: kStyle(
                        kSemiBold,
                        kSize16,
                        color: kTextColor,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (document.isVerified)
                      const _VerifiedBadge()
                    else if (document.isPending)
                      const _PendingBadge(),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: kTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _kVerifiedBadgeBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Verified',
            style: kStyle(kMedium, kSize11, color: kActiveGreen, height: 1.1),
          ),
          const SizedBox(width: 4),
          Container(
            height: 14,
            width: 14,
            decoration: const BoxDecoration(
              color: kActiveGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, size: 10, color: kWhite),
          ),
        ],
      ),
    );
  }
}

class _PendingBadge extends StatelessWidget {
  const _PendingBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _kPendingBadgeBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Under review',
        style: kStyle(kMedium, kSize11, color: _kPendingBadgeText, height: 1.1),
      ),
    );
  }
}
