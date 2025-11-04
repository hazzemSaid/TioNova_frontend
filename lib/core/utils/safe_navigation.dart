import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Extension to safely handle navigation operations with GoRouter
extension SafeNavigation on BuildContext {
  /// Safely pop the current route, or navigate to fallback if can't pop
  ///
  /// Example:
  /// ```dart
  /// context.safePop(); // Pop or go to '/'
  /// context.safePop(fallback: '/auth'); // Pop or go to '/auth'
  /// ```
  void safePop({String fallback = '/'}) {
    if (canPop()) {
      pop();
    } else {
      go(fallback);
    }
  }

  /// Check if navigation can pop and then pop, returns true if popped
  ///
  /// Example:
  /// ```dart
  /// if (!context.maybePop()) {
  ///   // Handle case where we couldn't pop
  /// }
  /// ```
  bool maybePop() {
    if (canPop()) {
      pop();
      return true;
    }
    return false;
  }

  /// Pop or go to a specific route based on a condition
  ///
  /// Example:
  /// ```dart
  /// context.popOrGo('/home');
  /// ```
  void popOrGo(String route) {
    if (canPop()) {
      pop();
    } else {
      go(route);
    }
  }

  /// Safely replace the current route
  /// Use this when you want to navigate but ensure there's a fallback
  ///
  /// Example:
  /// ```dart
  /// context.safeGo('/profile', ensureHistory: true);
  /// ```
  void safeGo(String route, {bool ensureHistory = false}) {
    if (ensureHistory && !canPop()) {
      // If there's no history and we want to ensure one, push instead
      push(route);
    } else {
      go(route);
    }
  }
}
