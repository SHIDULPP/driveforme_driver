import 'package:driveforme_driver/src/data/models/api_response.dart';
import 'package:driveforme_driver/src/data/models/wallet_model.dart';
import 'package:driveforme_driver/src/data/providers/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WalletApi {
  final ApiProvider _api;

  WalletApi(this._api);

  Future<ApiResponse<WalletDetailsModel>> getWalletDetails() async {
    final response = await _api.get('/wallet', requireUserId: true);

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
      requireUserId: true,
    );

    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to recharge wallet.',
        response.statusCode,
      );
    }

    // Recharge returns { walletBalance, transaction } — refetch full wallet.
    return getWalletDetails();
  }
}

final walletApiProvider = Provider<WalletApi>((ref) {
  return WalletApi(ref.watch(apiProviderProvider));
});
