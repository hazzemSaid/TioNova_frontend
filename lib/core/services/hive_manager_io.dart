import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Clear all Hive data - IO implementation
Future<void> clearAllHiveData() async {
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
