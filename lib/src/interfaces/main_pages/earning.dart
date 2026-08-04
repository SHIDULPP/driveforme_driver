import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/models/wallet_model.dart';
import 'package:driveforme_driver/src/data/providers/user_provider.dart';
import 'package:driveforme_driver/src/data/providers/wallet_provider.dart';
import 'package:driveforme_driver/src/data/services/navigation_services.dart';
import 'package:driveforme_driver/src/data/utils/responsive.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/earning_pages/wallet_recharge_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

enum _EarningsSection { wallet, earnings }

class EarningPage extends ConsumerStatefulWidget {
  const EarningPage({super.key});

  @override
  ConsumerState<EarningPage> createState() => _EarningPageState();
}

class _EarningPageState extends ConsumerState<EarningPage> {
  _EarningsSection _section = _EarningsSection.wallet;

  @override
  Widget build(BuildContext context) {
    final walletAsync = ref.watch(walletProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
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
                balanceLabel: _formatBalance(wallet.walletBalance),
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
                data: (wallet) => _section == _EarningsSection.wallet
                    ? _WalletTabContent(wallet: wallet)
                    : _EarningsTabContent(wallet: wallet),
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

String _formatBalance(double amount) => '₹ ${amount.toStringAsFixed(2)}';

final _rupeeStatFormat = NumberFormat('#,##0', 'en_IN');

String formatRupeeStat(double amount) {
  if (amount == amount.truncateToDouble()) {
    return '₹ ${_rupeeStatFormat.format(amount.toInt())}';
  }
  return '₹ ${NumberFormat('#,##0.00', 'en_IN').format(amount)}';
}

double _lastWeekEarnings(WalletDetailsModel wallet) {
  final now = DateTime.now();
  final thisWeekStart = DateTime(
    now.year,
    now.month,
    now.day,
  ).subtract(Duration(days: now.weekday - 1));

  var total = 0.0;
  for (final tx in wallet.transactions) {
    if (!tx.isCredit || tx.category != 'trip_earning') continue;
    final date = tx.createdAt;
    if (date == null || !date.isBefore(thisWeekStart)) continue;
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    if (!date.isBefore(lastWeekStart)) {
      total += tx.amount;
    }
  }
  return total;
}

String? _weekTrendLabel(double thisWeek, double lastWeek) {
  if (thisWeek == 0 && lastWeek == 0) return null;
  if (lastWeek == 0) return '↑ New earnings this week';
  final pct = ((thisWeek - lastWeek) / lastWeek * 100).round();
  if (pct > 0) return '↑ $pct% higher than last week';
  if (pct < 0) return '↓ ${pct.abs()}% lower than last week';
  return 'Same as last week';
}

List<WalletTransactionModel> _withdrawalTransactions(
  WalletDetailsModel wallet,
) {
  return wallet.transactions.where((tx) {
    final category = tx.category.toLowerCase();
    return category.contains('withdraw') || category == 'bank_transfer';
  }).toList();
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
    final bottomRadius = context.rs(28);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kEarningsHeaderBlue,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(bottomRadius),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        context.horizontalPadding,
        topPadding + context.rs(6),
        context.horizontalPadding,
        context.rs(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Your Wallet Balance',
                  style: kEarningsBalanceLabelR.copyWith(
                    color: kWhite.withValues(alpha: 0.72),
                  ),
                ),
                SizedBox(height: context.rs(2)),
                Text(balanceLabel, style: kEarningsBalanceAmountB),
                SizedBox(height: context.rs(12)),
                Material(
                  color: kEarningsGold,
                  borderRadius: BorderRadius.circular(30),
                  child: InkWell(
                    onTap: onAddBalance,
                    borderRadius: BorderRadius.circular(30),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.rs(14),
                        vertical: context.rs(9),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add, color: kWhite, size: 15),
                          const SizedBox(width: 3),
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
          ),
          SizedBox(width: context.rs(4)),
          Image.asset(
            'assets/pngs/earnigs_image.png',
            width: context.rs(130),
            height: context.rs(130),
            fit: BoxFit.contain,
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
      padding: EdgeInsets.fromLTRB(
        context.horizontalPadding,
        context.rs(12),
        context.horizontalPadding,
        0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: kEarningsTabContainerBorder),
          boxShadow: const [
            BoxShadow(
              color: kEarningsTabShadow,
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Expanded(
              child: _SegmentTab(
                label: 'Wallet',
                icon: _SegmentIcon.wallet,
                isSelected: selected == _EarningsSection.wallet,
                onTap: () => onChanged(_EarningsSection.wallet),
              ),
            ),
            Expanded(
              child: _SegmentTab(
                label: 'Earnings',
                icon: _SegmentIcon.earnings,
                isSelected: selected == _EarningsSection.earnings,
                onTap: () => onChanged(_EarningsSection.earnings),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _SegmentIcon { wallet, earnings }

class _SegmentTab extends StatelessWidget {
  const _SegmentTab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final _SegmentIcon icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.symmetric(vertical: context.rs(9)),
        decoration: BoxDecoration(
          color: isSelected ? kEarningsTabSelectedBg : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: kEarningsTabShadow,
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon == _SegmentIcon.wallet)
              SvgPicture.asset(
                'assets/svgs/wallet_icon.svg',
                width: context.rs(17),
                height: context.rs(15),
                colorFilter: ColorFilter.mode(
                  isSelected ? kEarningsHeaderBlue : kSecondaryTextColor,
                  BlendMode.srcIn,
                ),
              )
            else
              Icon(
                Icons.bar_chart_rounded,
                size: context.rs(17),
                color: isSelected ? kEarningsHeaderBlue : kSecondaryTextColor,
              ),
            SizedBox(width: context.rs(5)),
            Text(
              label,
              style: isSelected ? kEarningsTabActiveM : kEarningsTabInactiveM,
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletTabContent extends StatelessWidget {
  const _WalletTabContent({required this.wallet});

  final WalletDetailsModel wallet;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        context.horizontalPadding,
        context.rs(12),
        context.horizontalPadding,
        context.scaffoldBottomPadding,
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: _StatSummaryCard(
                value: formatRupeeStat(wallet.summary.totalCredits),
                label: 'Total Credits',
                iconAsset: 'assets/pngs/totalcredits.png',
                backgroundColor: kEarningsCardPurpleBg,
                valueColor: kEarningsStatValueBlue,
              ),
            ),
            SizedBox(width: context.rs(8)),
            Expanded(
              child: _StatSummaryCard(
                value: formatRupeeStat(wallet.summary.totalDebits),
                label: 'Total Debits',
                iconAsset: 'assets/pngs/totaldebits.png',
                backgroundColor: kEarningsCardBlueBg,
                valueColor: kEarningsStatValueBlue,
              ),
            ),
            SizedBox(width: context.rs(8)),
            Expanded(
              child: _StatSummaryCard(
                value: formatRupeeStat(wallet.walletBalance),
                label: 'Current Balance',
                iconAsset: 'assets/pngs/currentbalance.png',
                backgroundColor: kEarningsCardGreenBg,
                valueColor: kEarningsStatValueBlue,
              ),
            ),
          ],
        ),
        SizedBox(height: context.rs(18)),
        _SectionHeader(
          title: 'Recent Transactions',
          onViewAll: wallet.transactions.isEmpty ? null : () {},
        ),
        SizedBox(height: context.rs(8)),
        _TransactionsCard(transactions: wallet.transactions),
      ],
    );
  }
}

class _EarningsTabContent extends ConsumerWidget {
  const _EarningsTabContent({required this.wallet});

  final WalletDetailsModel wallet;

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final ratingAsync = ref.watch(effectiveDriverRatingProvider);
    final rating = ratingAsync.maybeWhen(
      data: formatDriverRating,
      orElse: () => userAsync.maybeWhen(
        data: (user) => displayRating(user),
        orElse: () => '—',
      ),
    );
    final completedTrips = userAsync.maybeWhen(
      data: (user) => '${user?.totalTrips ?? wallet.completedTripCount}',
      orElse: () => '${wallet.completedTripCount}',
    );

    final weekly = wallet.weeklyEarningsByWeekday();
    final maxWeekly = weekly.values.fold<double>(0, (a, b) => a > b ? a : b);
    final todayIndex = DateTime.now().weekday - 1;
    final thisWeek = wallet.thisWeekEarnings;
    final lastWeek = _lastWeekEarnings(wallet);
    final trendLabel = _weekTrendLabel(thisWeek, lastWeek);
    final withdrawals = _withdrawalTransactions(wallet);

    return ListView(
      padding: EdgeInsets.fromLTRB(
        context.horizontalPadding,
        context.rs(12),
        context.horizontalPadding,
        context.scaffoldBottomPadding,
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: _StatSummaryCard(
                value: formatRupeeStat(wallet.totalTripEarnings),
                label: 'Total Earned',
                iconAsset: 'assets/pngs/totalearnerd.png',
                backgroundColor: kEarningsCardPurpleBg,
                valueColor: kEarningsCardPurpleValue,
              ),
            ),
            SizedBox(width: context.rs(8)),
            Expanded(
              child: _StatSummaryCard(
                value: rating,
                label: 'Rating',
                iconAsset: 'assets/pngs/rating.png',
                backgroundColor: kEarningsCardYellowBg,
                valueColor: kEarningsCardOrangeValue,
              ),
            ),
            SizedBox(width: context.rs(8)),
            Expanded(
              child: _StatSummaryCard(
                value: completedTrips,
                label: 'Completed Trips',
                iconAsset: 'assets/pngs/totaltrips.png',
                backgroundColor: kEarningsCardGreenBg,
                valueColor: kEarningsCardGreenValue,
              ),
            ),
          ],
        ),
        SizedBox(height: context.rs(12)),
        _WeeklyEarningsChart(
          thisWeekTotal: thisWeek,
          trendLabel: trendLabel,
          weekly: weekly,
          maxWeekly: maxWeekly,
          todayIndex: todayIndex,
          dayLabels: _dayLabels,
        ),
        SizedBox(height: context.rs(12)),
        _AvailableEarningsCard(amount: wallet.totalTripEarnings),
        SizedBox(height: context.rs(18)),
        _SectionHeader(
          title: 'Recent Withdrawals',
          onViewAll: withdrawals.isEmpty ? null : () {},
        ),
        SizedBox(height: context.rs(8)),
        _WithdrawalsCard(withdrawals: withdrawals),
      ],
    );
  }
}

class _StatSummaryCard extends StatelessWidget {
  const _StatSummaryCard({
    required this.value,
    required this.label,
    required this.iconAsset,
    required this.backgroundColor,
    required this.valueColor,
  });

