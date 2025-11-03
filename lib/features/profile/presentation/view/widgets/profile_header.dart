import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final VoidCallback? onThemeToggle;

  const ProfileHeader({Key? key, this.onThemeToggle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile',
                style:
                    textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onBackground,
                      fontWeight: FontWeight.w600,
                    ) ??
                    TextStyle(
                      color: colorScheme.onBackground,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your study journey',
                style:
                    textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ) ??
                    TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
              ),
            ],
          ),
          GestureDetector(
            onTap: onThemeToggle,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.light_mode_outlined,
                color: colorScheme.onSurface,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
