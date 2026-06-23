import 'package:driveforme_driver/src/data/apis/wallet_api.dart';
import 'package:driveforme_driver/src/data/models/wallet_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Loads wallet balance and transactions from `GET /wallet`.
final walletProvider = FutureProvider<WalletDetailsModel>((ref) async {
  final response = await ref.read(walletApiProvider).getWalletDetails();
  if (!response.success || response.data == null) {
    throw Exception(response.message ?? 'Failed to load wallet.');
  }
  return response.data!;
});
