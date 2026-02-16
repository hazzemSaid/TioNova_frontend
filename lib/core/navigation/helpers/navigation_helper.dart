import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/navigation_context.dart';
import '../models/navigation_method.dart';
import 'platform_detector.dart';
import 'route_builder.dart' as route_utils;

/// Central utility class for all navigation operations with platform-aware methods
class NavigationHelper {
  /// Platform-aware navigation to chapter detail
  static void navigateToChapter(
    BuildContext context, {
    required String folderId,
    required String chapterId,
    Map<String, dynamic>? extra,
  }) {
    final route = route_utils.NavigationRouteBuilder.chapterDetailRoute(
      folderId,
      chapterId,
    );
    final method = PlatformDetector.preferredMethod;

    switch (method) {
      case NavigationMethod.replace:
        context.go(route, extra: extra);
        break;
      case NavigationMethod.push:
        context.push(route, extra: extra);
        break;
    }
  }

  /// Platform-aware navigation to chapter sub-page
  static void navigateToChapterSubpage(
    BuildContext context, {
    required String folderId,
    required String chapterId,
    required String subpage,
    Map<String, dynamic>? extra,
  }) {
    final route = route_utils.NavigationRouteBuilder.chapterSubpageRoute(
      folderId,
      chapterId,
      subpage,
    );
    final method = PlatformDetector.preferredMethod;

    switch (method) {
      case NavigationMethod.replace:
        context.go(route, extra: extra);
        break;
      case NavigationMethod.push:
        context.push(route, extra: extra);
        break;
    }
  }

  /// Platform-aware navigation using GoRouter named routes
  static void navigateToChapterNamed(
    BuildContext context, {
    required String folderId,
    required String chapterId,
    Map<String, dynamic>? extra,
  }) {
    final method = PlatformDetector.preferredMethod;
    final pathParameters = {'folderId': folderId, 'chapterId': chapterId};

    switch (method) {
      case NavigationMethod.replace:
        context.goNamed(
          'folder-chapter-detail',
          pathParameters: pathParameters,
          extra: extra,
        );
        break;
      case NavigationMethod.push:
        context.pushNamed(
          'folder-chapter-detail',
          pathParameters: pathParameters,
          extra: extra,
        );
        break;
    }
  }

  /// Platform-aware navigation to chapter sub-page using named routes
  static void navigateToChapterSubpageNamed(
    BuildContext context, {
    required String folderId,
    required String chapterId,
    required String subpage,
    Map<String, dynamic>? extra,
  }) {
    final method = PlatformDetector.preferredMethod;
    final pathParameters = {'folderId': folderId, 'chapterId': chapterId};

    switch (method) {
      case NavigationMethod.replace:
        context.goNamed(
          'folder-chapter-$subpage',
          pathParameters: pathParameters,
          extra: extra,
        );
        break;
      case NavigationMethod.push:
        context.pushNamed(
          'folder-chapter-$subpage',
          pathParameters: pathParameters,
          extra: extra,
        );
        break;
    }
  }

  /// Platform detection
  static bool isWebPlatform() => PlatformDetector.isWeb;

  /// Get the preferred navigation method for current platform
  static NavigationMethod getNavigationMethod() =>
      PlatformDetector.preferredMethod;

  /// Navigate with context preservation
  static void navigateWithContext(
    BuildContext context, {
    required NavigationContext navContext,
    required String subpage,
    Map<String, dynamic>? extra,
  }) {
    if (navContext.isFolderBased && navContext.folderId != null) {
      navigateToChapterSubpageNamed(
        context,
        folderId: navContext.folderId!,
        chapterId: navContext.chapterId,
        subpage: subpage,
        extra: extra,
      );
    } else {
      // Fallback to standalone navigation
      final method = PlatformDetector.preferredMethod;
      final pathParameters = {'chapterId': navContext.chapterId};

      switch (method) {
        case NavigationMethod.replace:
          context.goNamed(
            'chapter-$subpage',
            pathParameters: pathParameters,
            extra: extra,
          );
          break;
        case NavigationMethod.push:
          context.pushNamed(
            'chapter-$subpage',
            pathParameters: pathParameters,
            extra: extra,
          );
          break;
      }
    }
  }

  /// Navigate to folders list (fallback navigation)
  static void navigateToFoldersList(BuildContext context) {
    final method = PlatformDetector.preferredMethod;

    switch (method) {
      case NavigationMethod.replace:
        context.go('/folders');
        break;
      case NavigationMethod.push:
        context.push('/folders');
        break;
    }
  }
}
