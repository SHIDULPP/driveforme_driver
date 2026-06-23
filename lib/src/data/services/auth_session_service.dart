import 'package:driveforme_driver/src/data/apis/onboarding_api.dart';
import 'package:driveforme_driver/src/data/services/secure_storage_service.dart';
import 'package:driveforme_driver/src/data/utils/auth_navigation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Decides which screen to open after splash based on stored session + API.
class AuthSessionService {
  final SecureStorageService _storage;
  final OnboardingApi _onboardingApi;

  AuthSessionService({
    required SecureStorageService storage,
    required OnboardingApi onboardingApi,
  }) : _storage = storage,
       _onboardingApi = onboardingApi;

  Future<String> resolveInitialRoute() async {
    final userId = await _storage.getUserId();
    final token = await _storage.getAuthToken();
    if (userId == null ||
        userId.isEmpty ||
        token == null ||
        token.isEmpty) {
      await _storage.clearSession();
      return 'Phone';
    }

    final response = await _onboardingApi.getMe();
    if (!response.success || response.data == null) {
      await _storage.clearSession();
      return 'Phone';
    }

    return routeForUser(response.data!);
  }
}

final authSessionServiceProvider = Provider<AuthSessionService>((ref) {
  return AuthSessionService(
    storage: ref.watch(secureStorageServiceProvider),
    onboardingApi: ref.watch(onboardingApiProvider),
  );
});
