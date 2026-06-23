import 'package:driveforme_driver/src/data/apis/onboarding_api.dart';
import 'package:driveforme_driver/src/data/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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

String displayFullName(UserModel? user) {
  final name = user?.profile.fullName.trim();
  if (name == null || name.isEmpty) return 'Driver';
  return name;
}

String displayLocation(UserModel? user) {
  final location = user?.profile.location.trim();
  if (location == null || location.isEmpty) return 'Location not set';
  if (location.length == 1) return location.toUpperCase();
  return location[0].toUpperCase() + location.substring(1);
}

String displayEmail(UserModel? user) {
  final email = user?.profile.email.trim();
  if (email == null || email.isEmpty) return '—';
  return email;
}

String displayPhone(UserModel? user) {
  final phone = user?.phoneNumber.trim() ?? '';
  if (phone.isEmpty) return '—';
  if (phone.startsWith('+')) return phone;
  if (phone.length == 10) return '+91 $phone';
  return phone;
}

String displayDateOfBirth(UserModel? user) {
  final dob = user?.profile.dateOfBirth;
  if (dob == null) return '—';
  return DateFormat('dd/MM/yyyy').format(dob);
}

String displayGender(UserModel? user) {
  final gender = user?.profile.gender.trim() ?? '';
  if (gender.isEmpty) return '—';
  return gender[0].toUpperCase() + gender.substring(1);
}

String displayRating(UserModel? user) {
  final rating = user?.rating ?? 5.0;
  return rating.toStringAsFixed(1);
}

String displayTotalTrips(UserModel? user) {
  final trips = user?.totalTrips ?? 0;
  return '$trips completed ${trips == 1 ? 'trip' : 'trips'}';
}

String? profilePhotoUrl(UserModel? user) {
  final url = user?.driverVerification.livePhotoUrl.trim();
  if (url == null || url.isEmpty) return null;
  return url;
}

String formatWalletBalance(UserModel? user) {
  final balance = user?.walletBalance ?? 0;
  if (balance == balance.truncateToDouble()) {
    return '₹ ${balance.toInt()}';
  }
  return '₹ ${balance.toStringAsFixed(2)}';
}
