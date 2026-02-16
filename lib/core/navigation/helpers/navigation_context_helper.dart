import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/navigation_context.dart';

/// Helper class for detecting and working with navigation context
class NavigationContextHelper {
  /// Detects the current navigation context based on the current route
  static NavigationContext detectContext(BuildContext context) {
    final state = GoRouterState.of(context);
    final location = state.uri.path;
    final pathParameters = state.pathParameters;

    // Check if we're in a folder-based route
    if (location.contains('/folders/') &&
        pathParameters.containsKey('folderId')) {
      final folderId = pathParameters['folderId'];
      final chapterId = pathParameters['chapterId'];

      if (folderId != null && chapterId != null) {
        return NavigationContext.folderBased(
          folderId: folderId,
          chapterId: chapterId,
        );
      }
    }

    // Default to standalone context
    final chapterId = pathParameters['chapterId'];
    if (chapterId != null) {
      return NavigationContext.standalone(chapterId: chapterId);
    }

    throw StateError(
      'Unable to determine navigation context from current route: $location',
    );
  }

  /// Determines if the current route is folder-based
  static bool isFolderBasedRoute(BuildContext context) {
    try {
      return detectContext(context).isFolderBased;
    } catch (e) {
      return false;
    }
  }

  /// Gets the folder ID from current context (null if standalone)
  static String? getCurrentFolderId(BuildContext context) {
    try {
      return detectContext(context).folderId;
    } catch (e) {
      return null;
    }
  }

  /// Gets the chapter ID from current context
  static String? getCurrentChapterId(BuildContext context) {
    try {
      return detectContext(context).chapterId;
    } catch (e) {
      return null;
    }
  }

  /// Safely detects context with fallback
  static NavigationContext? detectContextSafely(BuildContext context) {
    try {
      return detectContext(context);
    } catch (e) {
      debugPrint('Failed to detect navigation context: $e');
      return null;
    }
  }
}