  final String value;
  final String label;
  final String iconAsset;
  final Color backgroundColor;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.rs(8),
        vertical: context.rs(14),
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kEarningsStatCardBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            iconAsset,
            width: context.rs(40),
            height: context.rs(40),
            fit: BoxFit.contain,
          ),
          SizedBox(height: context.rs(8)),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: kEarningsStatValueSB.copyWith(color: valueColor),
            ),
          ),
          SizedBox(height: context.rs(4)),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: kCaption11R.copyWith(
              color: kSecondaryTextColor,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyEarningsChart extends StatelessWidget {
  const _WeeklyEarningsChart({
    required this.thisWeekTotal,
    required this.trendLabel,
    required this.weekly,
    required this.maxWeekly,
    required this.todayIndex,
    required this.dayLabels,
  });

  final double thisWeekTotal;
  final String? trendLabel;
  final Map<int, double> weekly;
  final double maxWeekly;
  final int todayIndex;
  final List<String> dayLabels;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        context.rs(16),
        context.rs(16),
        context.rs(16),
        context.rs(12),
      ),
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
                child: Text(
                  'This Week Earnings',
                  style: kEarningsSectionTitleSB,
                ),
              ),
              const _WeekFilterChip(),
            ],
          ),
          SizedBox(height: context.rs(10)),
          Text(formatRupeeStat(thisWeekTotal), style: kEarningsChartTotalSB),
          if (trendLabel != null) ...[
            SizedBox(height: context.rs(4)),
            Text(trendLabel!, style: kEarningsTrendR),
          ],
          SizedBox(height: context.rs(16)),
          SizedBox(
            height: context.rs(188),
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
                      dayLabel: dayLabels[index],
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
    );
  }
}

