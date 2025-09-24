import 'package:flutter/material.dart';
import 'package:tionova/features/quiz/data/models/QuizModel.dart';

class QuizResultsScreen extends StatelessWidget {
  final QuizModel quiz;
  final List<String?> userAnswers;
  final int score;
  final int totalQuestions;
  final List<bool> isCorrectList;

  const QuizResultsScreen({
    Key? key,
    required this.quiz,
    required this.userAnswers,
    required this.score,
    required this.totalQuestions,
    required this.isCorrectList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = (score / totalQuestions * 100).round();
    final isPassed = percentage >= 70;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              backgroundColor: const Color(0xFF1C1C1E),
              title: const Text(
                'Quiz Results',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              pinned: true,
              elevation: 0,
            ),

            // Score Card
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: isPassed
                        ? Colors.green.withOpacity(0.3)
                        : Colors.red.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Your Score',
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$score / $totalQuestions',
                      style: TextStyle(
                        color: isPassed ? Colors.green : Colors.red,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        color: isPassed ? Colors.green : Colors.red,
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isPassed
                          ? 'Congratulations! You passed!'
                          : 'Keep practicing!',
                      style: TextStyle(
                        color: isPassed ? Colors.green : Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Questions List
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final question = quiz.questions[index];
                  final userAnswer = userAnswers[index];
                  final isCorrect = isCorrectList[index];
                  final correctAnswer = question.answer.toLowerCase();

                  // Get the full text of the selected option
                  String? selectedOptionText;
                  if (userAnswer != null && userAnswer.isNotEmpty) {
                    final optionIndex =
                        userAnswer.toLowerCase().codeUnitAt(0) -
                        'a'.codeUnitAt(0);
                    if (optionIndex >= 0 &&
                        optionIndex < question.options.length) {
                      selectedOptionText = question.options[optionIndex];
                    }
                  }

                  // Get the full text of the correct option
                  String correctOptionText = '';
                  if (correctAnswer.isNotEmpty) {
                    final correctIndex =
                        correctAnswer.codeUnitAt(0) - 'a'.codeUnitAt(0);
                    if (correctIndex >= 0 &&
                        correctIndex < question.options.length) {
                      correctOptionText = question.options[correctIndex];
                    }
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: isCorrect
                            ? Colors.green.withOpacity(0.3)
                            : Colors.red.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question and status
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isCorrect
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                isCorrect ? Icons.check : Icons.close,
                                color: isCorrect ? Colors.green : Colors.red,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Question ${index + 1}: ${question.question}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Show user's answer
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Your answer:',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        selectedOptionText ?? 'Not answered',
                                        style: TextStyle(
                                          color: isCorrect
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15,
                                        ),
                                      ),
                                      // Show explanation if answered correctly and explanation exists
                                      if (isCorrect &&
                                          question.explanation != null &&
                                          question.explanation!.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        const Text(
                                          'Explanation:',
                                          style: TextStyle(
                                            color: Colors.blueAccent,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          question.explanation!,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  // Show correct answer if wrong
                                  if (!isCorrect) ...[
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Correct answer:',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      correctOptionText,
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                      ),
                                    ),
                                    // Show explanation if available
                                    if (question.explanation != null &&
                                        question.explanation!.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Explanation:',
                                        style: TextStyle(
                                          color: Colors.blueAccent,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        question.explanation!,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }, childCount: quiz.questions.length),
              ),
            ),

            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 24.0)),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            // Navigate back to the home screen or quiz list
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0A84FF),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          child: const Text(
            'Finish',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
