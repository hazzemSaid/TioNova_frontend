import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class HiveManager {
  /// Initialize Hive with error handling for corrupted data
  static Future<void> initializeHive() async {
    try {
      await Hive.initFlutter();
    } catch (e) {
      print('Error initializing Hive: $e');
      // Clear all Hive data and try again
      await clearAllHiveData();
      await Hive.initFlutter();
    }
  }

  /// Clear all Hive data (use when corrupted)
  static Future<void> clearAllHiveData() async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final hiveDir = Directory('${appDocDir.path}');

      if (await hiveDir.exists()) {
        final files = await hiveDir.list().where((entity) {
          return entity.path.contains('.hive') || entity.path.contains('.lock');
        }).toList();

        for (final file in files) {
          try {
            await file.delete();
            print('Deleted Hive file: ${file.path}');
          } catch (e) {
            print('Error deleting ${file.path}: $e');
          }
        }
      }
    } catch (e) {
      print('Error clearing Hive data: $e');
    }
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
