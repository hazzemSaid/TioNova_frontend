import 'package:flutter/material.dart';

/// Reusable error dialog handler for all auth screens
class AuthErrorHandler {
  /// Show error dialog with consistent styling across all auth screens
  static void showErrorDialog(
    BuildContext context, {
    required String errorMessage,
    String title = 'Error',
    String actionLabel = 'OK',
    VoidCallback? onAction,
  }) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onAction?.call();
            },
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
