// // main.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:tionova/core/init/app_initializer.dart';
import 'package:tionova/core/presentation/view/screens/app_error_screen.dart';

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
        home: AppErrorScreen(
          details: FlutterErrorDetails(exception: e, stack: stackTrace),
          onRetry: () {
            // Hard reload logic if needed, or re-run main
            if (kIsWeb) {
              // Reload page
              // ignore: unsafe_html
              // html.window.location.reload();
              // Since we can't import html here easily, we rely on user action
            }
            main();
          },
        ),
      ),
    );
  }
}
