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
          child: BlocBuilder<QuizCubit, QuizState>(
            builder: (context, state) {
              if (state is GetHistoryLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is GetHistoryFailure) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load history',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 16,
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            _cubit.gethistory(chapterId: widget.chapterId),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                );
              }
              if (state is GetHistorySuccess) {
                return _buildResponsiveLayout(context, state.history);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveLayout(
    BuildContext context,
    UserQuizStatusModel history,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 900;
    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildSliverAppBar(context, colorScheme),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWeb ? screenWidth * 0.1 : 20.0,
              vertical: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMetricsSection(context, history, isWeb),
                const SizedBox(height: 40),
                _buildHistoryHeader(colorScheme),
                const SizedBox(height: 20),
                _buildHistoryList(history, isWeb),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context, ColorScheme colorScheme) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: colorScheme.surface.withOpacity(0.8),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(color: Colors.transparent),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: colorScheme.onSurface,
        ),
        onPressed: () => context.pop(),
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Quiz History',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (widget.quizTitle != null && widget.quizTitle!.isNotEmpty)
            Text(
              widget.quizTitle!,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: TextButton.icon(
            onPressed: () {
              final hasFolder = widget.folderId.isNotEmpty;
              final path = hasFolder
                  ? '/folders/${widget.folderId}/chapters/${widget.chapterId}/quiz'
                  : '/chapters/${widget.chapterId}/quiz';
              context.push(path);
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New'),
            style: TextButton.styleFrom(
              backgroundColor: colorScheme.primary.withOpacity(0.1),
              foregroundColor: colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsSection(
    BuildContext context,
    UserQuizStatusModel history,
    bool isWeb,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isWeb ? 4 : 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: isWeb ? 1.5 : 1.3,
          children: [
            _MetricCard(
              icon: Icons.bar_chart_rounded,
              iconColor: colorScheme.primary,
              value: '${history.totalAttempts}',
              label: 'Total Attempts',
            ),
            _MetricCard(
              icon: Icons.emoji_events_rounded,
              iconColor: const Color(0xFFF59E0B),
              value: '${history.bestScore}%',
              label: 'Best Score',
            ),
            _MetricCard(
              icon: Icons.trending_up_rounded,
              iconColor: const Color(0xFF10B981),
              value: '${history.averageScore}%',
              label: 'Avg Score',
            ),
            _MetricCard(
              icon: Icons.pie_chart_rounded,
              iconColor: const Color(0xFF8B5CF6),
              value: '${history.passRate}%',
              label: 'Pass Rate',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHistoryHeader(ColorScheme colorScheme) {
    return Row(
      children: [
        Text(
          'Recent Activities',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const Spacer(),
        Icon(Icons.tune_rounded, size: 20, color: colorScheme.onSurfaceVariant),
      ],
    );
  }

  Widget _buildHistoryList(UserQuizStatusModel history, bool isWeb) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.attempts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _AttemptCard(
          attempt: history.attempts[index],
          folderId: widget.folderId,
          chapterId: widget.chapterId,
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttemptCard extends StatelessWidget {
  final Attempt attempt;
  final String folderId;
  final String chapterId;

  const _AttemptCard({
    required this.attempt,
    required this.folderId,
    required this.chapterId,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final passed = attempt.state.toLowerCase() == 'passed';
    final statusColor = passed ? const Color(0xFF10B981) : colorScheme.error;

    return GestureDetector(
      onTap: () {
        final hasFolder = folderId.isNotEmpty;
        final path = hasFolder
            ? '/folders/$folderId/chapters/$chapterId/quiz/review'
            : '/chapters/$chapterId/quiz/review';
        context.push(path, extra: {'attempt': attempt});
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  '${attempt.degree}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        passed ? 'Completed' : 'Attempted',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusDot(color: statusColor),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(attempt.startedAt),
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${attempt.correct}/${attempt.totalQuestions}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Correct',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
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

class _StatusDot extends StatelessWidget {
  final Color color;
  const _StatusDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}
