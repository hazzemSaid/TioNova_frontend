/// Utility for consistent URL construction
class NavigationRouteBuilder {
  /// Constructs chapter detail route with folder context
  static String chapterDetailRoute(String folderId, String chapterId) {
    return validateAndBuildRoute(folderId, chapterId);
  }

  /// Constructs chapter sub-page route with folder context
  static String chapterSubpageRoute(
    String folderId,
    String chapterId,
    String subpage,
  ) {
    return validateAndBuildRoute(folderId, chapterId, subpage);
  }

  /// Validates parameters and builds hierarchical route
  static String validateAndBuildRoute(
    String folderId,
    String chapterId, [
    String? subpage,
  ]) {
    // Validate that both folderId and chapterId are non-empty
    if (folderId.trim().isEmpty || chapterId.trim().isEmpty) {
      throw ArgumentError(
        'Both folderId and chapterId must be non-empty for hierarchical URLs',
      );
    }

    final basePath = '/folders/$folderId/chapters/$chapterId';

    if (subpage != null && subpage.trim().isNotEmpty) {
      return '$basePath/$subpage';
    }

    return basePath;
  }

  /// Constructs standalone chapter route (without folder context)
  static String standaloneChapterRoute(String chapterId, [String? subpage]) {
    if (chapterId.trim().isEmpty) {
      throw ArgumentError('ChapterId must be non-empty');
    }

    final basePath = '/chapters/$chapterId';

    if (subpage != null && subpage.trim().isNotEmpty) {
      return '$basePath/$subpage';
    }

    return basePath;
  }

  /// Validates individual route parameters
  static bool isValidParameter(String? parameter) {
    return parameter != null && parameter.trim().isNotEmpty;
  }

  /// Sanitizes route parameters by trimming whitespace
  static String sanitizeParameter(String parameter) {
    return parameter.trim();
  }

  /// Builds route with validation and sanitization
  static String buildSafeRoute(
    String folderId,
    String chapterId, [
    String? subpage,
  ]) {
    final sanitizedFolderId = sanitizeParameter(folderId);
    final sanitizedChapterId = sanitizeParameter(chapterId);
    final sanitizedSubpage = subpage != null
        ? sanitizeParameter(subpage)
        : null;

    return validateAndBuildRoute(
      sanitizedFolderId,
      sanitizedChapterId,
      sanitizedSubpage,
    );
  }
}
