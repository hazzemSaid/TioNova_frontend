import 'package:flutter/material.dart';
import 'navigation_context_type.dart';

/// Enhanced navigation context model for context management
class NavigationContext {
  final NavigationContextType type;
  final String chapterId;
  final String? folderId;
  final String? folderTitle;
  final Color? folderColor;
  final String? folderOwnerId;
  final Map<String, dynamic> additionalData;

  const NavigationContext._({
    required this.type,
    required this.chapterId,
    this.folderId,
    this.folderTitle,
    this.folderColor,
    this.folderOwnerId,
    this.additionalData = const {},
  });

  /// Creates a folder-based navigation context
  factory NavigationContext.folderBased({
    required String folderId,
    required String chapterId,
    String? folderTitle,
    Color? folderColor,
    String? folderOwnerId,
    Map<String, dynamic>? additionalData,
  }) {
    return NavigationContext._(
      type: NavigationContextType.folderBased,
      folderId: folderId,
      chapterId: chapterId,
      folderTitle: folderTitle,
      folderColor: folderColor,
      folderOwnerId: folderOwnerId,
      additionalData: additionalData ?? {},
    );
  }

  /// Creates a standalone navigation context
  factory NavigationContext.standalone({
    required String chapterId,
    Map<String, dynamic>? additionalData,
  }) {
    return NavigationContext._(
      type: NavigationContextType.standalone,
      chapterId: chapterId,
      additionalData: additionalData ?? {},
    );
  }

  /// Returns true if this is a folder-based context
  bool get isFolderBased => type == NavigationContextType.folderBased;

  /// Returns true if this is a standalone context
  bool get isStandalone => type == NavigationContextType.standalone;

  /// Validation methods
  bool get isValid =>
      chapterId.trim().isNotEmpty &&
      (isStandalone || (isFolderBased && folderId?.trim().isNotEmpty == true));

  bool get hasCompleteContext =>
      isValid && (isStandalone || (isFolderBased && folderTitle != null));

  /// Creates a copy with updated values
  NavigationContext copyWith({
    NavigationContextType? type,
    String? chapterId,
    String? folderId,
    String? folderTitle,
    Color? folderColor,
    String? folderOwnerId,
    Map<String, dynamic>? additionalData,
  }) {
    return NavigationContext._(
      type: type ?? this.type,
      chapterId: chapterId ?? this.chapterId,
      folderId: folderId ?? this.folderId,
      folderTitle: folderTitle ?? this.folderTitle,
      folderColor: folderColor ?? this.folderColor,
      folderOwnerId: folderOwnerId ?? this.folderOwnerId,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  /// Converts to extra data map for GoRouter
  Map<String, dynamic> toExtraData() {
    final extra = Map<String, dynamic>.from(additionalData);

    if (folderTitle != null) extra['folderTitle'] = folderTitle;
    if (folderColor != null) extra['folderColor'] = folderColor;
    if (folderOwnerId != null) extra['folderOwnerId'] = folderOwnerId;
    if (folderId != null) extra['folderId'] = folderId;

    return extra;
  }

  @override
  String toString() {
    return 'NavigationContext(type: $type, chapterId: $chapterId, folderId: $folderId, folderTitle: $folderTitle, isValid: $isValid)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NavigationContext &&
        other.type == type &&
        other.chapterId == chapterId &&
        other.folderId == folderId &&
        other.folderTitle == folderTitle &&
        other.folderColor == folderColor &&
        other.folderOwnerId == folderOwnerId;
  }

  @override
  int get hashCode => Object.hash(
    type,
    chapterId,
    folderId,
    folderTitle,
    folderColor,
    folderOwnerId,
  );
}
