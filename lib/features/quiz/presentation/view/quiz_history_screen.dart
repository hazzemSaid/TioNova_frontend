// features/quiz/presentation/view/quiz_history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/features/quiz/data/models/UserQuizStatusModel.dart';
import 'package:tionova/features/quiz/presentation/bloc/quizcubit.dart';
import 'package:tionova/features/quiz/presentation/bloc/quizstate.dart';

class QuizHistoryScreen extends StatefulWidget {
  final String chapterId;
  final String folderId;
  final String? quizTitle;

  const QuizHistoryScreen({
    super.key,
    required this.chapterId,
    required this.folderId,
    this.quizTitle,
  });

  @override
  State<QuizHistoryScreen> createState() => _QuizHistoryScreenState();
}

class _QuizHistoryScreenState extends State<QuizHistoryScreen> {
  final _getIt = GetIt.instance;

  late final QuizCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = _getIt<QuizCubit>();
    _cubit.gethistory(chapterId: widget.chapterId);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: colorScheme.onSurface,
              size: 18,
            ),
            onPressed: () => context.pop(),
          ),
          title: Column(
            children: [
              Text(
                'Quiz History',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                widget.quizTitle ?? '',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: ElevatedButton.icon(
                onPressed: () {
                  context.push(
                    '/quiz-start',
                    extra: {
                      'chapterId': widget.chapterId,
                      'quizTitle': widget.quizTitle,
                    },
                  );
                },
                icon: Icon(Icons.add, size: 16, color: colorScheme.onSurface),
                label: Text(
                  'New Quiz',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  foregroundColor: colorScheme.onSurface,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: BlocBuilder<QuizCubit, QuizState>(
          builder: (context, state) {
            if (state is GetHistoryLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is GetHistoryFailure) {
              return Center(
                child: Text(
                  'Failed to load history',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              );
            }
            if (state is GetHistorySuccess) {
              final UserQuizStatusModel history = state.history;
              final attempts = history.attempts;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.2,
                      children: [
                        _MetricCard(
                          icon: Icons.bar_chart,
                          iconColor: colorScheme.primary,
                          value: '${history.totalAttempts}',
                          label: 'Total Attempts',
                          colorScheme: colorScheme,
                        ),
                        _MetricCard(
                          icon: Icons.emoji_events,
                          iconColor: colorScheme.tertiary,
                          value: '${history.bestScore}%',
                          label: 'Best Score',
                          colorScheme: colorScheme,
                        ),
                        _MetricCard(
                          icon: Icons.trending_up,
                          iconColor: colorScheme.secondary,
                          value: '${history.averageScore}%',
                          label: 'Average Score',
                          colorScheme: colorScheme,
                        ),
                        _MetricCard(
                          icon: Icons.radio_button_checked,
                          iconColor: colorScheme.primaryContainer,
                          value: '${history.passRate}%',
                          label: 'Pass Rate',
                          colorScheme: colorScheme,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: colorScheme.onSurfaceVariant,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Recent Attempts',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    ...attempts.asMap().entries.map((entry) {
                      final index = entry.key;
                      final attempt = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == attempts.length - 1 ? 0 : 12,
                        ),
                        child: _AttemptCard(
                          attempt: attempt,
                          colorScheme: colorScheme,
                          folderId: widget.folderId,
                          chapterId: widget.chapterId,
                        ),
                      );
                    }).toList(),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final ColorScheme colorScheme;

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttemptCard extends StatelessWidget {
  final Attempt attempt;
  final ColorScheme colorScheme;
  final String folderId;
  final String chapterId;

  const _AttemptCard({
    required this.attempt,
    required this.colorScheme,
    required this.folderId,
    required this.chapterId,
  });

  @override
  Widget build(BuildContext context) {
    final degree = attempt.degree;
    final total = attempt.totalQuestions;
    final correct = attempt.correct;
    final state = attempt.state.toLowerCase();
    final passed = state == 'passed';
    final DateTime started = attempt.startedAt;
    final duration = attempt.timeTaken ?? 0;
    final score = attempt.degree;

    return GestureDetector(
      onTap: () {
        final hasFolder = folderId.isNotEmpty;
        final path = hasFolder
            ? '/folders/$folderId/chapters/$chapterId/quiz/review'
            : '/chapters/$chapterId/quiz/review';
        context.push(path, extra: {'attempt': attempt});
      },
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _StatusChip(passed: passed, colorScheme: colorScheme),
                const Spacer(),
                Text(
                  _formatDate(started),
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.visibility_outlined,
                  color: colorScheme.onSurfaceVariant,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '$degree%',
              style: TextStyle(
                color: passed ? colorScheme.tertiary : colorScheme.error,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$correct/$total correct',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.schedule_outlined,
                  color: colorScheme.onSurfaceVariant,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  duration > 0
                      ? _formatDuration(Duration(seconds: duration))
                      : '—',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Text(
                  'Score: $score/100',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inSeconds <= 0) return '—';
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _StatusChip extends StatelessWidget {
  final bool passed;
  final ColorScheme colorScheme;

  const _StatusChip({required this.passed, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final color = passed ? colorScheme.tertiary : colorScheme.error;
    final icon = passed ? Icons.check_circle : Icons.cancel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            passed ? 'Passed' : 'Failed',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Quiz Review Screen
class QuizReviewScreen extends StatelessWidget {
  final Attempt attempt;

  const QuizReviewScreen({super.key, required this.attempt});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final degree = attempt.degree;
    final total = attempt.totalQuestions;
    final correct = attempt.correct;
    final incorrect = total - correct;
    final duration = attempt.completedAt.difference(attempt.startedAt);
    final timeSpent = '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    final score = attempt.degree;
    final passed = attempt.state.toLowerCase() == 'passed';
    final DateTime started = attempt.startedAt;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: colorScheme.onSurface,
            size: 18,
          ),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            Text(
              'Quiz Review',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Binary Search Trees',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: colorScheme.onSurface, size: 20),
            onPressed: () {},
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text(
                'Retake',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.surfaceContainerHighest,
                foregroundColor: colorScheme.onSurface,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _StatusChip(passed: passed, colorScheme: colorScheme),
                  const SizedBox(height: 16),
                  Text(
                    '$degree%',
                    style: TextStyle(
                      color: passed ? colorScheme.tertiary : colorScheme.error,
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDateTime(started),
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Progress bar
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      widthFactor: degree / 100,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          color: passed
                              ? colorScheme.tertiary
                              : colorScheme.error,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Stats Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _StatCard(
                  icon: Icons.radio_button_checked,
                  iconColor: colorScheme.primary,
                  value: score.toString(),
                  label: 'Total Score',
                  colorScheme: colorScheme,
                ),
                _StatCard(
                  icon: Icons.check_circle,
                  iconColor: colorScheme.tertiary,
                  value: correct.toString(),
                  label: 'Correct',
                  colorScheme: colorScheme,
                ),
                _StatCard(
                  icon: Icons.cancel,
                  iconColor: colorScheme.error,
                  value: incorrect.toString(),
                  label: 'Incorrect',
                  colorScheme: colorScheme,
                ),
                _StatCard(
                  icon: Icons.schedule,
                  iconColor: colorScheme.secondary,
                  value: timeSpent,
                  label: 'Time Spent',
                  colorScheme: colorScheme,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Question Review Header
            Text(
              'Question Review',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Review your answers and see detailed explanations',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 20),

            for (int i = 0; i < attempt.answers.length; i++) ...[
              _QuestionCard(
                questionNumber: i + 1,
                question: attempt.answers[i].question,
                userAnswer: attempt.answers[i].selectedOption,
                correctAnswer: attempt.answers[i].correctAnswer,
                explanation: attempt.answers[i].explanation,
                isCorrect: attempt.answers[i].isCorrect,
                options: attempt.answers[i].options,
                colorScheme: colorScheme,
              ),
              if (i != attempt.answers.length - 1) const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final hour = date.hour > 12
        ? date.hour - 12
        : date.hour == 0
        ? 12
        : date.hour;
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');

    return '${months[date.month - 1]} ${date.day}, ${date.year} at $hour:$minute $period';
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final ColorScheme colorScheme;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final int questionNumber;
  final String question;
  final String userAnswer;
  final String? correctAnswer;
  final String? explanation;
  final bool isCorrect;
  final List<String> options;
  final ColorScheme colorScheme;

  const _QuestionCard({
    required this.questionNumber,
    required this.question,
    required this.userAnswer,
    this.correctAnswer,
    this.explanation,
    required this.isCorrect,
    required this.options,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isCorrect ? colorScheme.tertiary : colorScheme.error;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Icon(
                  isCorrect ? Icons.check : Icons.close,
                  color: statusColor,
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$questionNumber',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: statusColor,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Answer:',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userAnswer == "z"
                      ? "No Answer"
                      : options[(userAnswer.toLowerCase().codeUnitAt(0) -
                            'a'.codeUnitAt(0))],
                  style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
                ),
              ],
            ),
          ),
          if (!isCorrect && correctAnswer != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.tertiary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.tertiary.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Correct Answer:',
                    style: TextStyle(
                      color: colorScheme.tertiary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    options[(correctAnswer!.toLowerCase().codeUnitAt(0) -
                        'a'.codeUnitAt(0))],
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (explanation != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explanation:',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    explanation!,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
