import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  // Web-safe options for FlutterSecureStorage
  static const _storage = FlutterSecureStorage(
    webOptions: WebOptions(
      dbName: 'tionova_secure_storage',
      publicKey: 'tionova_secure_key',
    ),
  );
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  // Save tokens with web error handling
  static Future<void> saveTokens(
    String accessToken,
    String refreshToken,
  ) async {
    try {
      await _storage.write(key: _accessTokenKey, value: accessToken);
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    } catch (e) {
      print('⚠️ TokenStorage: Error saving tokens: $e');
      if (kIsWeb) {
        // On web, storage might fail in private browsing mode
        // We log the error but don't crash the app
        print(
          'ℹ️ TokenStorage: Web storage may be unavailable (private browsing?)',
        );
      } else {
        rethrow;
      }
    }
  }

  // Get tokens with web error handling
  static Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (e) {
      print('⚠️ TokenStorage: Error reading access token: $e');
      if (kIsWeb) {
        // Return null on web storage errors instead of crashing
        return null;
      }
      rethrow;
    }
  }

  static Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      print('⚠️ TokenStorage: Error reading refresh token: $e');
      if (kIsWeb) {
        // Return null on web storage errors instead of crashing
        return null;
      }
      rethrow;
    }
  }

  // Delete tokens with web error handling
  static Future<void> clearTokens() async {
    try {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
    } catch (e) {
      print('⚠️ TokenStorage: Error clearing tokens: $e');
      if (kIsWeb) {
        // Ignore errors on web
        print('ℹ️ TokenStorage: Web storage clear failed, ignoring');
      } else {
        rethrow;
      }
    }
  }
}
