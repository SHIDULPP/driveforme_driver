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
}
