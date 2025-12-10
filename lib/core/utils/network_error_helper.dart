import 'package:flutter/material.dart';
import 'package:tionova/core/router/app_router.dart';

/// Helper class for displaying network error dialogs
class NetworkErrorHelper {
  static bool _isDialogShowing = false;

  /// Show a dialog when server is unreachable
  static void showServerDownDialog({
    String title = 'Connection Error',
    String message =
        'The app is currently unable to connect to the server. Please try again later.',
    String buttonText = 'OK',
  }) {
    final context = AppRouter.navigatorKey.currentContext;
    if (context == null || _isDialogShowing) return;

    _isDialogShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(
          Icons.cloud_off_rounded,
          size: 48,
          color: Colors.redAccent,
        ),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600]),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _isDialogShowing = false;
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    ).then((_) {
      _isDialogShowing = false;
    });
  }

  /// Check if a DioException is a connection error
  static bool isConnectionError(dynamic error) {
    if (error.toString().contains('Connection refused') ||
        error.toString().contains('SocketException') ||
        error.toString().contains('connection error') ||
        error.toString().contains('Network is unreachable')) {
      return true;
    }
    return false;
  }
}
