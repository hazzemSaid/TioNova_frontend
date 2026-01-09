import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'context_aware_navigator.dart';

/// Helper class for context-aware back navigation
class ContextAwareBackNavigation {
  /// Handles back navigation with context awareness
  static void navigateBack(BuildContext context) {
    final router = GoRouter.of(context);

    if (router.canPop()) {
      router.pop();
    } else {
      // Handle deep-link scenarios by navigating to appropriate parent
      final parentRoute = ContextAwareNavigator.getParentRoute(context);
      if (parentRoute != null) {
        router.go(parentRoute);
      } else {
        // Ultimate fallback - go to folders list
        router.go('/folders');
      }
    }
  }

  /// Creates a context-aware back button
  static Widget createBackButton(
    BuildContext context, {
    Color? color,
    VoidCallback? onPressed,
    double? size,
    EdgeInsetsGeometry? padding,
  }) {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: color, size: size ?? 24),
      onPressed: onPressed ?? () => navigateBack(context),
      padding: padding,
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Creates a context-aware back button with custom styling
  static Widget createStyledBackButton(
    BuildContext context, {
    Color? iconColor,
    Color? backgroundColor,
    VoidCallback? onPressed,
    double? size,
    BorderRadius? borderRadius,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      icon: Icon(
        Icons.arrow_back,
        color: iconColor ?? colorScheme.onSurface,
        size: size ?? 24,
      ),
      onPressed: onPressed ?? () => navigateBack(context),
      style: IconButton.styleFrom(
        backgroundColor: backgroundColor ?? colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}
