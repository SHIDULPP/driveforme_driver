import 'package:driveforme_driver/src/data/apis/wallet_api.dart';
import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/models/wallet_model.dart';
import 'package:driveforme_driver/src/data/providers/loading_provider.dart';
import 'package:driveforme_driver/src/data/providers/user_provider.dart';
import 'package:driveforme_driver/src/data/providers/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _kRechargeGold = Color(0xFFC6934B);

class WalletRechargeSheet extends ConsumerStatefulWidget {
  const WalletRechargeSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const WalletRechargeSheet(),
    );
  }

  @override
  ConsumerState<WalletRechargeSheet> createState() =>
      _WalletRechargeSheetState();
}

class _WalletRechargeSheetState extends ConsumerState<WalletRechargeSheet> {
  static const _presetAmounts = [100.0, 500.0, 1000.0, 2000.0];

  final _amountController = TextEditingController();
  double? _selectedAmount;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double? get _rechargeAmount {
    if (_selectedAmount != null) return _selectedAmount;
    return double.tryParse(_amountController.text.trim());
  }

  Future<void> _submitRecharge() async {
    final amount = _rechargeAmount;
    if (amount == null || amount <= 0) {
      _showMessage('Enter a valid recharge amount.');
      return;
    }

    ref.read(loadingProvider.notifier).startLoading();
    final response = await ref.read(walletApiProvider).rechargeWallet(
          amount: amount,
          description: 'Dummy UPI recharge',
        );
    ref.read(loadingProvider.notifier).stopLoading();

    if (!mounted) return;

    if (!response.success) {
      _showMessage(response.message ?? 'Recharge failed.');
      return;
    }

    ref.invalidate(walletProvider);
    ref.invalidate(userProvider);
    Navigator.of(context).pop();
    _showMessage('₹ ${amount.toStringAsFixed(0)} added to your wallet.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: kCardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Add Balance', style: kStyle(kSemiBold, kSize20, color: kTextColor)),
            const SizedBox(height: 6),
            Text(
              'Payment gateway coming soon. This demo recharge credits your wallet instantly.',
              style: kCaption13R.copyWith(color: kMutedText, height: 1.35),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presetAmounts.map((amount) {
                final isSelected = _selectedAmount == amount;
                return ChoiceChip(
                  label: Text(formatRupee(amount)),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _selectedAmount = amount;
                      _amountController.text = amount.toStringAsFixed(0);
                    });
                  },
                  selectedColor: _kRechargeGold.withValues(alpha: 0.2),
                  labelStyle: kCaption14R.copyWith(
                    color: isSelected ? kBrandBlue : kTextColor,
                    fontWeight: isSelected ? kSemiBold : kRegular,
                  ),
                  side: BorderSide(
                    color: isSelected ? _kRechargeGold : kCardBorder,
                  ),
                  backgroundColor: kWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Custom amount',
                prefixText: '₹ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (_) => setState(() => _selectedAmount = null),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _submitRecharge,
              style: ElevatedButton.styleFrom(
                backgroundColor: kBrandBlue,
                foregroundColor: kWhite,
                minimumSize: const Size.fromHeight(48),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Text(
                'Pay via UPI (Demo)',
                style: kStyle(kSemiBold, kSize15, color: kWhite),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
