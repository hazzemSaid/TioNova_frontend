import 'package:flutter/material.dart';

class ChapterDetailActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final IconData actionIcon;
  final VoidCallback onAction;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? iconContainerColor;
  final Color? textColor;
  final Color? subtitleColor;
  final bool isLarge;

  const ChapterDetailActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.actionIcon,
    required this.onAction,
    this.isLoading = false,
    this.backgroundColor,
    this.iconColor,
    this.iconContainerColor,
    this.textColor,
    this.subtitleColor,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(isLarge ? 32 : 28),
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isLarge ? 64 : 56,
            height: isLarge ? 64 : 56,
            decoration: BoxDecoration(
              color: iconContainerColor ?? colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor ?? colorScheme.onSurface,
              size: isLarge ? 32 : 28,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              color: textColor ?? colorScheme.onSurface,
              fontSize: isLarge ? 22 : 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(
              color: subtitleColor ?? colorScheme.onSurfaceVariant,
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: isLoading ? null : onAction,
              style: OutlinedButton.styleFrom(
                foregroundColor: textColor ?? colorScheme.onSurface,
                side: BorderSide(
                  color: iconColor ?? colorScheme.outline,
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isLoading ? Icons.hourglass_empty : actionIcon,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    actionLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
