/// Enum representing the type of navigation context
enum NavigationContextType {
  /// Chapter accessed through folder hierarchy (/folders/:folderId/chapters/:chapterId)
  folderBased,

  /// Chapter accessed directly (/chapters/:chapterId)
  standalone,
}
