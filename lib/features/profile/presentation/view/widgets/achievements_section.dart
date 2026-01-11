import 'package:flutter/material.dart';

class Achievement {
  final String title;
  final String description;
  final bool isEarned;
  final String emoji;

  Achievement({
    required this.title,
    required this.description,
    required this.isEarned,
    required this.emoji,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.emoji_events_outlined,
                color: colorScheme.onSurface,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Learning Achievements',
                style:
                    textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ) ??
                    TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Achievements List - Vertically stacked
          ...achievements.map((achievement) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildAchievementCard(context, achievement),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(BuildContext context, Achievement achievement) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final screenWidth = MediaQuery.of(context).size.width;

    return Opacity(
      opacity: 0.5,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight: 120,
          maxHeight: screenWidth < 600 ? 160 : 140,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Emoji Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    achievement.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Achievement Title
              Text(
                achievement.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: screenWidth < 600 ? 13 : 15,
                    ) ??
                    TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: screenWidth < 600 ? 13 : 15,
                      fontWeight: FontWeight.w600,
                    ),
              ),

              const SizedBox(height: 4),

              // Achievement Description
              Text(
                achievement.description,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                      fontSize: screenWidth < 600 ? 10 : 11,
                    ) ??
                    TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.7),
                      fontSize: screenWidth < 600 ? 10 : 11,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
