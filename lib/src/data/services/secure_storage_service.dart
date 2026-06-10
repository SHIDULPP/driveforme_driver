import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SecureStorageService {
  static const _userIdKey = 'user_id';
  static const _phoneNumberKey = 'phone_number';

  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveUserId(String userId) =>
      _storage.write(key: _userIdKey, value: userId);

  Future<String?> getUserId() => _storage.read(key: _userIdKey);

  Future<void> savePhoneNumber(String phoneNumber) =>
      _storage.write(key: _phoneNumberKey, value: phoneNumber);

  Future<String?> getPhoneNumber() => _storage.read(key: _phoneNumberKey);

  Future<void> clearSession() async {
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _phoneNumberKey);
  }
}

final secureStorageServiceProvider = Provider<SecureStorageService>(
  (ref) => SecureStorageService(),
);
