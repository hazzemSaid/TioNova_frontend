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
  final String chapterId;
  final String folderId;

  const QuizQuestionsScreen({
    super.key,
    required this.quiz,
    required this.answers,
    required this.chapterId,
    required this.folderId,
  });

  @override
  State<QuizQuestionsScreen> createState() => _QuizQuestionsScreenState();
}

class _QuizQuestionsScreenState extends State<QuizQuestionsScreen> {
  late int currentStep;
  int selectedAnswer = -1; // Initialize to -1 (no selection)
  bool reviewing = false;
  bool submitted = false;
  late Timer _timer;
  late int _remainingTimeInSeconds;
  static const int quizDurationInMinutes = 15;

  // Map to track answers by question index for better management
  final Map<int, String> answersMap = {};

  @override
  void initState() {
    super.initState();
    print('========== INIT STATE START ==========');
    currentStep = 0;
    _remainingTimeInSeconds = quizDurationInMinutes * 60;

    // Initialize map from existing answers list
    for (int i = 0; i < widget.answers.length; i++) {
      if (widget.answers[i] != null && widget.answers[i]!.isNotEmpty) {
        answersMap[i] = widget.answers[i]!;
      }
    }

    print('Initialized answersMap: $answersMap');
    print('Answers array: ${widget.answers}');
    print('Current step: $currentStep');

    // Only set selectedAnswer if there's actually a stored answer
    if (answersMap.containsKey(currentStep)) {
      selectedAnswer = _getSelectedAnswerIndex(currentStep);
      print(
        'Found stored answer in map, selectedAnswer set to: $selectedAnswer',
      );
    } else {
      print('No stored answer in map, keeping selectedAnswer as -1');
    }

    print('After check - selectedAnswer: $selectedAnswer');
    print('========== INIT STATE END ==========');
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
    final storedAnswer = answersMap[questionIndex];
    print(
      'Getting answer for question $questionIndex from map, stored: $storedAnswer',
    );

    if (storedAnswer == null || storedAnswer.isEmpty) {
      print('No stored answer in map');
      return -1;
    }

    final storedLetter = storedAnswer.toLowerCase().trim();
    print('Looking for letter: "$storedLetter"');

    // Find the option that starts with this letter
    final options = widget.quiz.questions[questionIndex].options;
    for (int i = 0; i < options.length; i++) {
      final optionLetter = _extractLetterFromOption(options[i]);
      print('Option $i: "${options[i]}" -> letter: "$optionLetter"');

      // Match by extracted letter if available, otherwise match by index-based letter
      if (optionLetter != null && optionLetter == storedLetter) {
        print('Match found at index $i (by option letter)');
        return i;
      } else if (optionLetter == null &&
          String.fromCharCode(97 + i) == storedLetter) {
        // If option doesn't have letter prefix, match by index-based letter (a, b, c, d)
        print('Match found at index $i (by index-based letter)');
        return i;
      }
    }

    print('No match found, returning -1');
    return -1;
  }

  void _selectAnswer(int index) {
    print('=== _selectAnswer called ===');
    print('Selecting answer index $index for question $currentStep');
    print('Current answersMap: $answersMap');
    final option = widget.quiz.questions[currentStep].options[index];
    final letter = _extractLetterFromOption(option);
    print('Extracted letter: $letter from option: $option');

    setState(() {
      selectedAnswer = index;
      final answerLetter = letter ?? String.fromCharCode(97 + index);

      // Store in map
      answersMap[currentStep] = answerLetter;

      // Sync with widget.answers list for backward compatibility
      widget.answers[currentStep] = answerLetter;

      print('Stored answer at index $currentStep: $answerLetter');
      print('Updated answersMap: $answersMap');
      print('Full answers array after update: ${widget.answers}');
    });
  }

