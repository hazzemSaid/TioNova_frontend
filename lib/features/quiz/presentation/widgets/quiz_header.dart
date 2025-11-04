import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuizHeader extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final String? timer;

  const QuizHeader({super.key, this.title, this.subtitle, this.timer});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        if (title != null)
          Text(
            title!,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          )
        else
          Text(
            'Quiz',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        if (timer != null)
          Text(
            timer!,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16),
          )
        else
          const SizedBox(width: 48), // Placeholder for alignment
      ],
    );
  }
}
