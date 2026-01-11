import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/navigation_method.dart';
import 'platform_detector.dart';

/// Fallback navigation for error scenarios
class FallbackNavigator {
  /// Handles invalid route scenarios
  static void handleInvalidRoute(BuildContext context, String attemptedRoute) {
    debugPrint('Invalid route attempted: $attemptedRoute');

    // Log the error for debugging
    _logRouteError('Invalid route', attemptedRoute);

    // Show error to user and navigate to safe location
    showRouteError(context, 'The requested page could not be found.');
    navigateToFoldersList(context);
  }

  /// Navigates to folders list as fallback
  static void navigateToFoldersList(BuildContext context) {
    final method = PlatformDetector.preferredMethod;

    try {
      switch (method) {
        case NavigationMethod.replace:
          context.go('/folders');
          break;
        case NavigationMethod.push:
          context.push('/folders');
          break;
      }
    } catch (e) {
      debugPrint('Failed to navigate to folders list: $e');
      // Ultimate fallback - try to go to home
      try {
        context.go('/');
      } catch (homeError) {
        debugPrint('Failed to navigate to home: $homeError');
      }
    }
  }

  /// Shows route error message to user
  static void showRouteError(BuildContext context, String error) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Theme.of(context).colorScheme.error,
        action: SnackBarAction(
          label: 'Go to Folders',
          textColor: Theme.of(context).colorScheme.onError,
          onPressed: () => navigateToFoldersList(context),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Handles malformed parameters
  static void handleMalformedParameters(
    BuildContext context,
    String folderId,
    String chapterId,
  ) {
    final error =
        'Invalid navigation parameters: folderId=$folderId, chapterId=$chapterId';
    debugPrint(error);

    _logRouteError('Malformed parameters', error);

    showRouteError(context, 'Invalid page parameters. Redirecting to folders.');
    navigateToFoldersList(context);
  }

  /// Handles missing context recovery
  static void handleMissingContext(BuildContext context, String chapterId) {
    debugPrint('Missing folder context for chapter: $chapterId');

    _logRouteError('Missing context', 'Chapter ID: $chapterId');

    // Try to navigate to standalone chapter route as fallback
    try {
      final method = PlatformDetector.preferredMethod;
      switch (method) {
        case NavigationMethod.replace:
          context.go('/chapters/$chapterId');
          break;
        case NavigationMethod.push:
          context.push('/chapters/$chapterId');
          break;
      }
    } catch (e) {
      debugPrint('Failed to navigate to standalone chapter: $e');
      navigateToFoldersList(context);
    }
  }

  /// Logs route errors for debugging
  static void _logRouteError(String errorType, String details) {
    final timestamp = DateTime.now().toIso8601String();
    debugPrint('[$timestamp] Navigation Error - $errorType: $details');

    // In a production app, you might want to send this to a logging service
    // For now, we just use debugPrint for development debugging
  }

  /// Creates a safe navigation function that handles errors
  static void safeNavigate(
    BuildContext context,
    VoidCallback navigationFunction, {
    String? fallbackRoute,
  }) {
    try {
      navigationFunction();
    } catch (e) {
      debugPrint('Navigation failed: $e');
      _logRouteError('Navigation exception', e.toString());

      if (fallbackRoute != null) {
        try {
          context.go(fallbackRoute);
        } catch (fallbackError) {
          debugPrint('Fallback navigation failed: $fallbackError');
          navigateToFoldersList(context);
        }
      } else {
        navigateToFoldersList(context);
      }
    }
  }
}