  void _nextQuestion() {
    print(
      'Next question - Current: $currentStep, Total: ${widget.quiz.questions.length}',
    );
    if (currentStep < widget.quiz.questions.length - 1) {
      setState(() {
        currentStep++;
        // Only set selectedAnswer if there's a stored answer in map
        if (answersMap.containsKey(currentStep)) {
          selectedAnswer = _getSelectedAnswerIndex(currentStep);
          print(
            'Next - Found stored answer in map at $currentStep: ${answersMap[currentStep]}, selected: $selectedAnswer',
          );
        } else {
          selectedAnswer = -1;
          print('Next - No stored answer in map at $currentStep, selected: -1');
        }
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
        // Only set selectedAnswer if there's a stored answer in map
        if (answersMap.containsKey(currentStep)) {
          selectedAnswer = _getSelectedAnswerIndex(currentStep);
          print(
            'Previous - Found stored answer in map at $currentStep: ${answersMap[currentStep]}, selected: $selectedAnswer',
          );
        } else {
          selectedAnswer = -1;
          print(
            'Previous - No stored answer in map at $currentStep, selected: -1',
          );
        }
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

    // Convert answersMap to List format for backend
    // Fill with null for unanswered questions
    final List<String?> finalAnswers = List<String?>.filled(
      widget.quiz.questions.length,
      null,
    );
    answersMap.forEach((index, letter) {
      finalAnswers[index] = letter;
    });

    print('=== SUBMITTING QUIZ ===');
    print('Answers from map: $answersMap');
    print('Final answers list: $finalAnswers');

    final hasFolder = widget.folderId.isNotEmpty;
    final path = hasFolder
        ? '/folders/${widget.folderId}/chapters/${widget.chapterId}/quiz/results'
        : '/chapters/${widget.chapterId}/quiz/results';
    context.pushReplacement(
      path,
      extra: {
        'quiz': widget.quiz,
        'userAnswers': finalAnswers,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outline.withOpacity(0.3),
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
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                    width: 2.0,
                  ),
                  color: isSelected ? colorScheme.primary : Colors.transparent,
                ),
                child: isSelected
                    ? Icon(Icons.check, size: 16, color: colorScheme.onPrimary)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    color: isSelected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurface,
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
    print('=============== BUILD START ===============');
    print('Building - Question: $currentStep, Selected: $selectedAnswer');
    print('Current answersMap: $answersMap');
    print('Current answers array: ${widget.answers}');
    print('=============== BUILD END ===============');
    final size = MediaQuery.of(context).size;
    final isWeb = size.width > 900;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (reviewing) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
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
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: isWeb ? _buildWebLayout(context) : _buildMobileLayout(context),
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side - Question content
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with back button and timer
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(
                        Icons.arrow_back,
                        color: colorScheme.onSurface,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.surfaceContainerHighest,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: colorScheme.onSurface,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatTime(_remainingTimeInSeconds),
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.visibility_outlined,
                        color: colorScheme.onSurface,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.surfaceContainerHighest,
                      ),
                      tooltip: 'Review',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Progress bar
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value:
                              (currentStep + 1) / widget.quiz.questions.length,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.primary,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${((currentStep + 1) / widget.quiz.questions.length * 100).toInt()}%',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Question
                Text(
                  widget.quiz.questions[currentStep].question,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                // Options
                Expanded(
                  child: ListView(
                    children: widget.quiz.questions[currentStep].options
                        .asMap()
                        .entries
                        .map((entry) {
                          final index = entry.key;
                          final option = entry.value;
                          final isSelected = index == selectedAnswer;
                          print(
                            'Building web option $index: "$option", isSelected: $isSelected',
                          );

                          return GestureDetector(
                            onTap: () {
                              print(
                                '!!! GestureDetector tapped - index: $index !!!',
                              );
                              _selectAnswer(index);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16.0),
                              padding: const EdgeInsets.all(20.0),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colorScheme.primaryContainer
                                    : colorScheme.surface,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.outline.withOpacity(0.3),
                                  width: 1.5,
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
                                        color: isSelected
                                            ? colorScheme.primary
                                            : colorScheme.onSurfaceVariant,
                                        width: 2.0,
                                      ),
                                      color: isSelected
                                          ? colorScheme.primary
                                          : Colors.transparent,
                                    ),
                                    child: isSelected
                                        ? Center(
                                            child: CircleAvatar(
                                              radius: 6,
                                              backgroundColor:
                                                  colorScheme.onPrimary,
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: TextStyle(
                                        color: isSelected
                                            ? colorScheme.onPrimaryContainer
                                            : colorScheme.onSurfaceVariant,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        })
                        .toList(),
                  ),
                ),
                const SizedBox(height: 24),
                // Navigation buttons
                Row(
                  children: [
                    if (currentStep > 0)
                      OutlinedButton(
                        onPressed: _previousQuestion,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.onSurface,
                          side: BorderSide(
                            color: colorScheme.outline.withOpacity(0.3),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.arrow_back, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Previous',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _nextQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            currentStep == widget.quiz.questions.length - 1
                                ? 'Review Answers'
                                : 'Next Question',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),
          // Right side - Question Navigator
          Container(
            width: 320,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question Navigator',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                // Question numbers grid
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: List.generate(widget.quiz.questions.length, (
                    index,
                  ) {
                    final isAnswered = answersMap.containsKey(index);
                    final isCurrent = index == currentStep;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          currentStep = index;
                          selectedAnswer = _getSelectedAnswerIndex(index);
                        });
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? colorScheme.primary
                              : isAnswered
                              ? colorScheme.primaryContainer
                              : colorScheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isCurrent
                                ? colorScheme.primary
                                : isAnswered
                                ? colorScheme.primary.withOpacity(0.5)
                                : colorScheme.outline.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isCurrent
                                  ? colorScheme.onPrimary
                                  : isAnswered
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onSurfaceVariant,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 32),
                // Stats
                Row(
                  children: [
                    Text(
                      'Answered',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${answersMap.length} / ${widget.quiz.questions.length}',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Navigation buttons
                OutlinedButton(
                  onPressed: currentStep > 0 ? _previousQuestion : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.onSurface,
                    side: BorderSide(
                      color: colorScheme.outline.withOpacity(0.3),
                    ),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Previous',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    minimumSize: const Size(double.infinity, 48),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        currentStep == widget.quiz.questions.length - 1
                            ? 'Review'
                            : 'Next Question',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
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
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
          const SizedBox(height: 24),
          Text(
            widget.quiz.questions[currentStep].question,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ...widget.quiz.questions[currentStep].options.asMap().entries.map((
            entry,
          ) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = index == selectedAnswer;

            return _buildOption(context, option, isSelected, reviewing, () {
              print('!!! Mobile option tapped - index: $index !!!');
              _selectAnswer(index);
            });
          }).toList(),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: currentStep == 0 ? null : _previousQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  foregroundColor: colorScheme.onSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  'Previous',
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: reviewing ? _submitQuiz : _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
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
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
