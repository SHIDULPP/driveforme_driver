import 'package:driveforme_driver/src/data/apis/wallet_api.dart';
import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/models/wallet_model.dart';
import 'package:driveforme_driver/src/data/providers/loading_provider.dart';
import 'package:driveforme_driver/src/data/providers/user_provider.dart';
import 'package:driveforme_driver/src/data/providers/wallet_provider.dart';
import 'package:driveforme_driver/src/data/services/razorpay_checkout_service.dart';
import 'package:driveforme_driver/src/data/utils/responsive.dart';
import 'package:driveforme_driver/src/interfaces/components/primarybutton.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/bank_and_withdraw/withdraw_amount_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

enum _RechargeStep { amount, processing, success, failed }

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

  _RechargeStep _step = _RechargeStep.amount;
  String _processingLabel = 'Processing Payment';
  double _confirmedAmount = 0;
  String _failureMessage = 'Something went wrong with your payment.';

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

  bool get _usesRazorpay => _razorpayCheckout.isConfigured;

  Future<void> _submitRecharge() async {
    final amount = _rechargeAmount;
    if (amount == null || amount <= 0) {
      _showMessage('Enter a valid recharge amount.');
      return;
    }

    setState(() {
      _confirmedAmount = amount;
      _processingLabel = 'Processing Payment';
      _step = _RechargeStep.processing;
    });
    ref.read(loadingProvider.notifier).startLoading();

    if (_usesRazorpay) {
      await _payWithRazorpay(amount);
    } else {
      await _payWithDemoRecharge(amount);
    }

    ref.read(loadingProvider.notifier).stopLoading();
  }

  Future<void> _payWithDemoRecharge(double amount) async {
    final response = await ref
        .read(walletApiProvider)
        .rechargeWallet(amount: amount, description: 'Wallet recharge');

    if (!mounted) return;

    if (!response.success) {
      _goToFailed(response.message ?? 'Recharge failed.');
      return;
    }

    ref.invalidate(walletProvider);
    ref.invalidate(userProvider);
    setState(() => _step = _RechargeStep.success);
  }

  Future<void> _payWithRazorpay(double amount) async {
    final orderResponse = await ref
        .read(walletApiProvider)
        .createRazorpayOrder(amount: amount);

    if (!mounted) return;

    if (!orderResponse.success || orderResponse.data == null) {
      _goToFailed(orderResponse.message ?? 'Failed to start payment.');
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
      _goToFailed(error.toString());
    }
  }

  Future<void> _handleRazorpaySuccess({
    required PaymentSuccessResponse response,
    required String transactionId,
    required double amount,
  }) async {
    if (!mounted) return;
    setState(() => _processingLabel = 'Verifying Payment');
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
      _goToFailed(verifyResponse.message ?? 'Payment verification failed.');
      return;
    }

    ref.invalidate(walletProvider);
    ref.invalidate(userProvider);
    setState(() => _step = _RechargeStep.success);
  }

  void _handleRazorpayFailure(PaymentFailureResponse response) {
    if (!mounted) return;
    final message = response.message?.trim();
    _goToFailed(
      message == null || message.isEmpty
          ? 'Payment cancelled or failed.'
          : message,
    );
  }

  void _goToFailed(String message) {
    if (!mounted) return;
    setState(() {
      _failureMessage = message;
      _step = _RechargeStep.failed;
    });
  }

  void _retry() {
    setState(() => _step = _RechargeStep.amount);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        decoration: const BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(20, context.rs(12), 20, context.rs(24)),
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
            SizedBox(height: context.rs(16)),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: switch (_step) {
                _RechargeStep.amount => _AmountStep(
                  key: const ValueKey('amount'),
                  usesRazorpay: _usesRazorpay,
                  amountController: _amountController,
                  selectedAmount: _selectedAmount,
                  presetAmounts: _presetAmounts,
                  onPresetSelected: (amount) {
                    setState(() {
                      _selectedAmount = amount;
                      _amountController.text = amount.toStringAsFixed(0);
                    });
                  },
                  onAmountChanged: (_) =>
                      setState(() => _selectedAmount = null),
                  onSubmit: _submitRecharge,
                ),
                _RechargeStep.processing => _ProcessingStep(
                  key: const ValueKey('processing'),
                  label: _processingLabel,
                ),
                _RechargeStep.success => _ResultStep(
                  key: const ValueKey('success'),
                  isSuccess: true,
                  title: '${formatRupee(_confirmedAmount)} Added!',
                  message: 'Your wallet balance has been updated.',
                  primaryLabel: 'Done',
                  onPrimary: () => Navigator.of(context).pop(),
                ),
                _RechargeStep.failed => _ResultStep(
                  key: const ValueKey('failed'),
                  isSuccess: false,
                  title: 'Payment Failed',
                  message: _failureMessage,
                  primaryLabel: 'Try Again',
                  onPrimary: _retry,
                  onCancel: () => Navigator.of(context).pop(),
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountStep extends StatelessWidget {
  const _AmountStep({
    super.key,
    required this.usesRazorpay,
    required this.amountController,
    required this.selectedAmount,
    required this.presetAmounts,
    required this.onPresetSelected,
    required this.onAmountChanged,
    required this.onSubmit,
  });

  final bool usesRazorpay;
  final TextEditingController amountController;
  final double? selectedAmount;
  final List<double> presetAmounts;
  final ValueChanged<double> onPresetSelected;
  final ValueChanged<String> onAmountChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Add Balance',
          style: kStyle(kSemiBold, kSize20, color: kTextColor),
        ),
        SizedBox(height: context.rs(6)),
        Text(
          usesRazorpay
              ? 'Add money securely via UPI, cards, netbanking & more.'
              : 'Razorpay is not configured. This recharge credits your wallet instantly.',
          style: kCaption13R.copyWith(color: kMutedText, height: 1.35),
        ),
        SizedBox(height: context.rs(20)),
        Text('Enter Amount', style: kEarningsSectionTitleSB),
        SizedBox(height: context.rs(10)),
        WithdrawAmountField(
          controller: amountController,
          onChanged: onAmountChanged,
        ),
        SizedBox(height: context.rs(12)),
        PresetAmountChips(
          amounts: presetAmounts,
          selectedAmount: selectedAmount,
          onSelected: onPresetSelected,
        ),
        SizedBox(height: context.rs(18)),
        if (usesRazorpay) ...[
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.rs(12),
              vertical: context.rs(10),
            ),
            decoration: BoxDecoration(
              color: kFigmaNeutral,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  height: context.rs(28),
                  width: context.rs(28),
                  decoration: const BoxDecoration(
                    color: kWithdrawSecureBadgeBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified_rounded,
                    size: context.rs(14),
                    color: kActiveGreen,
                  ),
                ),
                SizedBox(width: context.rs(10)),
                Expanded(
                  child: Text(
                    'Secured by Razorpay — UPI, cards, netbanking & more',
                    style: kCaption12R.copyWith(
                      color: kSecondaryTextColor,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.rs(18)),
        ],
        primaryButton(
          label: usesRazorpay ? 'Add Money' : 'Recharge Wallet',
          buttonColor: kBrandBlue,
          icon: const Icon(
            Icons.account_balance_wallet_outlined,
            color: kWhite,
            size: 18,
          ),
          onPressed: onSubmit,
        ),
      ],
    );
  }
}

