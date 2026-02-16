// features/quiz/presentation/view/practice_mode_screen.dart
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

    return BlocProvider(
      create: (context) =>
          getIt<QuizCubit>()..getPracticeMode(chapterId: widget.chapterId),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.surface,
                colorScheme.surfaceContainerLowest.withOpacity(0.5),
                colorScheme.surface,
              ],
            ),
          ),
          child: BlocConsumer<QuizCubit, QuizState>(
            listener: (context, state) {
              if (state is PracticeModeFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.failure.errMessage),
                    backgroundColor: colorScheme.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is PracticeModeLoading) {
                return _buildLoadingView(colorScheme);
              }

              if (state is PracticeModeComplete) {
                return _buildCompletionView(context, state);
              }

              if (state is PracticeModeReady ||
                  state is PracticeModeAnswerSelected ||
                  state is PracticeModeAnswerChecked) {
                return _buildQuestionView(context, state);
              }

              return _buildErrorView(context, colorScheme);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              color: colorScheme.primary,
              strokeWidth: 6,
              strokeCap: StrokeCap.round,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Mastery in Progress...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Preparing your customized practice set',
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sentiment_dissatisfied_rounded,
              size: 80,
              color: colorScheme.error.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'We couldn\'t load the practice questions. Please try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.read<QuizCubit>().getPracticeMode(
                chapterId: widget.chapterId,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionView(BuildContext context, QuizState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final cubit = context.read<QuizCubit>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 900;

    dynamic quiz;
    int currentIndex = 0;
    int correctCount = 0;
    String? selectedAnswer;
    bool isAnswerChecked = false;
    bool isCorrect = false;
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
        _buildCustomHeader(
          context,
          colorScheme,
          currentIndex,
          quiz.totalQuestions,
          correctCount,
          isAnswerChecked,
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isWeb ? screenWidth * 0.15 : 20.0,
              vertical: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressIndicator(colorScheme, progress),
                const SizedBox(height: 32),
                _buildQuestionCard(colorScheme, question.question),
                const SizedBox(height: 40),
                _buildOptionsList(
                  cubit,
                  colorScheme,
                  question.options,
                  selectedAnswer,
                  isAnswerChecked,
                  correctAnswer,
                  isCorrect,
                ),
                if (isAnswerChecked) ...[
                  const SizedBox(height: 32),
                  _buildFeedbackSection(colorScheme, isCorrect, explanation),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
        _buildBottomAction(
          context,
          cubit,
          colorScheme,
          selectedAnswer,
          isAnswerChecked,
          currentIndex,
          quiz.totalQuestions,
          isWeb,
        ),
      ],
    );
  }

  Widget _buildCustomHeader(
    BuildContext context,
    ColorScheme colorScheme,
    int current,
    int total,
    int score,
    bool isChecked,
  ) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 15,
        left: 10,
        right: 20,
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: colorScheme.onSurface,
            ),
            onPressed: () => context.safePop(
              folderId: widget.folderId,
              chapterId: widget.chapterId,
              fallback: '/',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Practice Mode',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  widget.chapterTitle ?? 'Chapter Mastery',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt_rounded, size: 16, color: colorScheme.primary),
                const SizedBox(width: 4),
                Text(
                  '$score pts',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(ColorScheme colorScheme, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: colorScheme.surfaceContainerHighest.withOpacity(
              0.5,
            ),
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(ColorScheme colorScheme, String questionText) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Text(
        questionText.replaceAll('\\n', '\n'),
        maxLines: null,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
          height: 1.6,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildOptionsList(
    QuizCubit cubit,
    ColorScheme colorScheme,
    List<String> options,
    String? selected,
    bool isChecked,
    String? correct,
    bool isUserCorrect,
  ) {
    return Column(
      children: options.asMap().entries.map((entry) {
        final optionText = entry.value;
        final letter = _extractLetterFromOption(optionText);
        final isSelected = selected == letter;
        final isCorrectOption = isChecked && correct == letter;
        final isWrongSelected = isChecked && isSelected && !isUserCorrect;

        Color itemColor = colorScheme.onSurface;
        Color borderColor = colorScheme.outlineVariant.withOpacity(0.3);
        Color bgColor = colorScheme.surfaceContainerHighest.withOpacity(0.2);

        if (isChecked) {
          if (isCorrectOption) {
            itemColor = const Color(0xFF10B981);
            borderColor = itemColor.withOpacity(0.5);
            bgColor = itemColor.withOpacity(0.08);
          } else if (isWrongSelected) {
            itemColor = colorScheme.error;
            borderColor = itemColor.withOpacity(0.5);
            bgColor = itemColor.withOpacity(0.08);
          } else {
            itemColor = colorScheme.onSurfaceVariant.withOpacity(0.5);
            bgColor = colorScheme.surfaceContainerHighest.withOpacity(0.1);
          }
        } else if (isSelected) {
          itemColor = colorScheme.primary;
          borderColor = itemColor.withOpacity(0.5);
          bgColor = itemColor.withOpacity(0.08);
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: isChecked ? null : () => cubit.selectPracticeAnswer(letter),
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor, width: 2),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isSelected || isCorrectOption
                          ? itemColor.withOpacity(0.15)
                          : colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected || isCorrectOption
                            ? itemColor.withOpacity(0.5)
                            : colorScheme.outlineVariant,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: isChecked && (isCorrectOption || isWrongSelected)
                          ? Icon(
                              isCorrectOption
                                  ? Icons.check_rounded
                                  : Icons.close_rounded,
                              size: 18,
                              color: itemColor,
                            )
                          : Text(
                              letter.toUpperCase(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? itemColor
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      optionText,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected || isCorrectOption
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isChecked && (isCorrectOption || isWrongSelected)
                            ? colorScheme.onSurface
                            : (isChecked
                                  ? colorScheme.onSurfaceVariant.withOpacity(
                                      0.7,
                                    )
                                  : colorScheme.onSurface),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeedbackSection(
    ColorScheme colorScheme,
    bool isCorrect,
    String? explanation,
  ) {
    final statusColor = isCorrect ? const Color(0xFF10B981) : colorScheme.error;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: statusColor.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCorrect
                      ? Icons.auto_awesome_rounded
                      : Icons.lightbulb_outline_rounded,
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isCorrect ? 'Fantastic Work!' : 'Quick Insight',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: statusColor,
                ),
              ),
            ],
          ),
          if (explanation != null && explanation.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              explanation,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
                height: 1.6,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomAction(
    BuildContext context,
    QuizCubit cubit,
    ColorScheme colorScheme,
    String? selected,
    bool isChecked,
    int current,
    int total,
    bool isWeb,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.fromLTRB(
        isWeb ? screenWidth * 0.15 : 24,
        16,
        isWeb ? screenWidth * 0.15 : 24,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.8),
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.2)),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: selected == null
              ? null
              : () {
                  if (isChecked) {
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
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: Text(
            isChecked
                ? (current < total - 1 ? 'Continue' : 'Finish Session')
                : 'Confirm Answer',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionView(
    BuildContext context,
    PracticeModeComplete state,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final percentage = (state.correctCount / state.totalQuestions * 100)
        .round();
    final cubit = context.read<QuizCubit>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 900;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isWeb ? screenWidth * 0.25 : 32.0,
          vertical: 60,
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
                Icon(
                  Icons.stars_rounded,
                  size: 100,
                  color: colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Session Complete!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: colorScheme.onSurface,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Great progress on mastering this chapter.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 48),

            Row(
              children: [
                Expanded(
                  child: _buildResultStat(
                    colorScheme,
                    'Accuracy',
                    '$percentage%',
                    colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildResultStat(
                    colorScheme,
                    'Questions',
                    '${state.correctCount}/${state.totalQuestions}',
                    const Color(0xFF10B981),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60),

            SizedBox(
              width: double.infinity,
              height: 56,
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Return to Chapter',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () =>
                    cubit.getPracticeMode(chapterId: widget.chapterId),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colorScheme.primary, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  'Practice Again',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultStat(
    ColorScheme colorScheme,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
