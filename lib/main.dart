// // main.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:tionova/core/init/app_initializer.dart';

Future<void> main() async {
  // Wrap entire main in try-catch to prevent white screen on errors
  try {
    await AppInitializer.initializeApp();
  } catch (e, stackTrace) {
    print('❌ Critical error during app initialization: $e');
    print('Stack trace: $stackTrace');

    // On web, try a minimal fallback initialization instead of showing error
    if (kIsWeb) {
      print('ℹ️ Attempting minimal web fallback...');
      try {
        await AppInitializer.runMinimalWebApp();
        return; // Exit main() if fallback succeeds
      } catch (e2) {
        print('❌ Minimal web fallback also failed: $e2');
      }
    }

    // Run error app only if all else fails
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
                const Text(
                  'Loading failed. Please refresh.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                if (kIsWeb)
                  ElevatedButton(
                    onPressed: () {
                      // Attempt to reload on web
                      // ignore: undefined_prefixed_name
                      // html.window.location.reload();
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
