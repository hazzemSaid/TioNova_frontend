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
    final theme = Theme.of(context);
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$questions Questions',
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(timeLimit, style: const TextStyle(color: Colors.white70)),
                Text(
                  difficulty,
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
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
