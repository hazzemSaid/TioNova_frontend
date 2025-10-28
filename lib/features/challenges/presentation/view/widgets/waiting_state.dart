import 'package:flutter/material.dart';

class WaitingState extends StatelessWidget {
  final int totalAnsweredPlayers;
  final int totalPlayers;
  final String? selectedAnswer;

  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentGreen;

  const WaitingState({
    super.key,
    required this.totalAnsweredPlayers,
    required this.totalPlayers,
    required this.selectedAnswer,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Icon(Icons.hourglass_empty, color: accentGreen, size: 64),
                const SizedBox(height: 24),
                Text(
                  'Waiting for other players...',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '$totalAnsweredPlayers/$totalPlayers players answered',
                  style: TextStyle(color: textSecondary, fontSize: 16),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: totalPlayers > 0
                          ? totalAnsweredPlayers / totalPlayers
                          : 0,
                      backgroundColor: cardBg,
                      valueColor: AlwaysStoppedAnimation<Color>(accentGreen),
                      minHeight: 8,
                    ),
                  ),
                ),
                if (selectedAnswer != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: accentGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: accentGreen.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: accentGreen, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Your answer: $selectedAnswer',
                          style: TextStyle(
                            color: accentGreen,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
