import 'package:flutter/material.dart';

class ChallengeTimerBar extends StatelessWidget {
  final int timeRemaining;
  final int durationSeconds;
  final bool isUrgent;
  final Animation<double>? pulse;

  final Color cardBg;
  final Color textSecondary;
  final Color accentGreen;
  final Color dangerRed;

  const ChallengeTimerBar({
    super.key,
    required this.timeRemaining,
    required this.durationSeconds,
    required this.isUrgent,
    this.pulse,
    required this.cardBg,
    required this.textSecondary,
    required this.accentGreen,
    required this.dangerRed,
  });

  @override
  Widget build(BuildContext context) {
    final timerProgress = (timeRemaining / durationSeconds).clamp(0.0, 1.0);

    Widget content = Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isUrgent
            ? dangerRed.withOpacity(0.15)
            : accentGreen.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUrgent
              ? dangerRed.withOpacity(0.3)
              : accentGreen.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.timer_outlined,
            color: isUrgent ? dangerRed : accentGreen,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${timeRemaining}s',
                      style: TextStyle(
                        color: isUrgent ? dangerRed : accentGreen,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'remaining',
                      style: TextStyle(color: textSecondary, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: timerProgress,
                    backgroundColor: cardBg,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isUrgent ? dangerRed : accentGreen,
                    ),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (pulse != null && isUrgent) {
      content = AnimatedBuilder(
        animation: pulse!,
        builder: (context, child) {
          return Transform.scale(scale: pulse!.value, child: child);
        },
        child: content,
      );
    }

    return content;
  }
}
