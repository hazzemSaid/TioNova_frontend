import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Secure token storage service that works across iOS Safari and web platforms
/// Uses flutter_secure_storage for mobile and SharedPreferences for web with encryption
class TokenStorage {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _encryptionKey = 'encryption_key';

  final FlutterSecureStorage? _secureStorage;
  final SharedPreferences? _sharedPreferences;
  String? _encryptionSecret;

  /// Constructor that initializes appropriate storage based on platform
  TokenStorage()
    : _secureStorage = !kIsWeb ? const FlutterSecureStorage() : null,
      _sharedPreferences = null; // SharedPreferences will be initialized lazily

  /// Save both access and refresh tokens securely
  Future<void> saveTokens(
    String accessToken,
    String refreshToken, {
    int? expiresIn,
  }) async {
    try {
      if (kIsWeb) {
        // Web platform: use SharedPreferences with encryption
        // CRITICAL: Initialize encryption key FIRST before encrypting
        await _getEncryptionKey();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_accessTokenKey, _encryptToken(accessToken));
        await prefs.setString(_refreshTokenKey, _encryptToken(refreshToken));

        if (expiresIn != null) {
          final expiryTime = DateTime.now()
              .add(Duration(seconds: expiresIn))
              .millisecondsSinceEpoch;
          await prefs.setInt(_tokenExpiryKey, expiryTime);
        }
      } else {
        // Mobile platforms: use flutter_secure_storage
        if (_secureStorage == null) {
          throw TokenStorageException(
            'Secure storage not available on this platform',
          );
        }
        await _secureStorage.write(key: _accessTokenKey, value: accessToken);
        await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);

        if (expiresIn != null) {
          final expiryTime = DateTime.now()
              .add(Duration(seconds: expiresIn))
              .millisecondsSinceEpoch;
          await _secureStorage.write(
            key: _tokenExpiryKey,
            value: expiryTime.toString(),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ [TokenStorage] Failed to save tokens: $e');
      throw TokenStorageException('Failed to save tokens: $e');
    }
  }

  /// Get the stored access token
  Future<String?> getAccessToken() async {
    try {
      if (kIsWeb) {
        // CRITICAL: Initialize encryption key FIRST before decrypting
        await _getEncryptionKey();
        final prefs = await SharedPreferences.getInstance();
        final encryptedToken = prefs.getString(_accessTokenKey);
        return encryptedToken != null ? _decryptToken(encryptedToken) : null;
      } else {
        if (_secureStorage == null) return null;
        return await _secureStorage.read(key: _accessTokenKey);
      }
    } catch (e) {
      debugPrint('⚠️ [TokenStorage] Failed to get access token: $e');
      return null; // Return null instead of throwing to be more resilient
    }
  }

  /// Get the stored refresh token
  Future<String?> getRefreshToken() async {
    try {
      if (kIsWeb) {
        // CRITICAL: Initialize encryption key FIRST before decrypting
        await _getEncryptionKey();
        final prefs = await SharedPreferences.getInstance();
        final encryptedToken = prefs.getString(_refreshTokenKey);
        return encryptedToken != null ? _decryptToken(encryptedToken) : null;
      } else {
        if (_secureStorage == null) return null;
        return await _secureStorage.read(key: _refreshTokenKey);
      }
    } catch (e) {
      debugPrint('⚠️ [TokenStorage] Failed to get refresh token: $e');
      return null;
    }
  }

  /// Check if access token is expired
  Future<bool> isAccessTokenExpired() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        final expiryTime = prefs.getInt(_tokenExpiryKey);
        if (expiryTime == null) return true;
        return DateTime.now().millisecondsSinceEpoch >= expiryTime;
      } else {
        if (_secureStorage == null) return true;
        final expiryStr = await _secureStorage.read(key: _tokenExpiryKey);
        if (expiryStr == null) return true;
        final expiryTime = int.tryParse(expiryStr);
        if (expiryTime == null) return true;
        return DateTime.now().millisecondsSinceEpoch >= expiryTime;
      }
    } catch (e) {
      debugPrint('⚠️ [TokenStorage] Error checking token expiry: $e');
      return true; // Assume expired on error
    }
  }

  /// Clear all stored tokens
  Future<void> clearTokens() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_accessTokenKey);
        await prefs.remove(_refreshTokenKey);
        await prefs.remove(_tokenExpiryKey);
      } else {
        if (_secureStorage == null) return;
        await _secureStorage.delete(key: _accessTokenKey);
        await _secureStorage.delete(key: _refreshTokenKey);
        await _secureStorage.delete(key: _tokenExpiryKey);
      }
    } catch (e) {
      debugPrint('❌ [TokenStorage] Failed to clear tokens: $e');
      throw TokenStorageException('Failed to clear tokens: $e');
    }
  }

  /// Generate or retrieve encryption key for web storage
  Future<String> _getEncryptionKey() async {
    if (_encryptionSecret != null) return _encryptionSecret!;

    final prefs = await SharedPreferences.getInstance();
    var key = prefs.getString(_encryptionKey);

    if (key == null) {
      // Generate a new encryption key
      final random = Random.secure();
      final keyBytes = List.generate(32, (_) => random.nextInt(256));
      key = base64Url.encode(keyBytes);
      await prefs.setString(_encryptionKey, key);
    }

    _encryptionSecret = key;
    return key;
  }

  /// Simple encryption for web storage using XOR with a key (basic obfuscation)
  String _encryptToken(String token) {
    final key = _encryptionSecret ?? 'default_key_placeholder';
    final tokenBytes = utf8.encode(token);
    final keyBytes = utf8.encode(key);

    final encryptedBytes = List<int>.generate(tokenBytes.length, (i) {
      return tokenBytes[i] ^ keyBytes[i % keyBytes.length];
    });

    return base64.encode(encryptedBytes);
  }

  /// Simple decryption for web storage
  String _decryptToken(String encryptedToken) {
    try {
      final key = _encryptionSecret ?? 'default_key_placeholder';
      final encryptedBytes = base64.decode(encryptedToken);
      final keyBytes = utf8.encode(key);

      final decryptedBytes = List<int>.generate(encryptedBytes.length, (i) {
        return encryptedBytes[i] ^ keyBytes[i % keyBytes.length];
      });

      return utf8.decode(decryptedBytes);
    } catch (e) {
      throw TokenStorageException('Failed to decrypt token: $e');
    }
  }

  /// Check if tokens exist
  Future<bool> hasTokens() async {
    try {
      final accessToken = await getAccessToken();
      final refreshToken = await getRefreshToken();
      return accessToken != null && refreshToken != null;
    } catch (e) {
      return false;
    }
  }
}

/// Exception class for token storage operations
class TokenStorageException implements Exception {
  final String message;

  TokenStorageException(this.message);

  @override
  String toString() => 'TokenStorageException: $message';
}
