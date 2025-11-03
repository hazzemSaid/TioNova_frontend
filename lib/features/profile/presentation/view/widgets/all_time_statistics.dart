import 'package:flutter/material.dart';

class AllTimeStatistics extends StatelessWidget {
  final int chapters;
  final int quizzes;
  final String studyTime;
  final int achievements;

  const AllTimeStatistics({
    Key? key,
    required this.chapters,
    required this.quizzes,
    required this.studyTime,
    required this.achievements,
  }) : super(key: key);

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
                Icons.analytics_outlined,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'All-Time Statistics',
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

          // First Row
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  '$chapters',
                  'Chapters',
                  Icons.menu_book_outlined,
                  colorScheme.primary,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildStatItem(
                  context,
                  '$quizzes',
                  'Quizzes',
                  Icons.quiz_outlined,
                  colorScheme.tertiary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Second Row
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  studyTime,
                  'Studied',
                  Icons.access_time_outlined,
                  colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildStatItem(
                  context,
                  '$achievements',
                  'Achievements',
                  Icons.emoji_events_outlined,
                  colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color iconColor,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style:
                    textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ) ??
                    TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                label,
                style:
                    textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ) ??
                    TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
