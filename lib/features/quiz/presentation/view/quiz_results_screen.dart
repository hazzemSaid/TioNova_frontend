// features/quiz/presentation/view/quiz_results_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/features/quiz/data/models/QuizModel.dart';
import 'package:tionova/features/quiz/data/models/UserQuizStatusModel.dart';
import 'package:tionova/features/quiz/presentation/bloc/quizcubit.dart';
import 'package:tionova/features/quiz/presentation/bloc/quizstate.dart';

class QuizResultsScreen extends StatefulWidget {
  final QuizModel quiz;
  final List<String?> userAnswers;
  final String token;
  final String chapterId;

  const QuizResultsScreen({
    Key? key,
    required this.quiz,
    required this.userAnswers,
    required this.token,
    required this.chapterId,
  }) : super(key: key);

  @override
  State<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends State<QuizResultsScreen> {
  Attempt? _attempt;

  void _showQuestionDetails({
    required String question,
    required List<String> options,
    required String selectedLetter,
    required String correctLetter,
    required bool isCorrect,
    String? explanation,
  }) {
    final int selectedIdx = selectedLetter.isNotEmpty
        ? (selectedLetter.toLowerCase().codeUnitAt(0) - 'a'.codeUnitAt(0))
        : -1;
    final int correctIdx = correctLetter.isNotEmpty
        ? (correctLetter.toLowerCase().codeUnitAt(0) - 'a'.codeUnitAt(0))
        : -1;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      color: isCorrect ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        question,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...options.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final text = entry.value;
                  final bool isSelected = idx == selectedIdx;
                  final bool isRight = idx == correctIdx;
                  Color borderColor = const Color(0xFF3A3A3C);
                  Color bgColor = const Color(0xFF2C2C2E);
                  Color textColor = Colors.white;
                  IconData? icon;
                  Color? iconColor;

                  if (isRight) {
                    borderColor = Colors.green.withOpacity(0.4);
                    bgColor = Colors.green.withOpacity(0.08);
                  }
                  if (isSelected && !isRight) {
                    borderColor = Colors.red.withOpacity(0.4);
                    bgColor = Colors.red.withOpacity(0.08);
                  }
                  if (isSelected) {
                    icon = isRight ? Icons.check : Icons.close;
                    iconColor = isRight ? Colors.green : Colors.red;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor, width: 1),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: iconColor, size: 18),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            text,
                            style: TextStyle(color: textColor, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                if ((explanation ?? '').isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Explanation',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    explanation!,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _submitToBackend();
  }

  void _submitToBackend() {
    final answersPayload = <Map<String, dynamic>>[];
    for (var i = 0; i < widget.quiz.questions.length; i++) {
      final question = widget.quiz.questions[i];
      final answer = widget.userAnswers[i] ?? 'z';
      answersPayload.add({'questionId': question.id, 'answer': answer});
    }

    final body = {'answers': answersPayload};

    context.read<QuizCubit>().setuserquizstatus(
      token: widget.token,
      quizId: widget.quiz.id,
      body: body,
      chapterId: widget.chapterId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: BlocConsumer<QuizCubit, QuizState>(
          listener: (context, state) {
            if (state is UserQuizStatusSuccess) {
              setState(() {
                _attempt = state.status.attempts.isNotEmpty
                    ? state.status.attempts.last
                    : null;
              });
            }
          },
          builder: (context, state) {
            if (state is UserQuizStatusLoading || _attempt == null) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFE9500)),
              );
            }

            final attempt = _attempt!;
            final percentage = attempt.degree;
            final isPassed = attempt.state.toLowerCase() == 'passed';
            // Map questionId -> question model for enriching graded answers
            final Map<String, dynamic> questionById = {
              for (final q in widget.quiz.questions) q.id: q,
            };

            return CustomScrollView(
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
                          '${attempt.correct} / ${attempt.totalQuestions}',
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
                      final answer = attempt.answers[index];
                      final isCorrect = answer.isCorrect;
                      final correctAnswer = answer.correctAnswer.toLowerCase();

                      // Resolve question details by id when available
                      String resolvedQuestionText = answer.question;
                      List<String> resolvedOptions = answer.options;
                      if ((answer.questionId ?? '').isNotEmpty) {
                        final q = questionById[answer.questionId!];
                        if (q != null) {
                          resolvedQuestionText = q.question as String;
                          resolvedOptions = (q.options as List).cast<String>();
                        }
                      }

                      // Selected option text (fallback to letter when options unknown)
                      String selectedOptionText = answer.selectedOption;
                      if (resolvedOptions.isNotEmpty &&
                          answer.selectedOption.isNotEmpty) {
                        final optionIndex =
                            answer.selectedOption.toLowerCase().codeUnitAt(0) -
                            'a'.codeUnitAt(0);
                        if (optionIndex >= 0 &&
                            optionIndex < resolvedOptions.length) {
                          selectedOptionText = resolvedOptions[optionIndex];
                        }
                      }

                      // Get the full text of the correct option
                      String correctOptionText = '';
                      if (correctAnswer.isNotEmpty &&
                          resolvedOptions.isNotEmpty) {
                        final correctIndex =
                            correctAnswer.codeUnitAt(0) - 'a'.codeUnitAt(0);
                        if (correctIndex >= 0 &&
                            correctIndex < resolvedOptions.length) {
                          correctOptionText = resolvedOptions[correctIndex];
                        }
                      }

                      return InkWell(
                        onTap: () {
                          _showQuestionDetails(
                            question: resolvedQuestionText,
                            options: resolvedOptions,
                            selectedLetter: answer.selectedOption,
                            correctLetter: answer.correctAnswer,
                            isCorrect: isCorrect,
                            explanation: answer.explanation,
                          );
                        },
                        child: Container(
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
                                      color: isCorrect
                                          ? Colors.green
                                          : Colors.red,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Question ${index + 1}: $resolvedQuestionText',
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
                                              (selectedOptionText.isEmpty ||
                                                      selectedOptionText == 'z')
                                                  ? 'Not answered'
                                                  : selectedOptionText,
                                              style: TextStyle(
                                                color: isCorrect
                                                    ? Colors.green
                                                    : Colors.red,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 15,
                                              ),
                                            ),
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
                                        ],

                                        // Explanation (if present)
                                        if ((answer.explanation ?? '')
                                            .isNotEmpty) ...[
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
                                            answer.explanation!,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }, childCount: attempt.answers.length),
                  ),
                ),

                // Bottom padding
                const SliverToBoxAdapter(child: SizedBox(height: 24.0)),
              ],
            );
          },
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
