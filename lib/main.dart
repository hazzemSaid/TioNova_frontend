// // main.dart
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:tionova/core/init/app_initializer.dart';
import 'package:tionova/core/presentation/view/screens/app_error_screen.dart';

Future<void> main() async {
  // Configure URL strategy for web (removes # from URLs)
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  // Initialize Sentry only in release mode
  if (kReleaseMode) {
    await SentryFlutter.init((options) {
      options.dsn =
          'https://eb7964b3446851eca39197ee93936244@o4510990565244928.ingest.de.sentry.io/4510990566752336';
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
    }, appRunner: () => _runApp());
    // TODO: Remove this line after sending the first sample event to sentry.
  } else {
    // Debug mode: run app without Sentry
    _runApp();
  }
}

Future<void> _runApp() async {
  try {
    await AppInitializer.initializeApp();
    // App is now running - do not add any code after this
  } catch (e, stackTrace) {
    print('❌ Critical error during app initialization: $e');
    print('Stack trace: $stackTrace');

    // Show error screen
    Widget errorApp = MaterialApp(
      home: AppErrorScreen(
        details: FlutterErrorDetails(exception: e, stack: stackTrace),
        onRetry: () {
          main();
        },
      ),
    );

    // Wrap with SentryWidget if in release mode
    if (kReleaseMode) {
      errorApp = SentryWidget(child: errorApp);
    }

    runApp(errorApp);
  }
}
