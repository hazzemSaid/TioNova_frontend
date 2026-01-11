import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/core/get_it/services_locator.dart';
import 'package:tionova/core/utils/safe_navigation.dart';
import 'package:tionova/features/quiz/presentation/bloc/quizcubit.dart';
import 'package:tionova/features/quiz/presentation/bloc/quizstate.dart';

class PracticeModeScreen extends StatefulWidget {
  final String chapterId;
  final String? folderId;
  final String? chapterTitle;

  const PracticeModeScreen({
    super.key,
    required this.chapterId,
    this.folderId,
    this.chapterTitle,
  });

  @override
  State<PracticeModeScreen> createState() => _PracticeModeScreenState();
}

class _PracticeModeScreenState extends State<PracticeModeScreen> {
  String _extractLetterFromOption(String option) {
    final match = RegExp(
      r'^([a-d])\s*\)',
    ).firstMatch(option.trim().toLowerCase());
    return match?.group(1) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocProvider(
      create: (context) =>
          getIt<QuizCubit>()..getPracticeMode(chapterId: widget.chapterId),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text(
            'Practice Mode',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.safePop(
              folderId: widget.folderId,
              chapterId: widget.chapterId,
              fallback: '/',
            ),
          ),
          backgroundColor: colorScheme.surface,
          elevation: 0,
        ),
        body: BlocConsumer<QuizCubit, QuizState>(
          listener: (context, state) {
            if (state is PracticeModeFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.failure.errMessage),
                  backgroundColor: colorScheme.error,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is PracticeModeLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Preparing practice questions...',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is PracticeModeComplete) {
              return _buildCompletionView(
                context,
                state,
                colorScheme,
                textTheme,
              );
            }

            if (state is PracticeModeReady ||
                state is PracticeModeAnswerSelected ||
                state is PracticeModeAnswerChecked) {
              return _buildQuestionView(context, state, colorScheme, textTheme);
            }

            return Center(
              child: Text(
                'Unable to load practice questions',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuestionView(
    BuildContext context,
    QuizState state,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final cubit = context.read<QuizCubit>();

    late final quiz;
    late final currentIndex;
    late final correctCount;
    String? selectedAnswer;
    bool? isAnswerChecked;
    bool? isCorrect;
    String? correctAnswer;
    String? explanation;

    if (state is PracticeModeReady) {
      quiz = state.quiz;
      currentIndex = state.currentQuestionIndex;
      correctCount = state.correctCount;
    } else if (state is PracticeModeAnswerSelected) {
      quiz = state.quiz;
      currentIndex = state.currentQuestionIndex;
      correctCount = state.correctCount;
      selectedAnswer = state.selectedAnswer;
    } else if (state is PracticeModeAnswerChecked) {
      quiz = state.quiz;
      currentIndex = state.currentQuestionIndex;
      correctCount = state.correctCount;
      selectedAnswer = state.selectedAnswer;
      isAnswerChecked = true;
      isCorrect = state.isCorrect;
      correctAnswer = state.correctAnswer;
      explanation = state.explanation;
    }

    final question = quiz.questions[currentIndex];
    final progress = (currentIndex + 1) / quiz.totalQuestions;

    return Column(
      children: [
        // Progress Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${currentIndex + 1} of ${quiz.totalQuestions}',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Score: $correctCount/${currentIndex + (isAnswerChecked == true ? 1 : 0)}',
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    question.question,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Options
                ...question.options.asMap().entries.map((entry) {
                  final optionText = entry.value;
                  final optionLetter = _extractLetterFromOption(optionText);
                  final isSelected = selectedAnswer == optionLetter;
                  final isCorrectOption =
                      isAnswerChecked == true && correctAnswer == optionLetter;
                  final isWrongSelected =
                      isAnswerChecked == true && isSelected && !isCorrect!;

                  Color? backgroundColor;
                  Color? borderColor;
                  Color? textColor;

                  if (isAnswerChecked == true) {
                    if (isCorrectOption) {
                      backgroundColor = colorScheme.primaryContainer;
                      borderColor = colorScheme.primary;
                      textColor = colorScheme.onPrimaryContainer;
                    } else if (isWrongSelected) {
                      backgroundColor = colorScheme.errorContainer;
                      borderColor = colorScheme.error;
                      textColor = colorScheme.onErrorContainer;
                    } else {
                      backgroundColor = colorScheme.surfaceContainerHighest;
                      borderColor = colorScheme.outline.withOpacity(0.3);
                      textColor = colorScheme.onSurfaceVariant;
                    }
                  } else if (isSelected) {
                    backgroundColor = colorScheme.primaryContainer.withOpacity(
                      0.5,
                    );
                    borderColor = colorScheme.primary;
                    textColor = colorScheme.onSurface;
                  } else {
                    backgroundColor = colorScheme.surfaceContainerHighest;
                    borderColor = colorScheme.outline.withOpacity(0.5);
                    textColor = colorScheme.onSurface;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: isAnswerChecked == true
                          ? null
                          : () => cubit.selectPracticeAnswer(optionLetter),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor, width: 2),
                        ),
                        child: Row(
                          children: [
                            if (isAnswerChecked == true && isCorrectOption)
                              Icon(
                                Icons.check_circle,
                                color: colorScheme.primary,
                                size: 24,
                              ),
                            if (isAnswerChecked == true && isWrongSelected)
                              Icon(
                                Icons.cancel,
                                color: colorScheme.error,
                                size: 24,
                              ),
                            if (isAnswerChecked == true &&
                                (isCorrectOption || isWrongSelected))
                              const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                optionText,
                                style: textTheme.bodyLarge?.copyWith(
                                  color: textColor,
                                  fontWeight: isSelected || isCorrectOption
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                // Feedback Section
                if (isAnswerChecked == true) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isCorrect!
                          ? colorScheme.primaryContainer.withOpacity(0.3)
                          : colorScheme.errorContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isCorrect
                            ? colorScheme.primary.withOpacity(0.5)
                            : colorScheme.error.withOpacity(0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isCorrect ? Icons.check_circle : Icons.cancel,
                              color: isCorrect
                                  ? colorScheme.primary
                                  : colorScheme.error,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              isCorrect ? 'Correct!' : 'Incorrect',
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isCorrect
                                    ? colorScheme.primary
                                    : colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                        if (explanation != null && explanation.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Explanation:',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            explanation,
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Bottom Action Button
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              top: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
            ),
          ),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedAnswer == null
                    ? null
                    : () {
                        if (isAnswerChecked == true) {
                          cubit.nextPracticeQuestion();
                        } else {
                          cubit.checkPracticeAnswer();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  disabledBackgroundColor: colorScheme.surfaceContainerHighest,
                  disabledForegroundColor: colorScheme.onSurfaceVariant,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isAnswerChecked == true
                      ? (currentIndex < quiz.totalQuestions - 1
                            ? 'Next Question'
                            : 'Finish Practice')
                      : 'Check Answer',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionView(
    BuildContext context,
    PracticeModeComplete state,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final percentage = (state.correctCount / state.totalQuestions * 100)
        .round();
    final cubit = context.read<QuizCubit>();

    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.emoji_events,
                  size: 64,
                  color: colorScheme.primary,
                ),
              ),
              Text(
                'Practice Complete!',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'You got ${state.correctCount} out of ${state.totalQuestions} correct',
                textAlign: TextAlign.center,
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 26),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'Accuracy',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$percentage%',
                      style: textTheme.displayLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    cubit.resetPracticeMode();
                    context.safePop(
                      folderId: widget.folderId,
                      chapterId: widget.chapterId,
                      fallback: '/',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    cubit.getPracticeMode(chapterId: widget.chapterId);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    side: BorderSide(color: colorScheme.primary),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Practice Again',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
