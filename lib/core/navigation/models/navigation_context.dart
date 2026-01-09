import 'navigation_context_type.dart';

/// Represents the navigation context for chapter-related screens
class NavigationContext {
  final NavigationContextType type;
  final String chapterId;
  final String? folderId;

  const NavigationContext._({
    required this.type,
    required this.chapterId,
    this.folderId,
  });

  /// Creates a folder-based navigation context
  factory NavigationContext.folderBased({
    required String folderId,
    required String chapterId,
  }) {
    return NavigationContext._(
      type: NavigationContextType.folderBased,
      folderId: folderId,
      chapterId: chapterId,
    );
  }

  /// Creates a standalone navigation context
  factory NavigationContext.standalone({required String chapterId}) {
    return NavigationContext._(
      type: NavigationContextType.standalone,
      chapterId: chapterId,
    );
  }

  /// Returns true if this is a folder-based context
  bool get isFolderBased => type == NavigationContextType.folderBased;

  /// Returns true if this is a standalone context
  bool get isStandalone => type == NavigationContextType.standalone;

  @override
  String toString() {
    return 'NavigationContext(type: $type, chapterId: $chapterId, folderId: $folderId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NavigationContext &&
        other.type == type &&
        other.chapterId == chapterId &&
        other.folderId == folderId;
  }

  @override
  int get hashCode => Object.hash(type, chapterId, folderId);
}
