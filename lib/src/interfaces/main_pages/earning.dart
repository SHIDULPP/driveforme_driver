import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _kEarningsHeaderBlue = Color(0xFF1A5288);
const _kEarningsPageBg = Color(0xFFF8FAF5);
const _kEarningsGold = Color(0xFFC6934B);
const _kStatValueBlue = Color(0xFF205D91);
const _kChartBarInactive = Color(0xFFF0EDE6);
const _kSegmentInactiveBg = Color(0xFFF5F3EE);

enum _EarningsSection { earnings, transactions }

class EarningPage extends StatefulWidget {
  const EarningPage({super.key});

  @override
  State<EarningPage> createState() => _EarningPageState();
}

class _EarningPageState extends State<EarningPage> {
  _EarningsSection _section = _EarningsSection.earnings;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: _kEarningsHeaderBlue,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _kEarningsPageBg,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _EarningsHeader(),
            _EarningsSegmentedTabs(
              selected: _section,
              onChanged: (value) => setState(() => _section = value),
            ),
            Expanded(
              child: _section == _EarningsSection.earnings
                  ? _EarningsTabContent()
                  : _TransactionsPlaceholder(),
            ),
          ],
        ),
      ),
    );
  }
}

class _EarningsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Container(
      color: _kEarningsHeaderBlue,
      padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your total Balance',
                  style: kCaption14R.copyWith(
                    color: kWhite.withValues(alpha: 0.78),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '₹ 150',
                  style: kStyle(
                    kSemiBold,
                    kSize30,
                    color: kWhite,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Used to receive ride request',
                  style: kCaption12R.copyWith(
                    color: kWhite.withValues(alpha: 0.7),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: _kEarningsGold,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, color: kWhite, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      'Add Balance',
                      style: kStyle(
                        kMedium,
                        kSize13,
                        color: kWhite,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EarningsSegmentedTabs extends StatelessWidget {
  const _EarningsSegmentedTabs({
    required this.selected,
    required this.onChanged,
  });

  final _EarningsSection selected;
  final ValueChanged<_EarningsSection> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _SegmentTab(
              label: 'Earnings',
              isSelected: selected == _EarningsSection.earnings,
              onTap: () => onChanged(_EarningsSection.earnings),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SegmentTab(
              label: 'Transactions',
              isSelected: selected == _EarningsSection.transactions,
              onTap: () => onChanged(_EarningsSection.transactions),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentTab extends StatelessWidget {
  const _SegmentTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? _kEarningsGold : _kSegmentInactiveBg,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: kStyle(
            isSelected ? kSemiBold : kMedium,
            kSize14,
            color: isSelected ? kWhite : kTextColor,
            height: 1.1,
          ),
        ),
      ),
    );
  }
}

class _EarningsTabContent extends StatelessWidget {
  static const _barHeights = [0.42, 0.58, 0.48, 0.62, 0.52, 0.55, 0.88];
  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        const Row(
          children: [
            Expanded(
              child: _StatSummaryCard(
                value: '₹ 2,035',
                label: 'Total Earnings',
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _StatSummaryCard(
                value: '20',
                label: 'Total Trips',
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _StatSummaryCard(
                value: '4.9',
                label: 'Rating',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kCardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: kCaption14R.copyWith(
                          color: kTextColor,
                          height: 1.3,
                        ),
                        children: [
                          const TextSpan(text: 'This week - '),
                          TextSpan(
                            text: '₹ 2,035 total',
                            style: kStyle(
                              kSemiBold,
                              kSize14,
                              color: _kStatValueBlue,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: kSearchFieldBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: kCardBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'This week',
                          style: kCaption13R.copyWith(color: kTextColor),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: kTextColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (index) {
                    final isHighlight = index == 6;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: index == 0 ? 0 : 4,
                          right: index == 6 ? 0 : 4,
                        ),
                        child: _WeeklyBar(
                          heightFactor: _barHeights[index],
                          dayLabel: _dayLabels[index],
                          isHighlighted: isHighlight,
                          amountLabel: '₹ 2,035',
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatSummaryCard extends StatelessWidget {
  const _StatSummaryCard({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _kEarningsGold.withValues(alpha: 0.65),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: kStyle(
                kSemiBold,
                kSize18,
                color: _kStatValueBlue,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: kCaption11R.copyWith(
              color: kTextColor,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyBar extends StatelessWidget {
  const _WeeklyBar({
    required this.heightFactor,
    required this.dayLabel,
    required this.isHighlighted,
    required this.amountLabel,
  });

  final double heightFactor;
  final String dayLabel;
  final bool isHighlighted;
  final String amountLabel;

  @override
  Widget build(BuildContext context) {
    const maxBarHeight = 120.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: 14,
          child: RotatedBox(
            quarterTurns: 3,
            child: Text(
              amountLabel,
              maxLines: 1,
              style: kCaption11R.copyWith(
                color: kMutedText.withValues(alpha: 0.65),
                fontSize: 9,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: maxBarHeight * heightFactor,
          decoration: BoxDecoration(
            color: isHighlighted ? _kEarningsGold : _kChartBarInactive,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          dayLabel,
          style: kCaption13R.copyWith(
            color: kTextColor,
            fontWeight: kMedium,
          ),
        ),
      ],
    );
  }
}

class _TransactionsPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No transactions yet',
        style: kCaption14R.copyWith(color: kMutedText),
      ),
    );
  }
}
