import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'navigation_context_helper.dart';
import '../models/navigation_context_type.dart';

/// Navigator that preserves navigation context across chapter sub-screens
class ContextAwareNavigator {
  /// Navigates to a chapter sub-screen while preserving context
  static void navigateToChapterSubScreen(
    BuildContext context, {
    required String subScreen, // 'notes', 'summary', 'mindmap', 'pdf'
    Map<String, dynamic>? extra,
  }) {
    final navContext = NavigationContextHelper.detectContextSafely(context);

    if (navContext == null) {
      debugPrint(
        'Warning: Could not detect navigation context, using fallback navigation',
      );
      _fallbackNavigation(context, subScreen, extra);
      return;
    }

    switch (navContext.type) {
      case NavigationContextType.folderBased:
        context.pushNamed(
          'folder-chapter-$subScreen',
          pathParameters: {
            'folderId': navContext.folderId!,
            'chapterId': navContext.chapterId,
          },
          extra: extra,
        );
        break;
      case NavigationContextType.standalone:
        context.pushNamed(
          'chapter-$subScreen',
          pathParameters: {'chapterId': navContext.chapterId},
          extra: extra,
        );
        break;
    }
  }

  /// Navigates to chapter detail while preserving context
  static void navigateToChapterDetail(
    BuildContext context, {
    Map<String, dynamic>? extra,
  }) {
    final navContext = NavigationContextHelper.detectContextSafely(context);

    if (navContext == null) {
      debugPrint(
        'Warning: Could not detect navigation context for chapter detail',
      );
      return;
    }

    switch (navContext.type) {
      case NavigationContextType.folderBased:
        context.goNamed(
          'folder-chapter-detail',
          pathParameters: {
            'folderId': navContext.folderId!,
            'chapterId': navContext.chapterId,
          },
          extra: extra,
        );
        break;
      case NavigationContextType.standalone:
        context.goNamed(
          'chapter-detail',
          pathParameters: {'chapterId': navContext.chapterId},
          extra: extra,
        );
        break;
    }
  }

  /// Gets the appropriate parent route for back navigation
  static String? getParentRoute(BuildContext context) {
    final navContext = NavigationContextHelper.detectContextSafely(context);

    if (navContext == null) return null;

    switch (navContext.type) {
      case NavigationContextType.folderBased:
        return '/folders/${navContext.folderId}/chapters/${navContext.chapterId}';
      case NavigationContextType.standalone:
        return '/chapters/${navContext.chapterId}';
    }
  }

  /// Fallback navigation when context detection fails
  static void _fallbackNavigation(
    BuildContext context,
    String subScreen,
    Map<String, dynamic>? extra,
  ) {
    final state = GoRouterState.of(context);
    final chapterId = state.pathParameters['chapterId'];

    if (chapterId != null) {
      // Try standalone route as fallback
      context.pushNamed(
        'chapter-$subScreen',
        pathParameters: {'chapterId': chapterId},
        extra: extra,
      );
    } else {
      debugPrint('Error: No chapter ID available for fallback navigation');
    }
  }
}
