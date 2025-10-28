import 'package:flutter/material.dart';

class FeedbackState extends StatelessWidget {
  final bool isCorrect;
  final String userAnswer; // 'A'..'D' or 'X' for no answer
  final String correctAnswer; // '?' if unknown
  final int? currentRank;
  final int totalPlayers;
  final Animation<double>? scale;

  final Color bg;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentGreen;
  final Color dangerRed;

  const FeedbackState({
    super.key,
    required this.isCorrect,
    required this.userAnswer,
    required this.correctAnswer,
    required this.currentRank,
    required this.totalPlayers,
    this.scale,
    required this.bg,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentGreen,
    required this.dangerRed,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Result Icon with Hero Animation
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Transform.rotate(
                    angle: (1 - value) * 0.5,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? accentGreen.withOpacity(0.15)
                            : dangerRed.withOpacity(0.15),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (isCorrect ? accentGreen : dangerRed)
                                .withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        color: isCorrect ? accentGreen : dangerRed,
                        size: 80,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Result Text with Fade Animation
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Text(
                    isCorrect
                        ? 'Correct!'
                        : userAnswer == 'X'
                        ? 'Time Out!'
                        : 'Incorrect!',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Answer Info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  if (userAnswer != 'X') ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Your answer: ',
                          style: TextStyle(color: textSecondary, fontSize: 16),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isCorrect ? accentGreen : dangerRed,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            userAnswer,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!isCorrect) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Correct answer: ',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: accentGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              correctAnswer,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ] else ...[
                    Text(
                      'You didn\'t answer in time',
                      style: TextStyle(color: textSecondary, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Correct answer: ',
                          style: TextStyle(color: textSecondary, fontSize: 16),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: accentGreen,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            correctAnswer,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32),

            if (currentRank != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: accentGreen.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.emoji_events, color: accentGreen, size: 32),
                        const SizedBox(width: 12),
                        Text(
                          'Your Rank',
                          style: TextStyle(color: textSecondary, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '#$currentRank',
                      style: TextStyle(
                        color: accentGreen,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'out of $totalPlayers players',
                      style: TextStyle(color: textSecondary, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: accentGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: accentGreen,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Next question loading...',
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
        ),
      ),
    );

    if (scale != null) {
      content = ScaleTransition(scale: scale!, child: content);
    }

    return content;
  }
}
