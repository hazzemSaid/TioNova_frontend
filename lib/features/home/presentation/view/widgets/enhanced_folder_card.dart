import 'package:flutter/material.dart';

class EnhancedFolderCard extends StatelessWidget {
  final String title;
  final int chapters;
  final String timeAgo;
  final Color color;
  final VoidCallback? onTap;

  const EnhancedFolderCard({
    super.key,
    required this.title,
    required this.chapters,
    required this.timeAgo,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isLarge = screenWidth > 900;

    // Responsive sizing - optimized to prevent overflow
    final cardPadding = isLarge ? 15.0 : (isTablet ? 14.0 : 13.0);
    final iconSize = isLarge ? 56.0 : (isTablet ? 54.0 : 52.0);
    final iconInnerSize = isLarge ? 32.0 : (isTablet ? 31.0 : 30.0);
    final iconRadius = isLarge ? 13.0 : (isTablet ? 12.5 : 12.0);
    final spacing1 = isLarge ? 11.0 : (isTablet ? 10.0 : 9.0);
    final spacing2 = isLarge ? 3.5 : (isTablet ? 3.0 : 2.5);
    final spacing3 = isLarge ? 1.5 : (isTablet ? 1.0 : 0.5);
    final titleFontSize = isLarge ? 15.0 : (isTablet ? 14.5 : 14.0);
    final chapterFontSize = isLarge ? 12.0 : (isTablet ? 11.5 : 11.0);
    final timeFontSize = isLarge ? 10.5 : 10.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
      child: Container(
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
          border: Border.all(color: colorScheme.outline.withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Folder Icon
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(iconRadius),
              ),
              child: Icon(
                Icons.folder_outlined,
                color: color,
                size: iconInnerSize,
              ),
            ),
            SizedBox(height: spacing1),
            Text(
              title,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
                fontSize: titleFontSize,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: spacing2),
            Text(
              '$chapters chapters',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: chapterFontSize,
              ),
            ),
            SizedBox(height: spacing3),
            Text(
              timeAgo,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.outline,
                fontSize: timeFontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
