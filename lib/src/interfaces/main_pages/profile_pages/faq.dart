import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _kDividerColor = Color(0xFFEEEEEE);

class _FaqItem {
  const _FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;
}

const _kFaqItems = [
  _FaqItem(
    question: 'How do I go online to receive trip requests?',
    answer:
        'Open the Home tab and toggle "You are Offline" to online. You will '
        'start receiving trip requests based on your selected trip '
        'preference and location.',
  ),
  _FaqItem(
    question: 'How is my fare calculated?',
    answer:
        'Fares are calculated based on trip distance, duration, and the '
        'trip type (short or long trip) you accept. The estimated fare is '
        'shown before you accept a request.',
  ),
  _FaqItem(
    question: 'When do I get paid for completed trips?',
    answer:
        'Earnings from completed trips are added to your wallet '
        'automatically. You can view your balance and withdraw to your '
        'linked bank account from the Earnings tab.',
  ),
  _FaqItem(
    question: 'What documents do I need to keep updated?',
    answer:
        'Keep your Aadhaar card, driving license, and live photo up to '
        'date under Documents. Verified documents help you get more trip '
        'requests.',
  ),
  _FaqItem(
    question: 'Can I change my trip preference later?',
    answer:
        'Yes. You can switch between Short Trip and Long Trip anytime from '
        'the Trip Preference card on your Home screen.',
  ),
  _FaqItem(
    question: 'How do I contact support during a trip?',
    answer:
        'Use the SOS button during an active trip for emergencies, or '
        'reach out from Help & Support for general assistance.',
  ),
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
            'FAQ',
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
                      item.question,
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
                    item.answer,
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
