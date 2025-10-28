import 'package:flutter/material.dart';

class ChallengeHeader extends StatelessWidget {
  final String challengeName;
  final int currentIndex; // zero-based
  final int totalQuestions;
  final VoidCallback onExit;

  final Color textPrimary;
  final Color textSecondary;

  const ChallengeHeader({
    super.key,
    required this.challengeName,
    required this.currentIndex,
    required this.totalQuestions,
    required this.onExit,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.close, color: textPrimary),
            onPressed: onExit,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  challengeName,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Question ${currentIndex + 1} of ${totalQuestions > 0 ? totalQuestions : '?'}',
                  style: TextStyle(color: textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
