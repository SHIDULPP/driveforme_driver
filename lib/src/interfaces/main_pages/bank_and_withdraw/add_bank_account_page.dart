import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/services/navigation_services.dart';
import 'package:driveforme_driver/src/data/utils/responsive.dart';
import 'package:driveforme_driver/src/interfaces/components/primarybutton.dart';
import 'package:driveforme_driver/src/data/models/bank_account_ui_model.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/bank_and_withdraw/withdraw_scaffold.dart';
import 'package:flutter/material.dart';

class AddBankAccountPage extends StatefulWidget {
  const AddBankAccountPage({super.key});

  @override
  State<AddBankAccountPage> createState() => _AddBankAccountPageState();
}

class _AddBankAccountPageState extends State<AddBankAccountPage> {
  final _holderController = TextEditingController();
  final _bankController = TextEditingController();
  final _branchController = TextEditingController();
  final _accountController = TextEditingController();
  final _confirmAccountController = TextEditingController();
  final _ifscController = TextEditingController();

  bool _obscureAccount = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _holderController.dispose();
    _bankController.dispose();
    _branchController.dispose();
    _accountController.dispose();
    _confirmAccountController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  void _verifyAccount() {
    if (_holderController.text.trim().isEmpty ||
        _bankController.text.trim().isEmpty ||
        _accountController.text.trim().isEmpty ||
        _confirmAccountController.text.trim().isEmpty ||
        _ifscController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    if (_accountController.text.trim() != _confirmAccountController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account numbers do not match.')),
      );
      return;
    }

    final account = BankAccountUiModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bankName: _bankController.text.trim(),
      accountNumber: _accountController.text.trim(),
      holderName: _holderController.text.trim(),
      ifscCode: _ifscController.text.trim().toUpperCase(),
      branchName: _branchController.text.trim(),
    );

    NavigationService().pushNamed(
      'verifyBankAccount',
      arguments: {'account': account},
    );
  }

  @override
  Widget build(BuildContext context) {
    return WithdrawScaffold(
      title: 'Add Bank Account',
      showHelp: true,
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          context.horizontalPadding,
          context.rs(8),
          context.horizontalPadding,
          context.rs(24),
        ),
        children: [
          Image.asset(
            'assets/pngs/add_bank_account.png',
            height: context.rs(150),
            fit: BoxFit.contain,
          ),
          SizedBox(height: context.rs(12)),
          Text(
            'Add your bank account securely',
            style: kStyle(kSemiBold, kSize18, color: kTextColor, height: 1.2),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.rs(6)),
          Text(
            'Your earnings will be transferred to this account',
            style: kCaption14R.copyWith(
              color: kSecondaryTextColor,
              height: 1.35,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.rs(20)),
          _BankFormField(
            label: 'Account Holder Name',
            controller: _holderController,
            hint: 'Enter account holder name',
          ),
          _BankFormField(
            label: 'Bank Name',
            controller: _bankController,
            hint: 'Select your bank',
            readOnly: true,
            suffix: const Icon(Icons.keyboard_arrow_down_rounded),
            onTap: () => _pickOption(_bankController, const [
              'HDFC Bank',
              'SBI',
              'ICICI Bank',
              'Axis Bank',
            ]),
          ),
          _BankFormField(
            label: 'Branch Name',
            controller: _branchController,
            hint: 'Select your branch',
            readOnly: true,
            suffix: const Icon(Icons.keyboard_arrow_down_rounded),
            onTap: () => _pickOption(_branchController, const [
              'MG Road Branch',
              'Kochi Main Branch',
              'Ernakulam Branch',
            ]),
          ),
          _BankFormField(
            label: 'Account Number',
            controller: _accountController,
            hint: 'Enter Account Number',
            obscure: _obscureAccount,
            suffix: IconButton(
              onPressed: () => setState(() => _obscureAccount = !_obscureAccount),
              icon: Icon(
                _obscureAccount ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: kMutedText,
              ),
            ),
          ),
          _BankFormField(
            label: 'Confirm Account Number',
            controller: _confirmAccountController,
            hint: 'Re-enter account number',
            obscure: _obscureConfirm,
            suffix: IconButton(
              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
              icon: Icon(
                _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: kMutedText,
              ),
            ),
          ),
          _BankFormField(
            label: 'IFSC Code',
            controller: _ifscController,
            hint: 'Enter IFSC Code',
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
          label: 'Verify Account',
          buttonColor: kBrandBlue,
          icon: const Icon(Icons.verified_user_outlined, color: kWhite, size: 18),
          onPressed: _verifyAccount,
        ),
      ),
    );
  }

  Future<void> _pickOption(TextEditingController controller, List<String> options) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options
                .map(
                  (option) => ListTile(
                    title: Text(option),
                    onTap: () => Navigator.pop(context, option),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
    if (selected != null) {
      controller.text = selected;
    }
  }
}

class _BankFormField extends StatelessWidget {
  const _BankFormField({
    required this.label,
    required this.controller,
    required this.hint,
    this.readOnly = false,
    this.obscure = false,
    this.suffix,
    this.onTap,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final bool readOnly;
  final bool obscure;
  final Widget? suffix;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.rs(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: kCaption14B.copyWith(height: 1.2)),
          SizedBox(height: context.rs(8)),
          GestureDetector(
            onTap: onTap,
            child: AbsorbPointer(
              absorbing: onTap != null,
              child: Container(
                decoration: BoxDecoration(
                  color: kWithdrawFieldBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kCardBorder),
                ),
                padding: EdgeInsets.symmetric(horizontal: context.rs(14)),
                child: TextField(
                  controller: controller,
                  readOnly: readOnly,
                  obscureText: obscure,
                  style: kStyle(kRegular, kSize14, color: kTextColor),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: kCaption14R.copyWith(color: kMutedText),
                    border: InputBorder.none,
                    suffixIcon: suffix,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: context.rs(14),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