class _WeekFilterChip extends StatelessWidget {
  const _WeekFilterChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.rs(12),
        vertical: context.rs(6),
      ),
      decoration: BoxDecoration(
        color: kFigmaNeutral,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('This week', style: kCaption12R.copyWith(color: kTextColor)),
          SizedBox(width: context.rs(4)),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: context.rs(16),
            color: kTextColor,
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
    final maxBarHeight = context.rs(132);
    final minBarHeight = context.rs(44);
    final barHeight =
        minBarHeight + (maxBarHeight - minBarHeight) * heightFactor.clamp(0, 1);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          height: barHeight,
          width: double.infinity,
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.only(bottom: context.rs(8)),
          decoration: BoxDecoration(
            color: isHighlighted
                ? kEarningsChartBarActive
                : kEarningsChartBarInactive,
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
                color: isHighlighted ? kWhite : kEarningsChartAmountMuted,
                height: 1,
              ),
            ),
          ),
        ),
        SizedBox(height: context.rs(8)),
        Text(
          dayLabel,
          style: kCaption13R.copyWith(color: kTextColor, fontWeight: kMedium),
        ),
      ],
    );
  }
}

class _AvailableEarningsCard extends StatelessWidget {
  const _AvailableEarningsCard({required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.rs(12)),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Available Earnings', style: kEarningsSectionTitleSB),
          SizedBox(height: context.rs(10)),
          Container(
            padding: EdgeInsets.fromLTRB(
              context.rs(10),
              context.rs(9),
              context.rs(6),
              context.rs(9),
            ),
            decoration: BoxDecoration(
              color: kFigmaNeutral,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formatRupeeStat(amount),
                        style: kStyle(
                          kSemiBold,
                          kSize20,
                          color: kEarningsStatValueBlue,
                          height: 1.1,
                        ),
                      ),
                      SizedBox(height: context.rs(4)),
                      Text(
                        'Withdraw anytime to your bank',
                        style: kCaption11R.copyWith(color: kMutedText),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: context.rs(8)),
                Material(
                  color: kEarningsGold,
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    onTap: () =>
                        NavigationService().pushNamed('withdrawEarnings'),
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.rs(12),
                        vertical: context.rs(10),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.account_balance_rounded,
                              color: kWhite,
                              size: 16,
                            ),
                            SizedBox(width: context.rs(4)),
                            Text(
                              'Withdraw Earnings',
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onViewAll});

  final String title;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: kEarningsSectionTitleSB)),
        if (onViewAll != null)
          GestureDetector(
            onTap: onViewAll,
            behavior: HitTestBehavior.opaque,
            child: Text('View All', style: kEarningsViewAllM),
          ),
      ],
    );
  }
}

