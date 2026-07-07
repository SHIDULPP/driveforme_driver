import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/services/navigation_services.dart';
import 'package:driveforme_driver/src/data/utils/responsive.dart';
import 'package:driveforme_driver/src/interfaces/components/primarybutton.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/bank_and_withdraw/available_earnings_card.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/bank_and_withdraw/withdraw_scaffold.dart';
import 'package:driveforme_driver/src/data/models/withdrawal_ui_model.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/bank_and_withdraw/withdrawal_list_tile.dart';
import 'package:driveforme_driver/src/data/providers/wallet_provider.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/bank_and_withdraw/withdraw_flow_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WithdrawEarningsPage extends ConsumerStatefulWidget {
  const WithdrawEarningsPage({super.key});

  @override
  ConsumerState<WithdrawEarningsPage> createState() =>
      _WithdrawEarningsPageState();
}

class _WithdrawEarningsPageState extends ConsumerState<WithdrawEarningsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncAvailableEarnings());
  }

  void _syncAvailableEarnings() {
    final wallet = ref.read(walletProvider);
    wallet.whenData((details) {
      ref
          .read(withdrawFlowProvider.notifier)
          .setAvailableEarnings(details.totalTripEarnings);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(walletProvider, (_, next) {
      next.whenData((details) {
        ref
            .read(withdrawFlowProvider.notifier)
            .setAvailableEarnings(details.totalTripEarnings);
      });
    });

    final flow = ref.watch(withdrawFlowProvider);
    final hasBank = flow.hasBankAccount;

    return WithdrawScaffold(
      title: 'Withdraw Earnings',
      showHelp: true,
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          context.horizontalPadding,
          context.rs(12),
          context.horizontalPadding,
          context.rs(24),
        ),
        children: [
          AvailableEarningsCard(amount: flow.availableEarnings),
          SizedBox(height: context.rs(14)),
          if (hasBank) ...[
            _WithdrawalsSection(withdrawals: flow.withdrawals),
          ] else ...[
            const NoBankEmptyState(),
          ],
        ],
      ),
      bottom: SafeArea(
        minimum: EdgeInsets.fromLTRB(
          context.horizontalPadding,
          0,
          context.horizontalPadding,
          context.rs(16),
        ),
        child: primaryButton(
          label: hasBank ? 'Withdraw Earnings' : 'Add bank Account',
          buttonColor: kBrandBlue,
          icon: hasBank
              ? null
              : const Icon(
                  Icons.account_balance_outlined,
                  color: kWhite,
                  size: 18,
                ),
          onPressed: () {
            if (hasBank) {
              NavigationService().pushNamed('withdrawAmount');
            } else {
              NavigationService().pushNamed('addBankAccount');
            }
          },
        ),
      ),
    );
  }
}

class _WithdrawalsSection extends StatelessWidget {
  const _WithdrawalsSection({required this.withdrawals});

  final List<WithdrawalUiModel> withdrawals;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kCardBorder),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.rs(14),
              context.rs(14),
              context.rs(14),
              context.rs(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Withdrawals',
                    style: kEarningsSectionTitleSB,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.rs(10),
                    vertical: context.rs(6),
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
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: context.rs(16),
                        color: kTextColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (withdrawals.isEmpty)
            const WithdrawalsEmptyState()
          else
            ...List.generate(withdrawals.length, (index) {
              final item = withdrawals[index];
              return Column(
                children: [
                  WithdrawalListTile(withdrawal: item),
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
        ],
      ),
    );
  }
}
