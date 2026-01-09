import 'package:flutter/material.dart';

class ChapterDetailStatsCard extends StatelessWidget {
  final int passed;
  final int attempted;

  const ChapterDetailStatsCard({
    super.key,
    required this.passed,
    required this.attempted,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.query_stats_rounded,
                color: colorScheme.onSurface,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Your Stats',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildStatItem(
            colorScheme,
            'Success Rate',
            '${attempted > 0 ? ((passed / attempted)).toStringAsFixed(0) : 0}%',
            Icons.trending_up_rounded,
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildStatItem(
            colorScheme,
            'Quizzes Taken',
            attempted.toString(),
            Icons.history_rounded,
            colorScheme.primary,
          ),
          const SizedBox(height: 16),
          _buildStatItem(
            colorScheme,
            'Quizzes Passed',
            passed.toString(),
            Icons.check_circle_outline_rounded,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    ColorScheme colorScheme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