class _TransactionsCard extends StatelessWidget {
  const _TransactionsCard({required this.transactions});

  final List<WalletTransactionModel> transactions;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return _EmptyListCard(message: 'No transactions yet');
    }

    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kCardBorder),
      ),
      child: Column(
        children: List.generate(transactions.length, (index) {
          final tx = transactions[index];
          return Column(
            children: [
              _TransactionTile(transaction: tx),
              if (index < transactions.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: kCardBorder,
                  indent: context.rs(70),
                  endIndent: context.rs(14),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _WithdrawalsCard extends StatelessWidget {
  const _WithdrawalsCard({required this.withdrawals});

  final List<WalletTransactionModel> withdrawals;

  @override
  Widget build(BuildContext context) {
    if (withdrawals.isEmpty) {
      return _EmptyListCard(message: 'No withdrawals yet');
    }

    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kCardBorder),
      ),
      child: Column(
        children: List.generate(withdrawals.length, (index) {
          final tx = withdrawals[index];
          return Column(
            children: [
              _WithdrawalTile(transaction: tx),
              if (index < withdrawals.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: kCardBorder,
                  indent: context.rs(70),
                  endIndent: context.rs(14),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _EmptyListCard extends StatelessWidget {
  const _EmptyListCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: context.rs(28)),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kCardBorder),
      ),
      alignment: Alignment.center,
      child: Text(message, style: kCaption14R.copyWith(color: kMutedText)),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction});

  final WalletTransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;
    final color = isCredit ? kActiveGreen : kSosRed;
    final iconBg = isCredit
        ? kEarningsTransactionIconBg
        : kEarningsPlatformFeeIconBg;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.rs(14),
        vertical: context.rs(11),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: context.rs(44),
            width: context.rs(44),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(
              isCredit
                  ? Icons.account_balance_wallet_outlined
                  : Icons.shield_outlined,
              color: color,
              size: context.rs(21),
            ),
          ),
          SizedBox(width: context.rs(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: kCaption14B.copyWith(height: 1.2),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: context.rs(3)),
                Text(
                  transaction.displayDate,
                  style: kCaption12R.copyWith(
                    color: kSecondaryTextColor,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: context.rs(10)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                transaction.displayAmount,
                style: kStyle(kSemiBold, kSize14, color: color, height: 1.2),
              ),
              SizedBox(height: context.rs(3)),
              Text(
                transaction.displayDate,
                style: kCaption12R.copyWith(
                  color: kSecondaryTextColor,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WithdrawalTile extends StatelessWidget {
  const _WithdrawalTile({required this.transaction});

  final WalletTransactionModel transaction;

  String get _statusLabel {
    final status = transaction.status.toLowerCase();
    if (status == 'failed') return 'Failed';
    return 'Completed';
  }

  Color get _statusColor {
    final status = transaction.status.toLowerCase();
    if (status == 'failed') return kSosRed;
    return kActiveGreen;
  }

  String get _displayDate {
    final date = transaction.createdAt;
    if (date == null) return '';
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final amount = transaction.amount;
    final amountLabel = amount == amount.truncateToDouble()
        ? '₹ ${amount.toInt()}'
        : '₹ ${amount.toStringAsFixed(2)}';

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.rs(14),
        vertical: context.rs(9),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: context.rs(35),
            width: context.rs(35),
            decoration: const BoxDecoration(
              color: kEarningsWithdrawIconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_rounded,
              color: kActiveGreen,
              size: context.rs(16),
            ),
          ),
          SizedBox(width: context.rs(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(amountLabel, style: kCaption14B.copyWith(height: 1.2)),
                SizedBox(height: context.rs(3)),
                Text(
                  transaction.description.isNotEmpty
                      ? transaction.description
                      : transaction.categoryLabel,
                  style: kCaption12R.copyWith(
                    color: kSecondaryTextColor,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: context.rs(10)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _statusLabel,
                style: kStyle(
                  kSemiBold,
                  kSize13,
                  color: _statusColor,
                  height: 1.2,
                ),
              ),
              SizedBox(height: context.rs(3)),
              Text(
                _displayDate,
                style: kCaption12R.copyWith(
                  color: kSecondaryTextColor,
                  height: 1.2,
                ),
              ),
            ],
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
