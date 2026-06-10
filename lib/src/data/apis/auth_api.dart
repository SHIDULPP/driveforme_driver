import 'package:driveforme_driver/src/data/models/api_response.dart';
import 'package:driveforme_driver/src/data/providers/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthApi {
  static const _driverRole = 'driver';

  final ApiProvider _api;

  AuthApi(this._api);

  Future<ApiResponse<Map<String, dynamic>>> requestOtp(String phoneNumber) {
    return _api.post('/auth/request-otp', {
      'phoneNumber': phoneNumber,
      'role': _driverRole,
    });
  }

  Future<ApiResponse<Map<String, dynamic>>> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) {
    return _api.post('/auth/verify-otp', {
      'phoneNumber': phoneNumber,
      'role': _driverRole,
      'otp': otp,
    });
  }
}

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.watch(apiProviderProvider));
});
