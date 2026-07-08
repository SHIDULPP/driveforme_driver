import 'package:driveforme_driver/src/data/models/api_response.dart';
import 'package:driveforme_driver/src/data/models/bank_account_ui_model.dart';
import 'package:driveforme_driver/src/data/models/wallet_model.dart';
import 'package:driveforme_driver/src/data/providers/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WalletApi {
  final ApiProvider _api;

  WalletApi(this._api);

  Future<ApiResponse<WalletDetailsModel>> getWalletDetails() async {
    final response = await _api.get('/wallet', requireAuth: true);

    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to load wallet.',
        response.statusCode,
      );
    }

    final data = nestedData(response.data);
    if (data == null) {
      return ApiResponse.error('Invalid wallet response');
    }

    return ApiResponse.success(
      WalletDetailsModel.fromJson(data),
      response.statusCode,
    );
  }

  Future<ApiResponse<WalletDetailsModel>> rechargeWallet({
    required double amount,
    String? description,
  }) async {
    final response = await _api.post(
      '/wallet/recharge',
      {
        'amount': amount,
        if (description != null && description.isNotEmpty)
          'description': description,
      },
      requireAuth: true,
    );

    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to recharge wallet.',
        response.statusCode,
      );
    }

    return getWalletDetails();
  }

  Future<ApiResponse<RazorpayOrderModel>> createRazorpayOrder({
    required double amount,
  }) async {
    final response = await _api.post(
      '/wallet/recharge/razorpay-order',
      {'amount': amount},
      requireAuth: true,
    );

    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to create payment order.',
        response.statusCode,
      );
    }

    final data = nestedData(response.data);
    if (data == null) {
      return ApiResponse.error('Invalid Razorpay order response');
    }

    return ApiResponse.success(
      RazorpayOrderModel.fromJson(data),
      response.statusCode,
    );
  }

  Future<ApiResponse<WalletActionResult>> verifyRazorpayPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    String? transactionId,
  }) async {
    final response = await _api.post(
      '/wallet/recharge/razorpay-verify',
      {
        'razorpay_order_id': razorpayOrderId,
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_signature': razorpaySignature,
        if (transactionId != null && transactionId.isNotEmpty)
          'transactionId': transactionId,
      },
      requireAuth: true,
    );

    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Payment verification failed.',
        response.statusCode,
      );
    }

    final data = nestedData(response.data);
    if (data == null) {
      return ApiResponse.error('Invalid payment verification response');
    }

    return ApiResponse.success(
      WalletActionResult.fromJson(data),
      response.statusCode,
    );
  }

  Future<ApiResponse<BankAccountUiModel>> saveBankAccount({
    required String accountHolderName,
    required String bankName,
    required String accountNumber,
    required String confirmAccountNumber,
    required String ifscCode,
    String? branchName,
  }) async {
    final response = await _api.post(
      '/wallet/bank-account',
      {
        'accountHolderName': accountHolderName,
        'bankName': bankName,
        'accountNumber': accountNumber,
        'confirmAccountNumber': confirmAccountNumber,
        'ifscCode': ifscCode.toUpperCase(),
        if (branchName != null && branchName.isNotEmpty)
          'branchName': branchName,
      },
      requireAuth: true,
    );

    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to save bank account.',
        response.statusCode,
      );
    }

    final data = nestedData(response.data);
    if (data == null) {
      return ApiResponse.error('Invalid bank account response');
    }

    return ApiResponse.success(
      BankAccountUiModel.fromJson(data),
      response.statusCode,
    );
  }

  Future<ApiResponse<WalletActionResult>> withdrawFunds({
    required double amount,
  }) async {
    final response = await _api.post(
      '/wallet/withdraw',
      {'amount': amount},
      requireAuth: true,
    );

    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Withdrawal failed.',
        response.statusCode,
      );
    }

    final data = nestedData(response.data);
    if (data == null) {
      return ApiResponse.error('Invalid withdrawal response');
    }

    return ApiResponse.success(
      WalletActionResult.fromJson(data),
      response.statusCode,
    );
  }

  Future<ApiResponse<ApplyReferralResult>> applyReferralCode({
    required String referralCode,
  }) async {
    final response = await _api.post(
      '/wallet/apply-referral',
      {'referralCode': referralCode.trim().toUpperCase()},
      requireAuth: true,
    );

    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to apply referral code.',
        response.statusCode,
      );
    }

    final data = nestedData(response.data);
    if (data == null) {
      return ApiResponse.error('Invalid referral response');
    }

    return ApiResponse.success(
      ApplyReferralResult.fromJson(data),
      response.statusCode,
    );
  }

  Future<ApiResponse<List<String>>> getAvailableBanks() async {
    final response = await _api.get('/wallet/banks/all', requireAuth: true);

    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to load banks.',
        response.statusCode,
      );
    }

    final data = response.data?['data'];
    if (data == null || data is! List) {
      return ApiResponse.error('Invalid banks response');
    }

    return ApiResponse.success(
      data.map((e) => e.toString()).toList(),
      response.statusCode,
    );
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getBranchesForBank({
    required String bankName,
    String? search,
  }) async {
    final response = await _api.get(
      '/wallet/banks/branches',
      queryParams: {
        'bankName': bankName,
        if (search != null && search.isNotEmpty) 'search': search,
      },
      requireAuth: true,
    );

    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to load branches.',
        response.statusCode,
      );
    }

    final data = response.data?['data'];
    if (data == null || data is! List) {
      return ApiResponse.error('Invalid branches response');
    }

    return ApiResponse.success(
      data.map((e) => Map<String, dynamic>.from(e as Map)).toList(),
      response.statusCode,
    );
  }
}

final walletApiProvider = Provider<WalletApi>((ref) {
  return WalletApi(ref.watch(apiProviderProvider));
});
