import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:tionova/features/auth/data/models/UserModel.dart';

class HiveInitializer {
  static Future<void> initialize() async {
    // Initialize Hive with a valid path in your app's documents directory
    final appDocumentDir = await path_provider
        .getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }

    // Open the box
    await Hive.openBox('appBox');
  }
}
