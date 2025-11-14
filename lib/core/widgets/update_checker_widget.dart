import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tionova/core/services/shorebird_service.dart';

/// Widget that checks for Shorebird updates and shows notification when available
/// Works with direct APK distribution (no Play Store needed)
class UpdateCheckerWidget extends StatefulWidget {
  final Widget child;

  const UpdateCheckerWidget({super.key, required this.child});

  @override
  State<UpdateCheckerWidget> createState() => _UpdateCheckerWidgetState();
}

class _UpdateCheckerWidgetState extends State<UpdateCheckerWidget> {
  final ShorebirdService _shorebirdService = ShorebirdService();
  Timer? _updateCheckTimer;
  bool _hasShownUpdateDialog = false;

  @override
  void initState() {
    super.initState();
    // Check for updates after a short delay
    Future.delayed(const Duration(seconds: 3), () {
      _checkForUpdates();
    });

    // Set up periodic checks (every 30 minutes)
    _updateCheckTimer = Timer.periodic(
      const Duration(minutes: 30),
      (_) => _checkForUpdates(),
    );
  }

  @override
  void dispose() {
    _updateCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkForUpdates() async {
    if (!mounted || _hasShownUpdateDialog) return;

    try {
      // Check if Shorebird is available (only works in release builds)
      final isAvailable = await _shorebirdService.isShorebirdAvailable();
      if (!isAvailable) {
        print('ℹ️ UpdateChecker: Shorebird not available (debug mode)');
        return;
      }

      // Check for updates
      final hasUpdate = await _shorebirdService.checkForUpdate();

      if (hasUpdate && mounted && !_hasShownUpdateDialog) {
        _hasShownUpdateDialog = true;

        // Show update dialog after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _showUpdateDialog();
          }
        });
      }
    } catch (e) {
      print('⚠️ UpdateChecker: Error checking for updates: $e');
    }
  }

  void _showUpdateDialog() {
    ShorebirdService.showUpdateDialog(
      context,
      onUpdate: () async {
        Navigator.of(context).pop();
        ShorebirdService.showDownloadingDialog(context);

        // Download the update
        final success = await _shorebirdService.downloadUpdate();

        if (mounted) {
          Navigator.of(context).pop();

          if (success) {
            _showRestartDialog();
          } else {
            _showErrorSnackBar();
          }
        }
      },
      onLater: () {
        Navigator.of(context).pop();
        _hasShownUpdateDialog = false; // Allow showing again later
      },
    );
  }

  void _showRestartDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;

        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              const SizedBox(width: 12),
              Text(
                'تم تحميل التحديث',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تم تحميل التحديث بنجاح.',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.restart_alt, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'يرجى إعادة تشغيل التطبيق لتطبيق التحديث.',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('حسناً'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text('فشل تحميل التحديث. يرجى المحاولة لاحقاً.')),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
