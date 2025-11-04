import 'package:flutter/material.dart';

class QuizResultCard extends StatelessWidget {
  final List<Map<String, dynamic>> questions;
  final List<int?> answers;

  const QuizResultCard({
    super.key,
    required this.questions,
    required this.answers,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    int correctAnswers = 0;
    for (int i = 0; i < questions.length; i++) {
      if (answers[i] == questions[i]['correct']) {
        correctAnswers++;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quiz Results',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Score: ${(correctAnswers / questions.length * 100).toStringAsFixed(0)}%',
          style: TextStyle(color: colorScheme.primary, fontSize: 16),
        ),
        const SizedBox(height: 16),
        ...questions.asMap().entries.map((entry) {
          final index = entry.key;
          final question = entry.value;
          return ListTile(
            title: Text(
              question['question'],
              style: TextStyle(color: colorScheme.onSurface),
            ),
            subtitle: Text(
              answers[index] == question['correct'] ? 'Correct' : 'Incorrect',
              style: TextStyle(
                color: answers[index] == question['correct']
                    ? colorScheme.tertiary
                    : colorScheme.error,
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
