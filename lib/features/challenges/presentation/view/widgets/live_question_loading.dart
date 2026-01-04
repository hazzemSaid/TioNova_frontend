import 'package:flutter/material.dart';
import 'package:tionova/features/challenges/presentation/view/utils/live_question_theme.dart';

class LiveQuestionLoading extends StatelessWidget {
  const LiveQuestionLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(color: LiveQuestionTheme.green),
          SizedBox(height: 16),
          Text(
            'Loading question...',
            style: TextStyle(
              color: LiveQuestionTheme.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
