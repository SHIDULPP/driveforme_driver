import 'package:DriveFormeDriver/src/data/constants/color_constants.dart';
import 'package:DriveFormeDriver/src/data/constants/style_constans.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _kDividerColor = Color(0xFFEEEEEE);

class _FaqItem {
  const _FaqItem({required this.questionKey, required this.answerKey});

  final String questionKey;
  final String answerKey;
}

const _kFaqItems = [
  _FaqItem(questionKey: 'faqQGoOnline', answerKey: 'faqAGoOnline'),
  _FaqItem(questionKey: 'faqQFare', answerKey: 'faqAFare'),
  _FaqItem(questionKey: 'faqQPaid', answerKey: 'faqAPaid'),
  _FaqItem(questionKey: 'faqQDocuments', answerKey: 'faqADocuments'),
  _FaqItem(questionKey: 'faqQPreference', answerKey: 'faqAPreference'),
  _FaqItem(questionKey: 'faqQSupport', answerKey: 'faqASupport'),
];

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  int? _expandedIndex = 0;

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
              const _FaqPageHeader(),
              const Divider(height: 1, thickness: 1, color: _kDividerColor),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _kFaqItems.length,
                  separatorBuilder: (_, _) => const Divider(
                    height: 1,
                    thickness: 1,
                    color: _kDividerColor,
                  ),
                  itemBuilder: (context, index) {
                    final item = _kFaqItems[index];
                    final isExpanded = _expandedIndex == index;
                    return _FaqTile(
                      item: item,
                      isExpanded: isExpanded,
                      onTap: () => setState(
                        () => _expandedIndex = isExpanded ? null : index,
                      ),
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

class _FaqPageHeader extends StatelessWidget {
  const _FaqPageHeader();

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
            'faq'.tr(),
            style: kStyle(kMedium, kSize18, color: kTextColor, height: 1.2),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({
    required this.item,
    required this.isExpanded,
    required this.onTap,
  });

  final _FaqItem item;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.questionKey.tr(),
                      style: kStyle(
                        kMedium,
                        kSize15,
                        color: kTextColor,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: isExpanded ? 0.5 : 0,
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: kBrandBlue,
                      size: 22,
                    ),
                  ),
                ],
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                crossFadeState: isExpanded
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    item.answerKey.tr(),
                    style: kCaption13R.copyWith(
                      color: kTripBodyMuted,
                      height: 1.45,
                    ),
                  ),
                ),
                secondChild: const SizedBox(width: double.infinity),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
