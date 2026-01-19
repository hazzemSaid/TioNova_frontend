// features/quiz/presentation/view/quiz_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/features/quiz/data/models/QuizModel.dart';
import 'package:tionova/features/quiz/presentation/bloc/quizcubit.dart';
import 'package:tionova/features/quiz/presentation/bloc/quizstate.dart';
import 'package:tionova/features/quiz/presentation/widgets/quiz_header.dart';

class QuizScreen extends StatefulWidget {
  final String chapterId;
  final String folderId;

  const QuizScreen({
    super.key,
    required this.chapterId,
    required this.folderId,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<QuizCubit>().createQuiz(chapterId: widget.chapterId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: BlocConsumer<QuizCubit, QuizState>(
        listener: (context, state) {
          if (state is CreateQuizFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failure.errMessage),
                behavior: SnackBarBehavior.floating,
                backgroundColor: colorScheme.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CreateQuizLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Generating Quiz...',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            );
          }

          if (state is CreateQuizSuccess) {
            return _buildQuizContent(context, state.quiz);
          }

          // Error/Fallback view
          return _buildErrorPlaceholder(colorScheme);
        },
      ),
    );
  }

  Widget _buildErrorPlaceholder(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: colorScheme.error.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text('Something went wrong while loading the quiz.'),
          TextButton(
            onPressed: () => context.read<QuizCubit>().createQuiz(
              chapterId: widget.chapterId,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizContent(BuildContext context, QuizModel quiz) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const QuizHeader(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            Icon(
                              Icons.emoji_events_rounded,
                              color: Colors.amber,
                              size: 80,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              quiz.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Test your knowledge with ${quiz.questions.length} refined questions',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 40),
                            _buildInfoGrid(colorScheme, quiz.questions.length),
                            const SizedBox(height: 40),
                            _buildRequirementsList(colorScheme),
                            const Spacer(),
                            const SizedBox(height: 40),
                            _buildStartButton(context, colorScheme, quiz),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoGrid(ColorScheme colorScheme, int questionCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildInfoCard(
          colorScheme,
          questionCount.toString(),
          'Questions',
          Icons.help_outline_rounded,
        ),
        _buildInfoCard(colorScheme, '15m', 'Time Limit', Icons.timer_outlined),
        _buildInfoCard(
          colorScheme,
          'Medium',
          'Difficulty',
          Icons.speed_rounded,
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    ColorScheme colorScheme,
    String value,
    String label,
    IconData icon,
  ) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementsList(ColorScheme colorScheme) {
    final items = [
      'Timed multiple choice questions',
      'Review your answers at the end',
      'Get detailed AI-powered feedback',
    ];

    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    item,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildStartButton(
    BuildContext context,
    ColorScheme colorScheme,
    QuizModel quiz,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () {
          final hasFolder = widget.folderId.isNotEmpty;
          final path = hasFolder
              ? '/folders/${widget.folderId}/chapters/${widget.chapterId}/quiz/questions'
              : '/chapters/${widget.chapterId}/quiz/questions';
          context.push(
            path,
            extra: {
              'quiz': quiz,
              'answers': List.filled(quiz.questions.length, null),
              'chapterId': widget.chapterId,
              'folderId': widget.folderId,
            },
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Start Challenge',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.arrow_forward_rounded),
          ],
        ),
      ),
    );
  }
}
