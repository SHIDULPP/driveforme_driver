class BankAccountUiModel {
  const BankAccountUiModel({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    required this.holderName,
    required this.ifscCode,
    this.branchName = '',
    this.isVerified = true,
  });

  final String id;
  final String bankName;
  final String accountNumber;
  final String holderName;
  final String ifscCode;
  final String branchName;
  final bool isVerified;

  String get maskedAccountNumber {
    final digits = accountNumber.replaceAll(RegExp(r'\s'), '');
    if (digits.length <= 4) return digits;
    final last4 = digits.substring(digits.length - 4);
    return 'XXXX XXXX XXXX $last4';
  }

  String get maskedAccountShort {
    final digits = accountNumber.replaceAll(RegExp(r'\s'), '');
    if (digits.length <= 4) return digits;
    return '•••• ${digits.substring(digits.length - 4)}';
  }

  BankAccountUiModel copyWith({
    String? id,
    String? bankName,
    String? accountNumber,
    String? holderName,
    String? ifscCode,
    String? branchName,
    bool? isVerified,
  }) {
    return BankAccountUiModel(
      id: id ?? this.id,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      holderName: holderName ?? this.holderName,
      ifscCode: ifscCode ?? this.ifscCode,
      branchName: branchName ?? this.branchName,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
