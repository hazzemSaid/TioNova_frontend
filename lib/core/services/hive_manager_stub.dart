/// Clear all Hive data - Stub implementation for web
Future<void> clearAllHiveData() async {
  // On web, we can't access file system directly
  // Hive uses IndexedDB on web and handles its own cleanup
  print('clearAllHiveData: Not supported on web platform');
}
