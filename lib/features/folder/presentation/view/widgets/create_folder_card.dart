// features/folder/presentation/view/widgets/create_folder_card.dart
import 'package:flutter/material.dart';
import 'package:tionova/features/folder/presentation/view/widgets/DashedBorderPainter.dart';

class CreateFolderCard extends StatelessWidget {
  final VoidCallback? onTap;

  const CreateFolderCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final screenSize = MediaQuery.sizeOf(context);
    final isTablet = screenSize.width > 600;
    final double padding = isTablet ? 48.0 : 40.0;
    final double horizontalPadding = isTablet ? 32.0 : 24.0;
    final double iconSize = isTablet ? 32.0 : 28.0;
    final double titleSize = isTablet ? 20.0 : 18.0;
    final double subtitleSize = isTablet ? 16.0 : 14.0;
    final double buttonHeight = isTablet ? 52.0 : 44.0;
    final double buttonIconSize = isTablet ? 20.0 : 18.0;
    final double buttonTextSize = isTablet ? 18.0 : 16.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: CustomPaint(
          painter: DashedBorderPainter(
            color: colorScheme.outlineVariant.withOpacity(0.6),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: padding,
              horizontal: horizontalPadding,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: isTablet ? 64 : 56,
                  height: isTablet ? 64 : 56,
                  decoration: BoxDecoration(
                    color: colorScheme.onPrimary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.add,
                    color: colorScheme.onPrimary,
                    size: iconSize,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Create New Folder',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: titleSize,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Organize your study materials into folders',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: subtitleSize,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  height: buttonHeight,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: colorScheme.onPrimary,
                        size: buttonIconSize,
                      ),
                      SizedBox(width: isTablet ? 10 : 8),
                      Text(
                        'New Folder',
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: buttonTextSize,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
