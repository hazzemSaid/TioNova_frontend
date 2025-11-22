import 'package:flutter/material.dart';

/// Helper widget to build action buttons for chapters
class ChapterActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isTablet;

  const ChapterActionButton({
    super.key,
    required this.label,
    required this.icon,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 12 : 10,
        vertical: isTablet ? 8 : 7,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: colorScheme.onSurface.withOpacity(0.8),
            size: isTablet ? 15 : 14,
          ),
          SizedBox(width: isTablet ? 6 : 5),
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.9),
              fontSize: isTablet ? 12 : 11.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
