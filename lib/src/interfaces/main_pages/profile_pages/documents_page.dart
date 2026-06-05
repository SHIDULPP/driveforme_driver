import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _kDividerColor = Color(0xFFEEEEEE);
const _kVerifiedBadgeBg = Color(0xFFE8F5EA);

class DocumentsPage extends StatelessWidget {
  const DocumentsPage({super.key});

  static const _documents = [
    _DocumentItem(
      imagePath: 'assets/pngs/ducuments.png',
      title: 'Aadhaar Card',
      isVerified: true,
    ),
    _DocumentItem(
      imagePath: 'assets/pngs/ducuments.png',
      title: 'Driving License',
      isVerified: true,
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
              const _DocumentsHeader(),
              const Divider(height: 1, thickness: 1, color: _kDividerColor),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    for (var i = 0; i < _documents.length; i++) ...[
                      _DocumentRow(document: _documents[i], onTap: () {}),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: _kDividerColor,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentItem {
  const _DocumentItem({
    required this.imagePath,
    required this.title,
    required this.isVerified,
  });

  final String imagePath;
  final String title;
  final bool isVerified;
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
              Image.asset(
                document.imagePath,
                width: 48,
                height: 34,
                fit: BoxFit.contain,
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
                    if (document.isVerified) ...[
                      const SizedBox(height: 6),
                      const _VerifiedBadge(),
                    ],
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
