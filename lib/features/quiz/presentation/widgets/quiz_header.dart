import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuizHeader extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final String? timer;

  const QuizHeader({super.key, this.title, this.subtitle, this.timer});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        if (title != null)
          Text(
            title!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          )
        else
          const Text(
            'Quiz',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        if (timer != null)
          Text(
            timer!,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          )
        else
          const SizedBox(width: 48), // Placeholder for alignment
      ],
    );
  }
}
