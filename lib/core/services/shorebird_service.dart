import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

/// Service to manage Shorebird Code Push updates
/// Handles checking for updates and applying patches automatically
///
/// HOW IT WORKS WITHOUT GOOGLE PLAY:
/// 1. Distribute initial APK via WhatsApp, Telegram, Email, etc.
/// 2. Users install the APK on their devices
/// 3. Shorebird SDK inside the app checks for patches automatically
/// 4. Updates are downloaded and applied without Google Play
///
/// REQUIREMENTS:
/// - Initial APK must be installed on user's device
/// - App must be built with: shorebird release android
/// - Patches are created with: shorebird patch android
class ShorebirdService {
  static final ShorebirdService _instance = ShorebirdService._internal();
  factory ShorebirdService() => _instance;
  ShorebirdService._internal();

  // Shorebird Updater instance
  final ShorebirdUpdater _updater = ShorebirdUpdater();

  bool _isUpdateAvailable = false;
  bool _isCheckingForUpdate = false;
  String? _currentPatchVersion;
  String? _availablePatchVersion;

  /// Check if an update is available
  bool get isUpdateAvailable => _isUpdateAvailable;

  /// Check if currently checking for updates
  bool get isCheckingForUpdate => _isCheckingForUpdate;

  /// Get current patch version
  String? get currentPatchVersion => _currentPatchVersion;

  /// Get available patch version
  String? get availablePatchVersion => _availablePatchVersion;

  /// Initialize Shorebird and check for updates on app start
  Future<void> initialize() async {
    try {
      print('🚀 ShorebirdService: Initializing...');

      // Check if Shorebird is available (only works in release builds)
      final isAvailable = _updater.isAvailable;

      if (!isAvailable) {
        print(
          'ℹ️ ShorebirdService: Running in debug mode - Shorebird disabled',
        );
        print('ℹ️ To test updates, build with: shorebird release android');
        return;
      }

      print('✅ ShorebirdService: Shorebird SDK available');

      // Get current patch
      try {
        final currentPatch = await _updater.readCurrentPatch();
        _currentPatchVersion = currentPatch?.number.toString();
        print(
          'ℹ️ ShorebirdService: Current patch: ${_currentPatchVersion ?? "none"}',
        );
      } catch (e) {
        print('⚠️ ShorebirdService: Could not get current patch: $e');
      }

      // Check for available updates
      final status = await _updater.checkForUpdate();

      if (status == UpdateStatus.outdated) {
        print('✅ ShorebirdService: New patch available!');
        _isUpdateAvailable = true;
      } else if (status == UpdateStatus.upToDate) {
        print('ℹ️ ShorebirdService: App is up to date');
        _isUpdateAvailable = false;
      } else {
        print('ℹ️ ShorebirdService: Update status: $status');
        _isUpdateAvailable = false;
      }

      print('✅ ShorebirdService: Initialization complete');
    } catch (e) {
      print('⚠️ ShorebirdService: Error during initialization: $e');
      // Don't throw - allow app to continue even if Shorebird fails
    }
  }

  /// Manually check for updates
  Future<bool> checkForUpdate() async {
    if (_isCheckingForUpdate) {
      print('ℹ️ ShorebirdService: Already checking for updates');
      return false;
    }

    try {
      _isCheckingForUpdate = true;
      print('🔍 ShorebirdService: Checking for updates...');

      // Check if Shorebird is available
      final isAvailable = _updater.isAvailable;
      if (!isAvailable) {
        print('ℹ️ ShorebirdService: Shorebird not available (debug mode)');
        return false;
      }

      // Check for new patch
      final status = await _updater.checkForUpdate();

      if (status == UpdateStatus.outdated) {
        print('✅ ShorebirdService: New patch found!');
        _isUpdateAvailable = true;
        return true;
      } else {
        print('ℹ️ ShorebirdService: No updates available (status: $status)');
        _isUpdateAvailable = false;
        return false;
      }
    } catch (e) {
      print('❌ ShorebirdService: Error checking for updates: $e');
      return false;
    } finally {
      _isCheckingForUpdate = false;
    }
  }

  /// Download and install available update
  Future<bool> downloadUpdate() async {
    if (!_isUpdateAvailable) {
      print('ℹ️ ShorebirdService: No update available to download');
      return false;
    }

    try {
      print('⬇️ ShorebirdService: Downloading patch...');

      // Download the patch
      await _updater.update();

      print('✅ ShorebirdService: Patch downloaded successfully');
      print('ℹ️ ShorebirdService: Restart app to apply patch');

      return true;
    } catch (e) {
      print('❌ ShorebirdService: Error downloading update: $e');
      return false;
    }
  }

  /// Check if Shorebird is available (only works in release mode)
  Future<bool> isShorebirdAvailable() async {
    try {
      return _updater.isAvailable;
    } catch (e) {
      return false;
    }
  }

  /// Show update dialog to user
  static void showUpdateDialog(
    BuildContext context, {
    required VoidCallback onUpdate,
    required VoidCallback onLater,
  }) {
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
              Icon(Icons.system_update, color: colorScheme.primary, size: 28),
              const SizedBox(width: 12),
              Text(
                'تحديث متاح',
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
                'يتوفر إصدار جديد من TioNova مع تحسينات وإصلاحات.',
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
                  color: colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'سيتم تطبيق التحديث عند إعادة تشغيل التطبيق.',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: onLater,
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.onSurfaceVariant,
              ),
              child: const Text('لاحقاً'),
            ),
            ElevatedButton(
              onPressed: onUpdate,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('تحديث الآن'),
            ),
          ],
        );
      },
    );
  }

  /// Show downloading dialog
  static void showDownloadingDialog(BuildContext context) {
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                'جارِ تحميل التحديث...',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'يرجى الانتظار',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
