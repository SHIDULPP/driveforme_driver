import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _kEarningsHeaderBlue = Color(0xFF1A5288);
const _kEarningsGold = Color(0xFFC6934B);
const _kStatValueBlue = Color(0xFF205D91);
const _kChartBarInactive = Color(0xFFF3F0E8);
const _kChartAmountMuted = Color(0xFFB8B0A4);

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
        backgroundColor: kScreenBg,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _EarningsHeader(),
            _EarningsSegmentedTabs(
              selected: _section,
              onChanged: (value) => setState(() => _section = value),
            ),
            Expanded(
              child: _section == _EarningsSection.earnings
                  ? const _EarningsTabContent()
                  : const _TransactionsPlaceholder(),
            ),
          ],
        ),
      ),
    );
  }
}

class _EarningsHeader extends StatelessWidget {
  const _EarningsHeader();

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Container(
      // height: 150,
      color: _kEarningsHeaderBlue,
      padding: EdgeInsets.fromLTRB(20, topPadding + 12, 20, 20),
      child: Column(
        children: [
          SizedBox(height: 70),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your total Balance',
                      style: kCaption14R.copyWith(
                        color: kWhite.withValues(alpha: 0.75),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹ 150',
                      style: kStyle(
                        kSemiBold,
                        kSize30,
                        color: kWhite,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Used to receive ride request',
                      style: kCaption12R.copyWith(
                        color: kWhite.withValues(alpha: 0.65),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Material(
                color: _kEarningsGold,
                borderRadius: BorderRadius.circular(30),
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(30),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add, color: kWhite, size: 16),
                        const SizedBox(width: 2),
                        Text(
                          'Add Balance',
                          style: kStyle(
                            kMedium,
                            kSize12,
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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kCardBorder),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Expanded(
              child: _SegmentTab(
                label: 'Earnings',
                isSelected: selected == _EarningsSection.earnings,
                onTap: () => onChanged(_EarningsSection.earnings),
              ),
            ),
            Expanded(
              child: _SegmentTab(
                label: 'Transactions',
                isSelected: selected == _EarningsSection.transactions,
                onTap: () => onChanged(_EarningsSection.transactions),
              ),
            ),
          ],
        ),
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
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? _kEarningsGold : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
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
  const _EarningsTabContent();

  static const _barHeights = [0.34, 0.34, 0.34, 0.34, 0.34, 0.34, 1.0];
  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
      children: [
        const Row(
          children: [
            Expanded(
              child: _StatSummaryCard(
                value: '₹ 2,035',
                label: 'Total Earnings',
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _StatSummaryCard(value: '20', label: 'Total Trips'),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _StatSummaryCard(value: '4.9', label: 'Rating'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kCardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                              color: kTextColor,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
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
                        const SizedBox(width: 2),
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
              const SizedBox(height: 18),
              SizedBox(
                height: 188,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (index) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: index == 0 ? 0 : 3,
                          right: index == 6 ? 0 : 3,
                        ),
                        child: _WeeklyBar(
                          heightFactor: _barHeights[index],
                          dayLabel: _dayLabels[index],
                          isHighlighted: index == 6,
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
  const _StatSummaryCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kEarningsGold.withValues(alpha: 0.55)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: kStyle(
                kSemiBold,
                kSize17,
                color: _kStatValueBlue,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: kCaption11R.copyWith(color: kTextColor, height: 1.15),
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

  static const _maxBarHeight = 132.0;
  static const _minBarHeight = 44.0;

  @override
  Widget build(BuildContext context) {
    final barHeight =
        _minBarHeight +
        (_maxBarHeight - _minBarHeight) * heightFactor.clamp(0.0, 1.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          height: barHeight,
          width: double.infinity,
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isHighlighted ? _kEarningsGold : _kChartBarInactive,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              amountLabel,
              maxLines: 1,
              style: kStyle(
                kRegular,
                kSize10,
                color: isHighlighted
                    ? kWhite.withValues(alpha: 0.9)
                    : _kChartAmountMuted,
                height: 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          dayLabel,
          style: kCaption13R.copyWith(color: kTextColor, fontWeight: kMedium),
        ),
      ],
    );
  }
}

class _TransactionsPlaceholder extends StatelessWidget {
  const _TransactionsPlaceholder();

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
