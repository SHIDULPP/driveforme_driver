import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/models/wallet_model.dart';
import 'package:driveforme_driver/src/data/providers/wallet_provider.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/earning_pages/wallet_recharge_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _kEarningsHeaderBlue = Color(0xFF1A5288);
const _kEarningsGold = Color(0xFFC6934B);
const _kStatValueBlue = Color(0xFF205D91);
const _kChartBarInactive = Color(0xFFF3F0E8);
const _kChartAmountMuted = Color(0xFFB8B0A4);
const _kCreditGreen = Color(0xFF17A34A);
const _kDebitRed = Color(0xFFE32626);

enum _EarningsSection { earnings, transactions }

class EarningPage extends ConsumerStatefulWidget {
  const EarningPage({super.key});

  @override
  ConsumerState<EarningPage> createState() => _EarningPageState();
}

class _EarningPageState extends ConsumerState<EarningPage> {
  _EarningsSection _section = _EarningsSection.earnings;

  @override
  Widget build(BuildContext context) {
    final walletAsync = ref.watch(walletProvider);

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
            walletAsync.when(
              data: (wallet) => _EarningsHeader(
                balanceLabel: formatRupee(wallet.walletBalance),
                onAddBalance: () => WalletRechargeSheet.show(context),
              ),
              loading: () => const _EarningsHeader(
                balanceLabel: '₹ —',
                onAddBalance: null,
              ),
              error: (_, _) => _EarningsHeader(
                balanceLabel: '₹ —',
                onAddBalance: () => ref.invalidate(walletProvider),
              ),
            ),
            _EarningsSegmentedTabs(
              selected: _section,
              onChanged: (value) => setState(() => _section = value),
            ),
            Expanded(
              child: walletAsync.when(
                data: (wallet) => _section == _EarningsSection.earnings
                    ? _EarningsTabContent(wallet: wallet)
                    : _TransactionsList(transactions: wallet.transactions),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => _WalletErrorState(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(walletProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EarningsHeader extends StatelessWidget {
  const _EarningsHeader({
    required this.balanceLabel,
    required this.onAddBalance,
  });

  final String balanceLabel;
  final VoidCallback? onAddBalance;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Container(
      color: _kEarningsHeaderBlue,
      padding: EdgeInsets.fromLTRB(20, topPadding + 12, 20, 20),
      child: Column(
        children: [
          const SizedBox(height: 70),
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
                      balanceLabel,
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
                  onTap: onAddBalance,
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
  const _EarningsTabContent({required this.wallet});

  final WalletDetailsModel wallet;

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final weekly = wallet.weeklyEarningsByWeekday();
    final maxWeekly = weekly.values.fold<double>(0, (a, b) => a > b ? a : b);
    final todayIndex = DateTime.now().weekday - 1;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
      children: [
        Row(
          children: [
            Expanded(
              child: _StatSummaryCard(
                value: formatRupeeCompact(wallet.totalTripEarnings),
                label: 'Total Earnings',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatSummaryCard(
                value: '${wallet.completedTripCount}',
                label: 'Total Trips',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatSummaryCard(
                value: formatRupeeCompact(wallet.summary.totalCredits),
                label: 'Total Credits',
              ),
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
                            text:
                                '${formatRupee(wallet.thisWeekEarnings)} total',
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
                    child: Text(
                      'This week',
                      style: kCaption13R.copyWith(color: kTextColor),
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
                    final amount = weekly[index] ?? 0;
                    final heightFactor = maxWeekly > 0
                        ? (amount / maxWeekly).clamp(0.08, 1.0)
                        : 0.08;

                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: index == 0 ? 0 : 3,
                          right: index == 6 ? 0 : 3,
                        ),
                        child: _WeeklyBar(
                          heightFactor: heightFactor,
                          dayLabel: _dayLabels[index],
                          isHighlighted: index == todayIndex,
                          amountLabel: amount > 0
                              ? formatRupeeCompact(amount)
                              : '₹ 0',
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

class _TransactionsList extends StatelessWidget {
  const _TransactionsList({required this.transactions});

  final List<WalletTransactionModel> transactions;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Center(
        child: Text(
          'No transactions yet',
          style: kCaption14R.copyWith(color: kMutedText),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
      itemCount: transactions.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return _TransactionTile(transaction: transactions[index]);
      },
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction});

  final WalletTransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final color = transaction.isCredit ? _kCreditGreen : _kDebitRed;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kCardBorder),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              transaction.isCredit
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: kCaption14B,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${transaction.categoryLabel} • ${transaction.displayDate}',
                  style: kCaption12R.copyWith(color: kMutedText),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            transaction.displayAmount,
            style: kStyle(kSemiBold, kSize14, color: color),
          ),
        ],
      ),
    );
  }
}

class _WalletErrorState extends StatelessWidget {
  const _WalletErrorState({required this.message, required this.onRetry});

  final String message;
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
              'Could not load wallet',
              style: kCaption14B,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: kCaption12R.copyWith(color: kMutedText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
