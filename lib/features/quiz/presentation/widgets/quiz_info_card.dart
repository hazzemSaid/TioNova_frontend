import 'package:flutter/material.dart';

class QuizInfoCard extends StatelessWidget {
  final String title;
  final String description;
  final int questions;
  final String timeLimit;
  final String difficulty;
  final VoidCallback onStart;

  const QuizInfoCard({
    super.key,
    required this.title,
    required this.description,
    required this.questions,
    required this.timeLimit,
    required this.difficulty,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$questions Questions',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                Text(
                  timeLimit,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                Text(difficulty, style: TextStyle(color: colorScheme.primary)),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Start Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}
