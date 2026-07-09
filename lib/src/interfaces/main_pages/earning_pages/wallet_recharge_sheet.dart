import 'package:driveforme_driver/src/data/apis/wallet_api.dart';
import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/models/wallet_model.dart';
import 'package:driveforme_driver/src/data/providers/loading_provider.dart';
import 'package:driveforme_driver/src/data/providers/user_provider.dart';
import 'package:driveforme_driver/src/data/providers/wallet_provider.dart';
import 'package:driveforme_driver/src/data/services/razorpay_checkout_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

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
  final _razorpayCheckout = RazorpayCheckoutService();
  double? _selectedAmount;
  bool _isProcessing = false;

  @override
  void dispose() {
    _amountController.dispose();
    _razorpayCheckout.dispose();
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
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    ref.read(loadingProvider.notifier).startLoading();

    if (_razorpayCheckout.isConfigured) {
      await _payWithRazorpay(amount);
    } else {
      await _payWithDemoRecharge(amount);
    }

    if (mounted) {
      setState(() => _isProcessing = false);
    }
    ref.read(loadingProvider.notifier).stopLoading();
  }

  Future<void> _payWithDemoRecharge(double amount) async {
    final response = await ref
        .read(walletApiProvider)
        .rechargeWallet(amount: amount, description: 'Wallet recharge');

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

  Future<void> _payWithRazorpay(double amount) async {
    final orderResponse = await ref
        .read(walletApiProvider)
        .createRazorpayOrder(amount: amount);

    if (!mounted) return;

    if (!orderResponse.success || orderResponse.data == null) {
      _showMessage(orderResponse.message ?? 'Failed to start payment.');
      return;
    }

    final order = orderResponse.data!;
    final user = await ref.read(userProvider.future);
    final contact = user?.phoneNumber ?? '';
    final name = user?.profile.fullName.trim().isNotEmpty == true
        ? user!.profile.fullName.trim()
        : 'Driver';
    final email = user?.profile.email.trim();

    try {
      _razorpayCheckout.open(
        orderId: order.orderId,
        amount: order.amount,
        name: name,
        contact: contact,
        email: email,
        onSuccess: (response) => _handleRazorpaySuccess(
          response: response,
          transactionId: order.transactionId,
          amount: amount,
        ),
        onFailure: _handleRazorpayFailure,
      );
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  Future<void> _handleRazorpaySuccess({
    required PaymentSuccessResponse response,
    required String transactionId,
    required double amount,
  }) async {
    ref.read(loadingProvider.notifier).startLoading();

    final verifyResponse = await ref
        .read(walletApiProvider)
        .verifyRazorpayPayment(
          razorpayOrderId: response.orderId ?? '',
          razorpayPaymentId: response.paymentId ?? '',
          razorpaySignature: response.signature ?? '',
          transactionId: transactionId,
        );

    ref.read(loadingProvider.notifier).stopLoading();
    if (!mounted) return;

    if (!verifyResponse.success) {
      _showMessage(verifyResponse.message ?? 'Payment verification failed.');
      return;
    }

    ref.invalidate(walletProvider);
    ref.invalidate(userProvider);
    Navigator.of(context).pop();
    _showMessage('₹ ${amount.toStringAsFixed(0)} added to your wallet.');
  }

  void _handleRazorpayFailure(PaymentFailureResponse response) {
    if (!mounted) return;
    final message = response.message?.trim();
    _showMessage(
      message == null || message.isEmpty
          ? 'Payment cancelled or failed.'
          : message,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final usesRazorpay = _razorpayCheckout.isConfigured;

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
            Text(
              'Add Balance',
              style: kStyle(kSemiBold, kSize20, color: kTextColor),
            ),
            const SizedBox(height: 6),
            Text(
              usesRazorpay
                  ? 'Pay securely with Razorpay to add balance to your wallet.'
                  : 'Razorpay is not configured. This recharge credits your wallet instantly.',
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
              onPressed: _isProcessing ? null : _submitRecharge,
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
                _isProcessing
                    ? 'Processing...'
                    : usesRazorpay
                    ? 'Pay with Razorpay'
                    : 'Recharge Wallet',
                style: kStyle(kSemiBold, kSize15, color: kWhite),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
