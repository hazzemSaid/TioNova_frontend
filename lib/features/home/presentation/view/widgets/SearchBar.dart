import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final screenSize = MediaQuery.sizeOf(context);
    final isTablet = screenSize.width > 600;

    // Responsive dimensions
    final double height = isTablet ? 56.0 : 48.0;
    final double fontSize = isTablet ? 18.0 : 16.0;
    final double iconSize = isTablet ? 24.0 : 20.0;
    final double borderRadius = isTablet ? 16.0 : 12.0;
    final EdgeInsets contentPadding = isTablet
        ? const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0)
        : const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: TextField(
        style:
            textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontSize: fontSize,
              height: 1.2,
            ) ??
            TextStyle(
              color: colorScheme.onSurface,
              fontSize: fontSize,
              height: 1.2,
            ),
        decoration: InputDecoration(
          hintText: 'Search folders, chapters...',
          hintStyle:
              textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: fontSize,
              ) ??
              TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: fontSize,
              ),
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.search,
            color: colorScheme.onSurfaceVariant,
            size: iconSize,
          ),
          contentPadding: contentPadding,
          filled: true,
          fillColor: Colors.transparent,
          isDense: true,
        ),
      ),
    );
  }
}
