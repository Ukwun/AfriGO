import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Token Storage
/// Securely stores JWT tokens using native secure storage
class TokenStorage {
  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';

  final _secureStorage = const FlutterSecureStorage();

  /// Save JWT token
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  /// Get JWT token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String refreshToken) async {
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  /// Save user ID
  Future<void> saveUserId(String userId) async {
    await _secureStorage.write(key: _userIdKey, value: userId);
  }

  /// Get user ID
  Future<String?> getUserId() async {
    return await _secureStorage.read(key: _userIdKey);
  }

  /// Clear all tokens
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }
}
