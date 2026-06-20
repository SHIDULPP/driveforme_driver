import 'package:driveforme_driver/src/data/apis/onboarding_api.dart';
import 'package:driveforme_driver/src/data/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Loads the logged-in user from `GET /onboarding/me`.
final userProvider = FutureProvider<UserModel?>((ref) async {
  final response = await ref.read(onboardingApiProvider).getMe();
  return response.data;
});

String greetingFirstName(UserModel? user) {
  final fullName = user?.profile.fullName.trim();
  if (fullName == null || fullName.isEmpty) return 'there';
  return fullName.split(RegExp(r'\s+')).first;
}

String displayLocation(UserModel? user) {
  final location = user?.profile.location.trim();
  if (location == null || location.isEmpty) return 'Location not set';
  if (location.length == 1) return location.toUpperCase();
  return location[0].toUpperCase() + location.substring(1);
}

String formatWalletBalance(UserModel? user) {
  final balance = user?.walletBalance ?? 0;
  if (balance == balance.truncateToDouble()) {
    return '₹ ${balance.toInt()}';
  }
  return '₹ ${balance.toStringAsFixed(2)}';
}
