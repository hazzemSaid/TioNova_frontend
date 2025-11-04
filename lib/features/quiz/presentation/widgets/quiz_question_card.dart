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
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question ${current + 1} of $total',
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          question,
          style: TextStyle(
            color: colorScheme.onSurface,
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
                color: selected == index
                    ? colorScheme.primary
                    : colorScheme.onSurface,
              ),
            ),
            leading: Radio<int>(
              value: index,
              groupValue: selected,
              onChanged: (value) => onSelect(index),
              activeColor: colorScheme.primary,
            ),
          );
        }),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: onPrevious,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
              child: const Text('Previous'),
            ),
            ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
              ),
              child: const Text('Next'),
            ),
          ],
        ),
      ],
    );
  }
}
