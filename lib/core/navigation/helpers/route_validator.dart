/// Validation result for route parameters
class ValidationResult {
  final bool isValid;
  final String? error;
  final String? sanitizedFolderId;
  final String? sanitizedChapterId;

  const ValidationResult({
    required this.isValid,
    this.error,
    this.sanitizedFolderId,
    this.sanitizedChapterId,
  });

  factory ValidationResult.valid({
    required String sanitizedFolderId,
    required String sanitizedChapterId,
  }) {
    return ValidationResult(
      isValid: true,
      sanitizedFolderId: sanitizedFolderId,
      sanitizedChapterId: sanitizedChapterId,
    );
  }

  factory ValidationResult.invalid(String error) {
    return ValidationResult(isValid: false, error: error);
  }
}

/// Route validation utilities
class RouteValidator {
  /// Validates chapter route parameters
  static ValidationResult validateChapterRoute(
    String folderId,
    String chapterId,
  ) {
    final sanitizedFolderId = sanitizeFolderId(folderId);
    final sanitizedChapterId = sanitizeChapterId(chapterId);

    if (sanitizedFolderId == null) {
      return ValidationResult.invalid('Invalid or empty folderId: $folderId');
    }

    if (sanitizedChapterId == null) {
      return ValidationResult.invalid('Invalid or empty chapterId: $chapterId');
    }

    return ValidationResult.valid(
      sanitizedFolderId: sanitizedFolderId,
      sanitizedChapterId: sanitizedChapterId,
    );
  }

  /// Sanitizes and validates folder ID
  static String? sanitizeFolderId(String? folderId) {
    if (folderId == null) return null;

    final sanitized = folderId.trim();
    if (sanitized.isEmpty) return null;

    // Additional validation rules can be added here
    // For example, checking for valid characters, length limits, etc.
    if (sanitized.contains(RegExp(r'[<>:"/\\|?*]'))) {
      return null; // Contains invalid characters
    }

    return sanitized;
  }

  /// Sanitizes and validates chapter ID
  static String? sanitizeChapterId(String? chapterId) {
    if (chapterId == null) return null;

    final sanitized = chapterId.trim();
    if (sanitized.isEmpty) return null;

    // Additional validation rules can be added here
    if (sanitized.contains(RegExp(r'[<>:"/\\|?*]'))) {
      return null; // Contains invalid characters
    }

    return sanitized;
  }

  /// Validates that a parameter is safe for URL usage
  static bool isUrlSafe(String parameter) {
    // Check for URL-unsafe characters
    final urlUnsafePattern = RegExp(r'[<>:"/\\|?*\s]');
    return !urlUnsafePattern.hasMatch(parameter);
  }

  /// Validates parameter length
  static bool isValidLength(String parameter, {int maxLength = 100}) {
    return parameter.length <= maxLength && parameter.isNotEmpty;
  }

  /// Comprehensive parameter validation
  static bool isValidParameter(String? parameter) {
    if (parameter == null) return false;

    final sanitized = parameter.trim();
    return sanitized.isNotEmpty &&
        isUrlSafe(sanitized) &&
        isValidLength(sanitized);
  }
}
