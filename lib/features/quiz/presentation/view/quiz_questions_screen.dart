// features/quiz/presentation/view/quiz_questions_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/features/quiz/data/models/QuizModel.dart';
import 'package:tionova/features/quiz/presentation/bloc/quizcubit.dart';
import 'package:tionova/features/quiz/presentation/view/quiz_results_screen.dart';
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
  late int selectedAnswer;
  bool reviewing = false;
  bool submitted = false;

  @override
  void initState() {
    super.initState();
    currentStep = 0;
    selectedAnswer = widget.answers[currentStep] != null
        ? widget.quiz.questions[currentStep].options.indexOf(
            widget.answers[currentStep]!,
          )
        : -1;
  }

  void _selectAnswer(int index) {
    setState(() {
      selectedAnswer = index;
      // Store the selected option letter (a, b, c, d)
      widget.answers[currentStep] = String.fromCharCode(
        97 + index,
      ); // 97 is ASCII for 'a'
    });
  }

  void _nextQuestion() {
    if (currentStep < widget.quiz.questions.length - 1) {
      setState(() {
        currentStep++;
        selectedAnswer = widget.answers[currentStep] != null
            ? widget.quiz.questions[currentStep].options.indexOf(
                widget.answers[currentStep]!,
              )
            : -1;
      });
    } else {
      setState(() {
        reviewing = true;
        currentStep = 0; // Reset to first question for review
        selectedAnswer = -1; // Clear selection for review mode
      });
    }
  }

  void _submitQuiz() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<QuizCubit>(),
          child: QuizResultsScreen(
            quiz: widget.quiz,
            userAnswers: widget.answers,
            token: widget.token,
            chapterId: widget.chapterId,
          ),
        ),
      ),
    );
  }

  void _previousQuestion() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
        selectedAnswer = widget.answers[currentStep] != null
            ? widget.quiz.questions[currentStep].options.indexOf(
                widget.answers[currentStep]!,
              )
            : -1;
      });
    }
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
    // Show review answers when in review mode
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
                timer: '14:59',
              ),
              const SizedBox(height: 16),
              // Progress bar
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
              // Options as cards
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
