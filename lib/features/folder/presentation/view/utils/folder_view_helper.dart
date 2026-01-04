import 'package:flutter/material.dart';
import 'package:tionova/utils/static.dart';

class FolderViewHelper {
  static const defaultColors = Static.defaultColors;
  static const defaultIcons = Static.defaultIcons;

  /// Get icon from stored index
  static IconData getIconFromIndex(String? iconIndex) {
    if (iconIndex == null) return Icons.folder_outlined;

    try {
      final index = int.parse(iconIndex);
      if (index >= 0 && index < defaultIcons.length) {
        return defaultIcons[index];
      }
    } catch (e) {
      // If parsing fails, return default
    }
    return Icons.folder_outlined;
  }

  /// Get color from stored hex string
  static Color getColorFromHex(String? colorHex) {
    if (colorHex == null) return defaultColors[0];

    try {
      // Remove # if present and ensure it's 8 characters for ARGB
      String cleanHex = colorHex.replaceAll('#', '');
      if (cleanHex.length == 6) {
        cleanHex = 'FF$cleanHex'; // Add alpha
      }
      return Color(int.parse(cleanHex, radix: 16));
    } catch (e) {
      // If parsing fails, return default
    }
    return defaultColors[0];
  }
}
