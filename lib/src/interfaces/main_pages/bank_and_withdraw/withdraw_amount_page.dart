import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/providers/loading_provider.dart';
import 'package:driveforme_driver/src/data/providers/user_provider.dart';
import 'package:driveforme_driver/src/data/providers/wallet_provider.dart';
import 'package:driveforme_driver/src/data/services/navigation_services.dart';
import 'package:driveforme_driver/src/data/utils/responsive.dart';
import 'package:driveforme_driver/src/interfaces/components/primarybutton.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/bank_and_withdraw/bank_account_card.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/bank_and_withdraw/select_bank_sheet.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/bank_and_withdraw/withdraw_amount_field.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/bank_and_withdraw/withdraw_flow_provider.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/bank_and_withdraw/withdraw_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WithdrawAmountPage extends ConsumerStatefulWidget {
  const WithdrawAmountPage({super.key});

  @override
  ConsumerState<WithdrawAmountPage> createState() => _WithdrawAmountPageState();
}

class _WithdrawAmountPageState extends ConsumerState<WithdrawAmountPage> {
  static const _presetAmounts = [100.0, 500.0, 1000.0, 2000.0];

  final _amountController = TextEditingController();
  double? _selectedPreset;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double? get _amount {
    if (_selectedPreset != null) return _selectedPreset;
    return double.tryParse(_amountController.text.trim());
  }

  Future<void> _openBankSelector() async {
    await SelectBankSheet.show(context);
  }

  Future<void> _withdrawNow() async {
    final amount = _amount;
    final flow = ref.read(withdrawFlowProvider);
    final bank = flow.selectedBank;

    if (amount == null || amount <= 0) {
      _showMessage('Enter a valid withdrawal amount.');
      return;
    }
    if (amount > flow.availableBalance) {
      _showMessage('Amount exceeds available balance.');
      return;
    }
    if (bank == null) {
      _showMessage('Please select a bank account.');
      return;
    }
    if (flow.isSubmitting) return;

    ref.read(loadingProvider.notifier).startLoading();
    final error = await ref
        .read(withdrawFlowProvider.notifier)
        .withdrawFunds(amount);
    ref.read(loadingProvider.notifier).stopLoading();

    if (!mounted) return;
    if (error != null) {
      _showMessage(error);
      return;
    }

    ref.invalidate(walletProvider);
    ref.invalidate(userProvider);

    NavigationService().pushNamed(
      'withdrawalSuccess',
      arguments: {'amount': amount},
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(withdrawFlowProvider);
    final bank = flow.selectedBank;

    return WithdrawScaffold(
      title: 'Withdraw Earnings',
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          context.horizontalPadding,
          context.rs(12),
          context.horizontalPadding,
          context.rs(24),
        ),
        children: [
          Text('Enter Amount', style: kEarningsSectionTitleSB),
          SizedBox(height: context.rs(10)),
          WithdrawAmountField(
            controller: _amountController,
            onChanged: (_) => setState(() => _selectedPreset = null),
          ),
          SizedBox(height: context.rs(12)),
          PresetAmountChips(
            amounts: _presetAmounts,
            selectedAmount: _selectedPreset,
            onSelected: (amount) {
              setState(() {
                _selectedPreset = amount;
                _amountController.text = amount.toStringAsFixed(0);
              });
            },
          ),
          SizedBox(height: context.rs(22)),
          Text('Transfer to', style: kEarningsSectionTitleSB),
          SizedBox(height: context.rs(10)),
          if (bank != null)
            BankAccountCard(
              bankName: bank.bankName,
              maskedAccountNumber: bank.maskedAccountNumber,
              holderName: bank.holderName,
              showChange: true,
              onChange: _openBankSelector,
            )
          else
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(context.rs(16)),
              decoration: BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kCardBorder),
              ),
              child: Text(
                'No bank account selected',
                style: kCaption14R.copyWith(color: kMutedText),
              ),
            ),
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
          label: flow.isSubmitting ? 'Processing...' : 'Withdraw Now',
          buttonColor: kBrandBlue,
          onPressed: flow.isSubmitting ? null : _withdrawNow,
        ),
      ),
    );
  }
}
