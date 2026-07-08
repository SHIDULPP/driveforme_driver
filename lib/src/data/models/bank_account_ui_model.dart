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

  static const primaryId = 'primary';

  final String id;
  final String bankName;
  final String accountNumber;
  final String holderName;
  final String ifscCode;
  final String branchName;
  final bool isVerified;

  factory BankAccountUiModel.fromJson(Map<String, dynamic> json) {
    return BankAccountUiModel(
      id: json['id']?.toString() ?? primaryId,
      bankName: json['bankName']?.toString() ?? '',
      accountNumber: json['accountNumber']?.toString() ?? '',
      holderName: json['accountHolderName']?.toString() ??
          json['holderName']?.toString() ??
          '',
      ifscCode: json['ifscCode']?.toString() ?? '',
      branchName: json['branchName']?.toString() ?? '',
      isVerified: json['isVerified'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountHolderName': holderName,
      'ifscCode': ifscCode,
      'branchName': branchName,
      'isVerified': isVerified,
    };
  }

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
