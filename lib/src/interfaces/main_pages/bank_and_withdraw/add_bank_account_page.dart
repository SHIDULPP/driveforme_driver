import 'package:driveforme_driver/src/data/apis/wallet_api.dart';
import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/services/navigation_services.dart';
import 'package:driveforme_driver/src/data/utils/responsive.dart';
import 'package:driveforme_driver/src/interfaces/components/primarybutton.dart';
import 'package:driveforme_driver/src/data/models/bank_account_ui_model.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/bank_and_withdraw/withdraw_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddBankAccountPage extends ConsumerStatefulWidget {
  const AddBankAccountPage({super.key});

  @override
  ConsumerState<AddBankAccountPage> createState() => _AddBankAccountPageState();
}

class _AddBankAccountPageState extends ConsumerState<AddBankAccountPage> {
  final _holderController = TextEditingController();
  final _bankController = TextEditingController();
  final _branchController = TextEditingController();
  final _accountController = TextEditingController();
  final _confirmAccountController = TextEditingController();
  final _ifscController = TextEditingController();

  bool _obscureAccount = true;
  bool _obscureConfirm = true;

  List<String> _cachedBanks = [];

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

    if (_accountController.text.trim() !=
        _confirmAccountController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account numbers do not match.')),
      );
      return;
    }

    final account = BankAccountUiModel(
      id: BankAccountUiModel.primaryId,
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

  Future<void> _selectBank() async {
    if (_cachedBanks.isEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      final res = await ref.read(walletApiProvider).getAvailableBanks();
      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialog
      }

      if (res.success && res.data != null) {
        _cachedBanks = res.data!;
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res.message ?? 'Failed to load banks.')),
          );
        }
        return;
      }
    }

    if (!mounted) return;
    final selectedBank = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SearchableSelectorDialog<String>(
        title: 'Select Bank Name',
        hintText: 'Search bank...',
        initialItems: _cachedBanks,
        itemLabel: (item) => item,
      ),
    );

    if (selectedBank != null && selectedBank != _bankController.text) {
      setState(() {
        _bankController.text = selectedBank;
        _branchController.clear();
        _ifscController.clear();
      });
    }
  }

  Future<void> _selectBranch() async {
    final selectedBank = _bankController.text;
    if (selectedBank.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your bank first.')),
      );
      return;
    }

    final selectedBranchMap = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SearchableSelectorDialog<Map<String, dynamic>>(
        title: 'Select Branch Name',
        hintText: 'Search branch by name or location...',
        itemLabel: (item) => item['branchName']?.toString() ?? '',
        onSearch: (query) async {
          final res = await ref
              .read(walletApiProvider)
              .getBranchesForBank(bankName: selectedBank, search: query);
          return res.data ?? [];
        },
      ),
    );

    if (selectedBranchMap != null) {
      setState(() {
        _branchController.text =
            selectedBranchMap['branchName']?.toString() ?? '';
        _ifscController.text = selectedBranchMap['ifsc']?.toString() ?? '';
      });
    }
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
            onTap: _selectBank,
          ),
          _BankFormField(
            label: 'Branch Name',
            controller: _branchController,
            hint: 'Select your branch',
            readOnly: true,
            suffix: const Icon(Icons.keyboard_arrow_down_rounded),
            onTap: _selectBranch,
          ),
          _BankFormField(
            label: 'Account Number',
            controller: _accountController,
            hint: 'Enter Account Number',
            obscure: _obscureAccount,
            suffix: IconButton(
              onPressed: () =>
                  setState(() => _obscureAccount = !_obscureAccount),
              icon: Icon(
                _obscureAccount
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
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
              onPressed: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
              icon: Icon(
                _obscureConfirm
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
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
          icon: const Icon(
            Icons.verified_user_outlined,
            color: kWhite,
            size: 18,
          ),
          onPressed: _verifyAccount,
        ),
      ),
    );
  }
}

class _SearchableSelectorDialog<T> extends StatefulWidget {
  final String title;
  final String hintText;
  final List<T>? initialItems;
  final Future<List<T>> Function(String)? onSearch;
  final String Function(T) itemLabel;

  const _SearchableSelectorDialog({
    required this.title,
    required this.hintText,
    this.initialItems,
    this.onSearch,
    required this.itemLabel,
  });

  @override
  State<_SearchableSelectorDialog<T>> createState() =>
      _SearchableSelectorDialogState<T>();
}

class _SearchableSelectorDialogState<T>
    extends State<_SearchableSelectorDialog<T>> {
  final _searchController = TextEditingController();
  List<T> _filteredItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialItems != null) {
      _filteredItems = List.from(widget.initialItems!);
    } else {
      _performSearch('');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (widget.onSearch != null) {
      setState(() => _isLoading = true);
      try {
        final results = await widget.onSearch!(query);
        if (mounted) {
          setState(() {
            _filteredItems = results;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else if (widget.initialItems != null) {
      setState(() {
        _filteredItems = widget.initialItems!
            .where(
              (item) => widget
                  .itemLabel(item)
                  .toLowerCase()
                  .contains(query.toLowerCase()),
            )
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          SizedBox(height: context.rs(12)),
          Container(
            width: context.rs(40),
            height: context.rs(5),
            decoration: BoxDecoration(
              color: kCardBorder,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: context.rs(16)),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.horizontalPadding,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: kStyle(kSemiBold, kSize18, color: kTextColor),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close_rounded, color: kMutedText),
                ),
              ],
            ),
          ),
          SizedBox(height: context.rs(12)),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.horizontalPadding,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: kWithdrawFieldBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kCardBorder),
              ),
              padding: EdgeInsets.symmetric(horizontal: context.rs(14)),
              child: TextField(
                controller: _searchController,
                style: kStyle(kRegular, kSize14, color: kTextColor),
                onChanged: _performSearch,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: kCaption14R.copyWith(color: kMutedText),
                  border: InputBorder.none,
                  icon: const Icon(Icons.search_rounded, color: kMutedText),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: context.rs(14),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: context.rs(12)),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredItems.isEmpty
                ? Center(
                    child: Text(
                      'No items found',
                      style: kCaption14R.copyWith(color: kMutedText),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      return ListTile(
                        title: Text(
                          widget.itemLabel(item),
                          style: kStyle(kRegular, kSize14, color: kTextColor),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: context.horizontalPadding,
                          vertical: context.rs(4),
                        ),
                        onTap: () => Navigator.pop(context, item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
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
