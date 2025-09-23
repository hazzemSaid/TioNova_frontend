import 'package:flutter/material.dart';

class QuizReviewAnswers extends StatelessWidget {
  final List<Map<String, dynamic>> questions;
  final List<int?> answers;
  final VoidCallback onSubmit;
  final VoidCallback onContinue;

  const QuizReviewAnswers({
    super.key,
    required this.questions,
    required this.answers,
    required this.onSubmit,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Review Answers',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...questions.asMap().entries.map((entry) {
          final index = entry.key;
          final question = entry.value;
          return ListTile(
            title: Text(
              question['question'],
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              answers[index] != null
                  ? question['options'][answers[index]!]
                  : 'No answer',
              style: const TextStyle(color: Colors.orangeAccent),
            ),
          );
        }).toList(),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              child: const Text('Continue Answering'),
            ),
            ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
              ),
              child: const Text('Submit Quiz'),
            ),
          ],
        ),
      ],
    );
  }
}
