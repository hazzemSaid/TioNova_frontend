import 'package:flutter/material.dart';

/// A mixin that provides safe context access methods to prevent
/// "Looking up a deactivated widget's ancestor is unsafe" errors.
///
/// This mixin should be used with StatefulWidget State classes that
/// need to use BuildContext after async operations.
///
/// Usage:
/// ```dart
/// class _MyScreenState extends State<MyScreen> with SafeContextMixin {
///   Future<void> loadData() async {
///     final data = await fetchData();
///
///     // Safe to use context after async
///     if (contextIsValid) {
///       Navigator.of(context).pop();
///       ScaffoldMessenger.of(context).showSnackBar(...);
///     }
///   }
/// }
/// ```
mixin SafeContextMixin<T extends StatefulWidget> on State<T> {
  /// Check if the context is still valid and safe to use.
  /// This checks if the widget is still mounted.
  bool get contextIsValid => mounted;

  /// Safely execute a callback that uses BuildContext.
  /// Only executes if the widget is still mounted.
  ///
  /// Example:
  /// ```dart
  /// await someAsyncOperation();
  /// safeContext((ctx) {
  ///   Navigator.of(ctx).pop();
  /// });
  /// ```
  void safeContext(void Function(BuildContext context) callback) {
    if (mounted) {
      callback(context);
    }
  }

  /// Safely execute an async callback that uses BuildContext.
  /// Only executes if the widget is still mounted.
  ///
  /// Example:
  /// ```dart
  /// await safeContextAsync((ctx) async {
  ///   await Navigator.of(ctx).pushNamed('/route');
  /// });
  /// ```
  Future<void> safeContextAsync(
    Future<void> Function(BuildContext context) callback,
  ) async {
    if (mounted) {
      await callback(context);
    }
  }

  /// Safely execute a callback with return value that uses BuildContext.
  /// Returns null if widget is not mounted.
  ///
  /// Example:
  /// ```dart
  /// final result = safeContextReturn((ctx) {
  ///   return Theme.of(ctx).colorScheme;
  /// });
  /// ```
  R? safeContextReturn<R>(R Function(BuildContext context) callback) {
    if (mounted) {
      return callback(context);
    }
    return null;
  }
}
