import 'package:driveforme_driver/src/data/models/wallet_model.dart';

class WithdrawalUiModel {
  const WithdrawalUiModel({
    required this.id,
    required this.amount,
    required this.bankName,
    required this.maskedAccount,
    required this.status,
    required this.date,
  });

  final String id;
  final double amount;
  final String bankName;
  final String maskedAccount;
  final String status;
  final DateTime date;

  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isFailed => status.toLowerCase() == 'failed';

  factory WithdrawalUiModel.fromWalletTransaction(WalletTransactionModel tx) {
    var bankName = 'Bank';
    var maskedAccount = '••••';

    final match = RegExp(
      r'Withdrawal to (.+) \((\d{4})\)',
    ).firstMatch(tx.description);
    if (match != null) {
      bankName = match.group(1)?.trim() ?? bankName;
      maskedAccount = '•••• ${match.group(2)}';
    }

    final normalizedStatus = tx.status.toLowerCase();
    final displayStatus = normalizedStatus == 'completed'
        ? 'Completed'
        : normalizedStatus == 'failed'
            ? 'Failed'
            : _titleCase(tx.status);

    return WithdrawalUiModel(
      id: tx.id,
      amount: tx.amount,
      bankName: bankName,
      maskedAccount: maskedAccount,
      status: displayStatus,
      date: tx.createdAt ?? DateTime.now(),
    );
  }

  static String _titleCase(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}

List<WithdrawalUiModel> withdrawalTransactionsFromWallet(
  WalletDetailsModel wallet, {
  bool thisWeekOnly = true,
}) {
  final now = DateTime.now();
  final weekStart = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: now.weekday - 1));

  return wallet.transactions
      .where((tx) {
        if (tx.category.toLowerCase() != 'withdrawal') return false;
        if (!thisWeekOnly) return true;
        final date = tx.createdAt;
        return date != null && !date.isBefore(weekStart);
      })
      .map(WithdrawalUiModel.fromWalletTransaction)
      .toList();
}
