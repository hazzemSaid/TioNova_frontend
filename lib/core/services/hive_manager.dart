import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive_flutter/hive_flutter.dart';

// Conditional import for dart:io
import 'hive_manager_stub.dart'
    if (dart.library.io) 'hive_manager_io.dart'
    as platform;

class HiveManager {
  /// Flag to track if Hive is available (false on Safari private mode)
  static bool _isHiveAvailable = false;

  /// Check if Hive storage is available
  static bool get isHiveAvailable => _isHiveAvailable;

  /// Initialize Hive with error handling for corrupted data
  /// Includes timeout for web platforms (iOS Safari can hang)
  static Future<void> initializeHive() async {
    try {
      if (kIsWeb) {
        // On web, use timeout to prevent hanging on iOS Safari
        // Safari private mode blocks IndexedDB completely
        await Hive.initFlutter().timeout(
          const Duration(seconds: 3),
          onTimeout: () {
            print(
              '⚠️ Hive initialization timeout on web (Safari private mode?)',
            );
            throw TimeoutException('Hive init timeout');
          },
        );
        _isHiveAvailable = true;
      } else {
        await Hive.initFlutter();
        _isHiveAvailable = true;
      }
      print('✅ Hive initialized successfully');
    } catch (e) {
      print('⚠️ Error initializing Hive: $e');
      _isHiveAvailable = false;
      // Clear all Hive data and try again (only on non-web)
      if (!kIsWeb) {
        await clearAllHiveData();
        await Hive.initFlutter();
        _isHiveAvailable = true;
      }
      // On web, continue even if Hive fails - the app should still work
      // with limited functionality (in-memory storage fallback)
      print('ℹ️ Hive not available on web - using in-memory fallback');
    }
  }

  /// Clear all Hive data (use when corrupted)
  /// This only works on non-web platforms
  static Future<void> clearAllHiveData() async {
    if (kIsWeb) {
      // On web, we can only clear boxes through Hive API
      print('Clearing Hive data on web is limited');
      return;
    }
    await platform.clearAllHiveData();
  }

  /// Safe box opening with error handling
  static Future<Box<T>> safeOpenBox<T>(
    String boxName, {
    bool deleteIfCorrupted = true,
  }) async {
    try {
      return await Hive.openBox<T>(boxName);
    } catch (e) {
      print('Error opening box $boxName: $e');

      if (deleteIfCorrupted) {
        try {
          await Hive.deleteBoxFromDisk(boxName);
          print('Deleted corrupted box: $boxName');
          return await Hive.openBox<T>(boxName);
        } catch (deleteError) {
          print('Error recreating box $boxName: $deleteError');
          rethrow;
        }
      } else {
        rethrow;
      }
    }
  }

  /// Safe box opening for untyped boxes
  static Future<Box> safeOpenUntypedBox(
    String boxName, {
    bool deleteIfCorrupted = true,
  }) async {
    try {
      return await Hive.openBox(boxName);
    } catch (e) {
      print('Error opening untyped box $boxName: $e');

      if (deleteIfCorrupted) {
        try {
          await Hive.deleteBoxFromDisk(boxName);
          print('Deleted corrupted untyped box: $boxName');
          return await Hive.openBox(boxName);
        } catch (deleteError) {
          print('Error recreating untyped box $boxName: $deleteError');
          rethrow;
        }
      } else {
        rethrow;
      }
    }
  }
}
