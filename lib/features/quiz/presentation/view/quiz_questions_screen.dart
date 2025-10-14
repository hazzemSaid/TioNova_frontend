// features/quiz/presentation/view/quiz_questions_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/features/quiz/data/models/QuizModel.dart';
import 'package:tionova/features/quiz/presentation/widgets/quiz_header.dart';
import 'package:tionova/features/quiz/presentation/widgets/quiz_review_answers.dart';

class QuizQuestionsScreen extends StatefulWidget {
  final QuizModel quiz;
  final List<String?>
  answers; // This will store the selected option letters (a, b, c, d)
  final String token;
  final String chapterId;

  const QuizQuestionsScreen({
    super.key,
    required this.quiz,
    required this.answers,
    required this.token,
    required this.chapterId,
  });

  @override
  State<QuizQuestionsScreen> createState() => _QuizQuestionsScreenState();
}

class _QuizQuestionsScreenState extends State<QuizQuestionsScreen> {
  late int currentStep;
  int selectedAnswer = -1; // Changed to non-late and initialized
  bool reviewing = false;
  bool submitted = false;
  late Timer _timer;
  late int _remainingTimeInSeconds;
  static const int quizDurationInMinutes = 1;

  @override
  void initState() {
    super.initState();
    currentStep = 0;
    _remainingTimeInSeconds = quizDurationInMinutes * 60;
    selectedAnswer = _getSelectedAnswerIndex(currentStep);
    print(
      'InitState - Question $currentStep, Selected: $selectedAnswer, Stored answer: ${widget.answers[currentStep]}',
    );
    _startTimer();
  }

  // Helper method to extract letter from option text (e.g., "a) Text" -> "a")
  String? _extractLetterFromOption(String option) {
    final trimmed = option.trim().toLowerCase();
    if (trimmed.isEmpty) return null;

    // Check if it starts with a letter followed by )
    final match = RegExp(r'^([a-d])\s*\)').firstMatch(trimmed);
    if (match != null) {
      return match.group(1);
    }

    return null;
  }

  // Helper method to get the selected answer index from the stored letter
  int _getSelectedAnswerIndex(int questionIndex) {
    final storedAnswer = widget.answers[questionIndex];
    print('Getting answer for question $questionIndex, stored: $storedAnswer');

    if (storedAnswer == null || storedAnswer.isEmpty) {
      print('No stored answer');
      return -1;
    }

    final storedLetter = storedAnswer.toLowerCase().trim();
    print('Looking for letter: "$storedLetter"');

    // Find the option that starts with this letter
    final options = widget.quiz.questions[questionIndex].options;
    for (int i = 0; i < options.length; i++) {
      final optionLetter = _extractLetterFromOption(options[i]);
      print('Option $i: "${options[i]}" -> letter: "$optionLetter"');
      if (optionLetter != null && optionLetter == storedLetter) {
        print('Match found at index $i');
        return i;
      }
    }

    print('No match found, returning -1');
    return -1;
  }

  void _selectAnswer(int index) {
    print('Selecting answer index $index for question $currentStep');
    final option = widget.quiz.questions[currentStep].options[index];
    final letter = _extractLetterFromOption(option);
    print('Extracted letter: $letter from option: $option');

    setState(() {
      selectedAnswer = index;
      widget.answers[currentStep] = letter ?? String.fromCharCode(97 + index);
      print('Stored answer: ${widget.answers[currentStep]}');
    });
  }

  void _nextQuestion() {
    print(
      'Next question - Current: $currentStep, Total: ${widget.quiz.questions.length}',
    );
    if (currentStep < widget.quiz.questions.length - 1) {
      setState(() {
        currentStep++;
        selectedAnswer = _getSelectedAnswerIndex(currentStep);
        print('Moved to question $currentStep, selected: $selectedAnswer');
      });
    } else {
      setState(() {
        reviewing = true;
        currentStep = 0;
        selectedAnswer = -1;
      });
    }
  }

  void _previousQuestion() {
    print('Previous question - Current: $currentStep');
    if (currentStep > 0) {
      setState(() {
        currentStep--;
        print('Moving to question $currentStep');
        selectedAnswer = _getSelectedAnswerIndex(currentStep);
        print('After move - selected: $selectedAnswer');
      });
    }
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingTimeInSeconds <= 1) {
        timer.cancel();
        if (!submitted && mounted) {
          submitted = true;
          _submitQuiz();
        }
      } else {
        if (mounted) {
          setState(() {
            _remainingTimeInSeconds--;
          });
        } else {
          timer.cancel();
        }
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  void _submitQuiz() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    submitted = true;
    context.pushReplacement(
      '/quiz-results',
      extra: {
        'quiz': widget.quiz,
        'userAnswers': widget.answers,
        'token': widget.token,
        'chapterId': widget.chapterId,
        'timeTaken': quizDurationInMinutes * 60 - _remainingTimeInSeconds,
      },
    );
  }

  Widget _buildOption(
    BuildContext context,
    String option,
    bool isSelected,
    bool reviewing,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFFE9500)
                  : const Color(0xFF3A3A3C),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.white70,
                    width: 2.0,
                  ),
                  color: isSelected ? Colors.black : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Building - Question: $currentStep, Selected: $selectedAnswer');

    if (reviewing) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: QuizReviewAnswers(
              questions: widget.quiz.questions
                  .map((q) => {'question': q.question, 'options': q.options})
                  .toList(),
              answers: widget.answers.map((answer) {
                if (answer == null) return null;
                return answer.toLowerCase().codeUnitAt(0) - 'a'.codeUnitAt(0);
              }).toList(),
              onContinue: () {
                setState(() {
                  reviewing = false;
                });
              },
              onSubmit: _submitQuiz,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QuizHeader(
                title:
                    'Question ${currentStep + 1} of ${widget.quiz.questions.length}',
                timer: _formatTime(_remainingTimeInSeconds),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: (currentStep + 1) / widget.quiz.questions.length,
                backgroundColor: const Color(0xFF2C2C2E),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 24),
              Text(
                widget.quiz.questions[currentStep].question,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ...widget.quiz.questions[currentStep].options.asMap().entries.map(
                (entry) {
                  final index = entry.key;
                  final option = entry.value;
                  final isSelected = index == selectedAnswer;

                  return _buildOption(
                    context,
                    option,
                    isSelected,
                    reviewing,
                    () => _selectAnswer(index),
                  );
                },
              ).toList(),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: currentStep == 0 ? null : _previousQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C2C2E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Previous',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: reviewing ? _submitQuiz : _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFE9500),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      currentStep == widget.quiz.questions.length - 1
                          ? 'Review Answers'
                          : 'Next',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
