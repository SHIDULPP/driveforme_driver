import 'package:driveforme_driver/src/data/models/bank_account_ui_model.dart';
import 'package:driveforme_driver/src/data/models/withdrawal_ui_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WithdrawFlowState {
  const WithdrawFlowState({
    this.availableEarnings = 2035,
    this.bankAccounts = const [],
    this.selectedBankId,
    this.withdrawals = const [],
  });

  final double availableEarnings;
  final List<BankAccountUiModel> bankAccounts;
  final String? selectedBankId;
  final List<WithdrawalUiModel> withdrawals;

  bool get hasBankAccount => bankAccounts.isNotEmpty;

  BankAccountUiModel? get selectedBank {
    if (selectedBankId == null) return bankAccounts.isNotEmpty ? bankAccounts.first : null;
    for (final account in bankAccounts) {
      if (account.id == selectedBankId) return account;
    }
    return bankAccounts.isNotEmpty ? bankAccounts.first : null;
  }

  WithdrawFlowState copyWith({
    double? availableEarnings,
    List<BankAccountUiModel>? bankAccounts,
    String? selectedBankId,
    List<WithdrawalUiModel>? withdrawals,
  }) {
    return WithdrawFlowState(
      availableEarnings: availableEarnings ?? this.availableEarnings,
      bankAccounts: bankAccounts ?? this.bankAccounts,
      selectedBankId: selectedBankId ?? this.selectedBankId,
      withdrawals: withdrawals ?? this.withdrawals,
    );
  }
}

class WithdrawFlowNotifier extends Notifier<WithdrawFlowState> {
  @override
  WithdrawFlowState build() => const WithdrawFlowState();

  void setAvailableEarnings(double amount) {
    state = state.copyWith(availableEarnings: amount);
  }

  void selectBank(String bankId) {
    state = state.copyWith(selectedBankId: bankId);
  }

  void addBankAccount(BankAccountUiModel account) {
    final accounts = [...state.bankAccounts, account];
    state = state.copyWith(
      bankAccounts: accounts,
      selectedBankId: account.id,
    );
  }

  void addWithdrawal(WithdrawalUiModel withdrawal) {
    state = state.copyWith(
      withdrawals: [withdrawal, ...state.withdrawals],
      availableEarnings: (state.availableEarnings - withdrawal.amount)
          .clamp(0, double.infinity),
    );
  }
}

final withdrawFlowProvider =
    NotifierProvider<WithdrawFlowNotifier, WithdrawFlowState>(
  WithdrawFlowNotifier.new,
);
