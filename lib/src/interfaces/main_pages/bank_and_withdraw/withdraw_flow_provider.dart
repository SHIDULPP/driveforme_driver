import 'dart:convert';

import 'package:driveforme_driver/src/data/apis/wallet_api.dart';
import 'package:driveforme_driver/src/data/models/bank_account_ui_model.dart';
import 'package:driveforme_driver/src/data/services/secure_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WithdrawFlowState {
  const WithdrawFlowState({
    this.availableBalance = 0,
    this.bankAccounts = const [],
    this.selectedBankId,
    this.isLoadingBank = false,
    this.isSubmitting = false,
  });

  final double availableBalance;
  final List<BankAccountUiModel> bankAccounts;
  final String? selectedBankId;
  final bool isLoadingBank;
  final bool isSubmitting;

  bool get hasBankAccount => bankAccounts.isNotEmpty;

  BankAccountUiModel? get selectedBank {
    if (selectedBankId == null) {
      return bankAccounts.isNotEmpty ? bankAccounts.first : null;
    }
    for (final account in bankAccounts) {
      if (account.id == selectedBankId) return account;
    }
    return bankAccounts.isNotEmpty ? bankAccounts.first : null;
  }

  WithdrawFlowState copyWith({
    double? availableBalance,
    List<BankAccountUiModel>? bankAccounts,
    String? selectedBankId,
    bool? isLoadingBank,
    bool? isSubmitting,
  }) {
    return WithdrawFlowState(
      availableBalance: availableBalance ?? this.availableBalance,
      bankAccounts: bankAccounts ?? this.bankAccounts,
      selectedBankId: selectedBankId ?? this.selectedBankId,
      isLoadingBank: isLoadingBank ?? this.isLoadingBank,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class WithdrawFlowNotifier extends Notifier<WithdrawFlowState> {
  @override
  WithdrawFlowState build() => const WithdrawFlowState();

  SecureStorageService get _storage => ref.read(secureStorageServiceProvider);
  WalletApi get _walletApi => ref.read(walletApiProvider);

  void setAvailableBalance(double amount) {
    state = state.copyWith(availableBalance: amount);
  }

  void selectBank(String bankId) {
    state = state.copyWith(selectedBankId: bankId);
  }

  Future<void> loadSavedBankAccount() async {
    state = state.copyWith(isLoadingBank: true);
    try {
      final raw = await _storage.getBankAccountJson();
      if (raw == null || raw.isEmpty) return;

      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return;

      final account = BankAccountUiModel.fromJson(decoded);
      if (!account.isVerified || account.bankName.isEmpty) return;

      state = state.copyWith(
        bankAccounts: [account],
        selectedBankId: account.id,
      );
    } catch (_) {
      // Ignore corrupt cache and let the user add a bank account again.
    } finally {
      state = state.copyWith(isLoadingBank: false);
    }
  }

  Future<String?> saveBankAccount({
    required String accountHolderName,
    required String bankName,
    required String accountNumber,
    required String confirmAccountNumber,
    required String ifscCode,
    String? branchName,
  }) async {
    state = state.copyWith(isSubmitting: true);
    try {
      final response = await _walletApi.saveBankAccount(
        accountHolderName: accountHolderName,
        bankName: bankName,
        accountNumber: accountNumber,
        confirmAccountNumber: confirmAccountNumber,
        ifscCode: ifscCode,
        branchName: branchName,
      );

      if (!response.success || response.data == null) {
        return response.message ?? 'Failed to save bank account.';
      }

      final account = response.data!.copyWith(
        id: BankAccountUiModel.primaryId,
      );
      await _storage.saveBankAccountJson(jsonEncode(account.toJson()));

      state = state.copyWith(
        bankAccounts: [account],
        selectedBankId: account.id,
      );
      return null;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  Future<String?> withdrawFunds(double amount) async {
    state = state.copyWith(isSubmitting: true);
    try {
      final response = await _walletApi.withdrawFunds(amount: amount);
      if (!response.success || response.data == null) {
        return response.message ?? 'Withdrawal failed.';
      }

      state = state.copyWith(
        availableBalance: response.data!.walletBalance,
      );
      return null;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}

final withdrawFlowProvider =
    NotifierProvider<WithdrawFlowNotifier, WithdrawFlowState>(
  WithdrawFlowNotifier.new,
);
