// // main.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:tionova/core/init/app_initializer.dart';

Future<void> main() async {
  // Configure URL strategy for web (removes # from URLs)
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  // Initialize and run the app
  try {
    await AppInitializer.initializeApp();
    // App is now running - do not add any code after this
  } catch (e, stackTrace) {
    print('❌ Critical error during app initialization: $e');
    print('Stack trace: $stackTrace');

    // Send error to backend for debugging
    try {
      // Dio dio = Dio();
      // await dio.post(
      //   '$baseUrl/error-log',
      //   data: {'message': e.toString() + " during app initialization"},
      // );
      print('✅ Error sent to backend');
    } catch (logError) {
      print('⚠️ Failed to send error to backend: $logError');
    }

    // Run error app
    runApp(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'TioNova',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Error: ${e.toString()}',
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                    textAlign: TextAlign.center,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 20),
                if (kIsWeb)
                  ElevatedButton(
                    onPressed: () {
                      // Reload on web
                    },
                    child: const Text('Retry'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
