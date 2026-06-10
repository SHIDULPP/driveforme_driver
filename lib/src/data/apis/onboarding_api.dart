import 'package:driveforme_driver/src/data/models/api_response.dart';
import 'package:driveforme_driver/src/data/models/user_model.dart';
import 'package:driveforme_driver/src/data/providers/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingApi {
  final ApiProvider _api;

  OnboardingApi(this._api);

  Future<ApiResponse<UserModel>> getMe() async {
    final response = await _api.get('/onboarding/me', requireUserId: true);
    if (!response.success) {
      return ApiResponse.error(
        response.message ?? 'Failed to load profile',
        response.statusCode,
      );
    }

    final data = nestedData(response.data);
    if (data == null) {
      return ApiResponse.error('Invalid profile response');
    }

    return ApiResponse.success(UserModel.fromJson(data), response.statusCode);
  }

  Future<ApiResponse<Map<String, dynamic>>> submitDriverProfile({
    required String fullName,
    required String email,
    required String dateOfBirth,
    required String gender,
    required String location,
  }) {
    return _api.post(
      '/onboarding/driver/profile',
      {
        'fullName': fullName,
        'email': email,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'location': location,
      },
      requireUserId: true,
    );
  }
}

final onboardingApiProvider = Provider<OnboardingApi>((ref) {
  return OnboardingApi(ref.watch(apiProviderProvider));
});
