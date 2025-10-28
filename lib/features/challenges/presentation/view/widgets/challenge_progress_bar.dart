import 'package:flutter/material.dart';

class ChallengeProgressBar extends StatelessWidget {
  final int currentIndex; // zero-based
  final int totalQuestions;

  final Color cardBg;
  final Color textPrimary;
  final Color accentGreen;

  const ChallengeProgressBar({
    super.key,
    required this.currentIndex,
    required this.totalQuestions,
    required this.cardBg,
    required this.textPrimary,
    required this.accentGreen,
  });

  @override
  Widget build(BuildContext context) {
    final total = totalQuestions > 0 ? totalQuestions : 1;
    final progress = ((currentIndex + 1) / total).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: cardBg,
                valueColor: AlwaysStoppedAnimation<Color>(accentGreen),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${(progress * 100).clamp(0, 100).toInt()}%',
            style: TextStyle(
              color: textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
