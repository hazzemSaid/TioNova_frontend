import 'package:flutter/material.dart';

class StudyStats extends StatelessWidget {
  final int myFoldersCount;
  final int totalChaptersCount;

  const StudyStats({
    super.key,
    required this.myFoldersCount,
    required this.totalChaptersCount,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Study Stats',
            style: textTheme.titleLarge?.copyWith(color: colorScheme.onPrimary),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                myFoldersCount.toString(),
                'My Folders',
                textTheme,
                colorScheme,
              ),
              _buildStatItem(
                totalChaptersCount.toString(),
                'Total Chapters',
                textTheme,
                colorScheme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String count,
    String label,
    dynamic textTheme,
    dynamic colorScheme,
  ) {
    return Column(
      children: [
        Text(
          count,
          style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
        ),
      ],
    );
  }
}

class StudyStatItem extends StatelessWidget {
  final String count;
  final String label;

  const StudyStatItem({Key? key, required this.count, required this.label})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          count,
          style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
        ),
      ],
    );
  }
}
