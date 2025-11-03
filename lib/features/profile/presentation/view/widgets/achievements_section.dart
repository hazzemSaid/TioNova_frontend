import 'package:flutter/material.dart';

class Achievement {
  final String title;
  final String description;
  final bool isEarned;

  Achievement({
    required this.title,
    required this.description,
    required this.isEarned,
  });
}

class AchievementsSection extends StatelessWidget {
  final List<Achievement> achievements;

  const AchievementsSection({Key? key, required this.achievements})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.emoji_events_outlined,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Achievements',
                style:
                    textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ) ??
                    TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Achievements List
          ...achievements.map((achievement) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildAchievementItem(context, achievement),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(BuildContext context, Achievement achievement) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final earnedBackground = colorScheme.secondaryContainer;
    final earnedForeground = colorScheme.onSecondaryContainer;
    final inactiveBackground = colorScheme.surfaceVariant;
    final inactiveForeground = colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: achievement.isEarned ? earnedBackground : inactiveBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Trophy Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: achievement.isEarned
                  ? earnedForeground.withOpacity(0.2)
                  : inactiveForeground.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events_outlined,
              color: achievement.isEarned
                  ? earnedForeground
                  : inactiveForeground.withOpacity(0.7),
              size: 18,
            ),
          ),

          const SizedBox(width: 10),

          // Achievement Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style:
                      textTheme.bodyLarge?.copyWith(
                        color: achievement.isEarned
                            ? earnedForeground
                            : inactiveForeground,
                        fontWeight: FontWeight.w600,
                      ) ??
                      TextStyle(
                        color: achievement.isEarned
                            ? earnedForeground
                            : inactiveForeground,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  achievement.description,
                  style:
                      textTheme.bodySmall?.copyWith(
                        color: achievement.isEarned
                            ? earnedForeground.withOpacity(0.8)
                            : inactiveForeground.withOpacity(0.8),
                      ) ??
                      TextStyle(
                        color: achievement.isEarned
                            ? earnedForeground.withOpacity(0.8)
                            : inactiveForeground.withOpacity(0.8),
                        fontSize: 12,
                      ),
                ),
              ],
            ),
          ),

          // Earned Badge
          if (achievement.isEarned)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Earned',
                style:
                    textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ) ??
                    TextStyle(
                      color: colorScheme.primary,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}
