import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SecureStorageService {
  static const _userIdKey = 'user_id';
  static const _phoneNumberKey = 'phone_number';
  static const _authTokenKey = 'auth_token';
  static const _activeTripIdKey = 'active_trip_id';
  static const _driverOnlineKey = 'driver_online';

  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveUserId(String userId) =>
      _storage.write(key: _userIdKey, value: userId);

  Future<String?> getUserId() => _storage.read(key: _userIdKey);

  Future<void> savePhoneNumber(String phoneNumber) =>
      _storage.write(key: _phoneNumberKey, value: phoneNumber);

  Future<String?> getPhoneNumber() => _storage.read(key: _phoneNumberKey);

  Future<void> saveAuthToken(String token) =>
      _storage.write(key: _authTokenKey, value: token);

  Future<String?> getAuthToken() => _storage.read(key: _authTokenKey);

  Future<void> saveActiveTripId(String tripId) =>
      _storage.write(key: _activeTripIdKey, value: tripId);

  Future<String?> getActiveTripId() => _storage.read(key: _activeTripIdKey);

  Future<void> clearActiveTripId() => _storage.delete(key: _activeTripIdKey);

  Future<void> saveDriverOnline(bool isOnline) =>
      _storage.write(key: _driverOnlineKey, value: isOnline.toString());

  Future<bool> getDriverOnline() async {
    final value = await _storage.read(key: _driverOnlineKey);
    if (value == null) return true;
    return value == 'true';
  }

  Future<void> clearDriverOnline() => _storage.delete(key: _driverOnlineKey);

  Future<void> clearSession() async {
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _phoneNumberKey);
    await _storage.delete(key: _authTokenKey);
    await _storage.delete(key: _activeTripIdKey);
    await _storage.delete(key: _driverOnlineKey);
  }
}

final secureStorageServiceProvider = Provider<SecureStorageService>(
  (ref) => SecureStorageService(),
);
