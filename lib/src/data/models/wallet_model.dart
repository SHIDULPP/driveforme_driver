import 'package:intl/intl.dart';

class WalletTransactionModel {
  final String id;
  final double amount;
  final String type;
  final String category;
  final String description;
  final double? balanceAfter;
  final String status;
  final DateTime? createdAt;

  const WalletTransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.description,
    this.balanceAfter,
    this.status = 'completed',
    this.createdAt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      amount: _toDouble(json['amount']) ?? 0,
      type: json['type']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      balanceAfter: _toDouble(json['balanceAfter']),
      status: json['status']?.toString() ?? 'completed',
      createdAt: _parseDate(json['createdAt']),
    );
  }

  bool get isCredit => type == 'credit';

  String get displayAmount {
    final prefix = isCredit ? '+ ' : '- ';
    final value = amount == amount.truncateToDouble()
        ? amount.toInt().toString()
        : amount.toStringAsFixed(2);
    return '$prefix₹ $value';
  }

  String get displayDate {
    final date = createdAt;
    if (date == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    if (target == today) {
      return 'Today, ${DateFormat('hh:mm a').format(date)}';
    }
    return DateFormat('d MMM yyyy, hh:mm a').format(date);
  }

  String get categoryLabel => _titleCase(category.replaceAll('_', ' '));

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  static String _titleCase(String value) {
    if (value.isEmpty) return value;
    return value
        .split(' ')
        .map(
          (part) => part.isEmpty
              ? part
              : '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }
}

class WalletSummaryModel {
  final double totalCredits;
  final double totalDebits;
  final int transactionCount;

  const WalletSummaryModel({
    this.totalCredits = 0,
    this.totalDebits = 0,
    this.transactionCount = 0,
  });

  factory WalletSummaryModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const WalletSummaryModel();
    return WalletSummaryModel(
      totalCredits: (json['totalCredits'] as num?)?.toDouble() ?? 0,
      totalDebits: (json['totalDebits'] as num?)?.toDouble() ?? 0,
      transactionCount: (json['transactionCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class WalletDetailsModel {
  final double walletBalance;
  final String referralCode;
  final WalletSummaryModel summary;
  final List<WalletTransactionModel> transactions;

  const WalletDetailsModel({
    required this.walletBalance,
    this.referralCode = '',
    required this.summary,
    required this.transactions,
  });

  factory WalletDetailsModel.fromJson(Map<String, dynamic> json) {
    final rawTransactions = json['transactions'];
    return WalletDetailsModel(
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0,
      referralCode: json['referralCode']?.toString() ?? '',
      summary: WalletSummaryModel.fromJson(
        json['summary'] as Map<String, dynamic>?,
      ),
      transactions: rawTransactions is List
          ? rawTransactions
                .whereType<Map>()
                .map((item) => WalletTransactionModel.fromJson(
                      Map<String, dynamic>.from(item),
                    ))
                .toList()
          : const [],
    );
  }

  double get totalTripEarnings => transactions
      .where((t) => t.isCredit && t.category == 'trip_earning')
      .fold(0, (sum, t) => sum + t.amount);

  int get completedTripCount =>
      transactions.where((t) => t.category == 'trip_earning').length;

  List<WalletTransactionModel> get earningsTransactions => transactions
      .where((t) => t.category == 'trip_earning' || t.category == 'referral_bonus')
      .toList();

  Map<int, double> weeklyEarningsByWeekday() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(weekStart.year, weekStart.month, weekStart.day);

    final amounts = List<double>.filled(7, 0);
    for (final tx in transactions) {
      if (!tx.isCredit || tx.category != 'trip_earning') continue;
      final date = tx.createdAt;
      if (date == null || date.isBefore(startOfWeek)) continue;
      final dayIndex = date.weekday - 1;
      if (dayIndex >= 0 && dayIndex < 7) {
        amounts[dayIndex] += tx.amount;
      }
    }
    return {for (var i = 0; i < 7; i++) i: amounts[i]};
  }

  double get thisWeekEarnings {
    return weeklyEarningsByWeekday().values.fold(0, (a, b) => a + b);
  }
}

String formatRupee(double amount) {
  if (amount == amount.truncateToDouble()) {
    return '₹ ${amount.toInt()}';
  }
  return '₹ ${amount.toStringAsFixed(2)}';
}

String formatRupeeCompact(double amount) {
  if (amount >= 1000) {
    final thousands = amount / 1000;
    if (thousands == thousands.truncateToDouble()) {
      return '₹ ${thousands.toInt()},000';
    }
    return '₹ ${thousands.toStringAsFixed(1)}k';
  }
  return formatRupee(amount);
}