class _ProcessingStep extends StatelessWidget {
  const _ProcessingStep({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.rs(28)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: context.rs(72),
            width: context.rs(72),
            child: CircularProgressIndicator(
              strokeWidth: context.rs(6),
              backgroundColor: kEarningsChartBarInactive,
              color: kBrandBlue,
            ),
          ),
          SizedBox(height: context.rs(20)),
          Text(
            label,
            style: kStyle(kSemiBold, kSize18, color: kTextColor, height: 1.2),
          ),
          SizedBox(height: context.rs(6)),
          Text(
            'Please wait, do not close this screen',
            style: kCaption13R.copyWith(color: kMutedText),
          ),
        ],
      ),
    );
  }
}

class _ResultStep extends StatelessWidget {
  const _ResultStep({
    super.key,
    required this.isSuccess,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    this.onCancel,
  });

  final bool isSuccess;
  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: context.rs(8)),
        Center(
          child: Container(
            height: context.rs(88),
            width: context.rs(88),
            decoration: BoxDecoration(
              color: isSuccess ? kActiveGreen : kSosRed,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSuccess ? Icons.check_rounded : Icons.close_rounded,
              color: kWhite,
              size: context.rs(48),
            ),
          ),
        ),
        SizedBox(height: context.rs(18)),
        Text(
          title,
          textAlign: TextAlign.center,
          style: kStyle(kSemiBold, kSize20, color: kTextColor, height: 1.25),
        ),
        SizedBox(height: context.rs(8)),
        Text(
          message,
          textAlign: TextAlign.center,
          style: kCaption14R.copyWith(color: kSecondaryTextColor, height: 1.4),
        ),
        SizedBox(height: context.rs(22)),
        primaryButton(
          label: primaryLabel,
          buttonColor: isSuccess ? kActiveGreen : kBrandBlue,
          onPressed: onPrimary,
        ),
        if (onCancel != null) ...[
          SizedBox(height: context.rs(4)),
          TextButton(
            onPressed: onCancel,
            child: Text(
              'Cancel',
              style: kStyle(kMedium, kSize15, color: kMutedText),
            ),
          ),
        ],
      ],
    );
  }
}
