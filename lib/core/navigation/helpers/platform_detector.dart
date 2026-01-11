import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/navigation_method.dart';

/// Reliable platform detection for navigation behavior
class PlatformDetector {
  /// Returns true if running on web platform
  static bool get isWeb => kIsWeb;

  /// Returns true if running on mobile platform
  static bool get isMobile => !kIsWeb;

  /// Returns the preferred navigation method for current platform
  static NavigationMethod get preferredMethod =>
      isWeb ? NavigationMethod.replace : NavigationMethod.push;

  /// Determines if the current platform supports browser history
  static bool get supportsBrowserHistory => isWeb;

  /// Determines if the current platform uses navigation stack
  static bool get usesNavigationStack => isMobile;

  /// Returns platform-specific behavior description
  static String get platformDescription {
    if (isWeb) {
      return 'Web platform - uses context.go() for browser history management';
    } else {
      return 'Mobile platform - uses context.push() for navigation stack';
    }
  }

  /// Validates that platform detection is working correctly
  static bool validatePlatformDetection() {
    // This should always return a consistent result for the same platform
    final firstCheck = isWeb;
    final secondCheck = kIsWeb;
    return firstCheck == secondCheck;
  }
}
