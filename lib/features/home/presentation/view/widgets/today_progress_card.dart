import 'package:flutter/material.dart';
import 'package:tionova/features/home/presentation/view/widgets/metric_item.dart';

class TodayProgressCard extends StatelessWidget {
  final Map<String, dynamic> progress;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const TodayProgressCard({
    super.key,
    required this.progress,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final total = progress['total'] as int;
    final completed = progress['completed'] as int;
    // Prevent division by zero - if total is 0, progress is 0
    final progressPercent = total > 0 ? completed / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Today's Progress",
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Text(
                '${progress['completed']}/${progress['total']}',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progressPercent,
              minHeight: 8,
              backgroundColor: colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
          const SizedBox(height: 16),
          // Metrics Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              MetricItem(
                value: '${progress['chapters']}',
                label: 'Chapters',
                icon: Icons.menu_book,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              MetricItem(
                value: '${progress['quizzes']}',
                label: 'Quizzes',
                icon: Icons.quiz,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              MetricItem(
                value: '${progress['studyTime']}m',
                label: 'Study Time',
                icon: Icons.access_time,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
