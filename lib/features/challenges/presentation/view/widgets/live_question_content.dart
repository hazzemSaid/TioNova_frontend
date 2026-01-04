import 'package:flutter/material.dart';
import 'package:tionova/features/challenges/presentation/services/challenge_vibration_service.dart';
import 'package:tionova/features/challenges/presentation/view/utils/live_question_theme.dart';
import 'package:tionova/features/challenges/presentation/view/widgets/feedback_state.dart';
import 'package:tionova/features/challenges/presentation/view/widgets/live_question_option_button.dart';
import 'package:tionova/features/challenges/presentation/view/widgets/submit_button.dart';
import 'package:tionova/features/challenges/presentation/view/widgets/waiting_state.dart';

class LiveQuestionContent extends StatelessWidget {
  final Map<String, dynamic> question;
  final bool showingFeedback;
  final bool wasCorrect;
  final String? selectedAnswer;
  final String? correctAnswer;
  final int? currentRank;
  final int totalPlayers;
  final Animation<double> feedbackScaleAnimation;
  final bool isWaitingForOthers;
  final int totalAnsweredPlayers;
  final Animation<Offset> questionSlideAnimation;
  final Animation<double> optionsFadeAnimation;
  final bool hasAnswered;
  final ChallengeVibrationService vibrationService;
  final ValueChanged<String> onAnswerSelected;
  final VoidCallback onSubmit;

  const LiveQuestionContent({
    super.key,
    required this.question,
    required this.showingFeedback,
    required this.wasCorrect,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.currentRank,
    required this.totalPlayers,
    required this.feedbackScaleAnimation,
    required this.isWaitingForOthers,
    required this.totalAnsweredPlayers,
    required this.questionSlideAnimation,
    required this.optionsFadeAnimation,
    required this.hasAnswered,
    required this.vibrationService,
    required this.onAnswerSelected,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    // Show feedback state if all players answered
    if (showingFeedback) {
      return FeedbackState(
        isCorrect: wasCorrect,
        userAnswer: selectedAnswer ?? 'X',
        correctAnswer: correctAnswer ?? '?',
        currentRank: currentRank,
        totalPlayers: totalPlayers,
        scale: feedbackScaleAnimation,
        bg: LiveQuestionTheme.bg,
        cardBg: LiveQuestionTheme.cardBg,
        textPrimary: LiveQuestionTheme.textPrimary,
        textSecondary: LiveQuestionTheme.textSecondary,
        accentGreen: LiveQuestionTheme.green,
        dangerRed: LiveQuestionTheme.red,
      );
    }

    // Show waiting state if user has answered
    if (isWaitingForOthers) {
      return WaitingState(
        totalAnsweredPlayers: totalAnsweredPlayers,
        totalPlayers: totalPlayers,
        selectedAnswer: selectedAnswer,
        cardBg: LiveQuestionTheme.cardBg,
        textPrimary: LiveQuestionTheme.textPrimary,
        textSecondary: LiveQuestionTheme.textSecondary,
        accentGreen: LiveQuestionTheme.green,
      );
    }

    final options = List<String>.from(question['options'] ?? []);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Animated Question Card
          SlideTransition(
            position: questionSlideAnimation,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: LiveQuestionTheme.cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: LiveQuestionTheme.green.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Text(
                question['question'] ?? '',
                style: const TextStyle(
                  color: LiveQuestionTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Animated Options
          FadeTransition(
            opacity: optionsFadeAnimation,
            child: Column(
              children: [
                ...options.asMap().entries.map((entry) {
                  final optionLabel = String.fromCharCode(
                    65 + entry.key,
                  ); // A, B, C, D
                  final optionText = entry.value;
                  final isSelected = selectedAnswer == optionLabel;

                  return LiveQuestionOptionButton(
                    label: optionLabel,
                    text: optionText,
                    isSelected: isSelected,
                    onTap: hasAnswered
                        ? null
                        : () {
                            vibrationService.selection();
                            onAnswerSelected(optionLabel);
                          },
                    cardBg: LiveQuestionTheme.cardBg,
                    textPrimary: LiveQuestionTheme.textPrimary,
                    textSecondary: LiveQuestionTheme.textSecondary,
                    accentGreen: LiveQuestionTheme.green,
                  );
                }),
                const SizedBox(height: 24),
                SubmitButton(
                  canSubmit: selectedAnswer != null && !hasAnswered,
                  hasAnswered: hasAnswered,
                  onSubmit: onSubmit,
                  cardBg: LiveQuestionTheme.cardBg,
                  textSecondary: LiveQuestionTheme.textSecondary,
                  accentGreen: LiveQuestionTheme.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
