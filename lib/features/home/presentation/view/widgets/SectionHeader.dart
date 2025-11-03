import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String actionText;
  final IconData actionIcon;

  const SectionHeader({
    super.key,
    required this.title,
    required this.actionText,
    required this.actionIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final screenSize = MediaQuery.sizeOf(context);
    final isTablet = screenSize.width > 600;
    final double titleSize = isTablet ? 20.0 : screenSize.width * 0.045;
    final double actionTextSize = isTablet ? 16.0 : screenSize.width * 0.035;
    final double iconSize = isTablet ? 20.0 : screenSize.width * 0.04;
    final double spacing = isTablet ? 12.0 : screenSize.width * 0.015;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style:
              textTheme.titleMedium?.copyWith(
                fontSize: titleSize,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ) ??
              TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
        ),
        Row(
          children: [
            if (actionIcon == Icons.access_time) ...[
              Icon(actionIcon, color: colorScheme.secondary, size: iconSize),
              SizedBox(width: spacing / 2),
            ],
            Text(
              actionText,
              style:
                  textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: actionTextSize,
                    fontWeight: FontWeight.w500,
                  ) ??
                  TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: actionTextSize,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            if (actionIcon == Icons.arrow_forward_ios) ...[
              SizedBox(width: spacing / 2),
              Icon(
                actionIcon,
                color: colorScheme.onSurfaceVariant,
                size: isTablet ? 16.0 : screenSize.width * 0.03,
              ),
            ],
          ],
        ),
      ],
    );
  }
}
