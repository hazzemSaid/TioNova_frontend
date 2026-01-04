import 'package:flutter/material.dart';
import 'package:tionova/features/challenges/presentation/view/utils/live_question_theme.dart';

class LiveQuestionLeaderboardButton extends StatelessWidget {
  final VoidCallback onTap;

  const LiveQuestionLeaderboardButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: LiveQuestionTheme.cardBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.emoji_events_outlined,
                  color: LiveQuestionTheme.green,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Live Scoreboard',
                  style: TextStyle(
                    color: LiveQuestionTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
