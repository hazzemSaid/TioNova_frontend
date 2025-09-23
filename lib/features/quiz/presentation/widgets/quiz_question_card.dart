import 'package:flutter/material.dart';

class QuizQuestionCard extends StatelessWidget {
  final String question;
  final List<String> options;
  final int? selected;
  final void Function(int) onSelect;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final int current;
  final int total;

  const QuizQuestionCard({
    super.key,
    required this.question,
    required this.options,
    required this.selected,
    required this.onSelect,
    required this.onNext,
    required this.onPrevious,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question ${current + 1} of $total',
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          question,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          return ListTile(
            title: Text(
              option,
              style: TextStyle(
                color: selected == index ? Colors.orangeAccent : Colors.white,
              ),
            ),
            leading: Radio<int>(
              value: index,
              groupValue: selected,
              onChanged: (value) => onSelect(index),
              activeColor: Colors.orangeAccent,
            ),
          );
        }).toList(),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: onPrevious,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              child: const Text('Previous'),
            ),
            ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
              ),
              child: const Text('Next'),
            ),
          ],
        ),
      ],
    );
  }
}
