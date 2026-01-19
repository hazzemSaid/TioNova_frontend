// features/quiz/presentation/view/quiz_review_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/features/quiz/data/models/UserQuizStatusModel.dart';

class QuizReviewScreen extends StatelessWidget {
  final Attempt attempt;
  final String? quizTitle;

  const QuizReviewScreen({super.key, required this.attempt, this.quizTitle});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final degree = attempt.degree;
    final total = attempt.totalQuestions;
    final correct = attempt.correct;
    final incorrect = total - correct;
    final duration = attempt.completedAt.difference(attempt.startedAt);
    final timeSpent = _formatDuration(duration);
    final score = attempt.degree;
    final passed = attempt.state.toLowerCase() == 'passed';
    final DateTime started = attempt.startedAt;

    return Scaffold(
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
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(context, colorScheme),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMainStatusCard(colorScheme, passed, degree, started),
                    const SizedBox(height: 24),
                    _buildStatsGrid(
                      colorScheme,
                      score,
                      correct,
                      incorrect,
                      timeSpent,
                    ),
                    const SizedBox(height: 40),
                    _buildReviewHeader(colorScheme),
                    const SizedBox(height: 16),
                    _buildQuestionsList(colorScheme),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
      title: Text(
        'Quiz Review',
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildMainStatusCard(
    ColorScheme colorScheme,
    bool passed,
    int degree,
    DateTime started,
  ) {
    final statusColor = passed ? const Color(0xFF10B981) : colorScheme.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _StatusChip(passed: passed, colorScheme: colorScheme),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: degree / 100,
                  strokeWidth: 10,
                  backgroundColor: colorScheme.surfaceVariant,
                  color: statusColor,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$degree%',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    'Score',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            _formatDateTime(started),
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(
    ColorScheme colorScheme,
    int score,
    int correct,
    int incorrect,
    String timeSpent,
  ) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _StatCard(
          icon: Icons.emoji_events_outlined,
          label: 'Total Score',
          value: '$score/100',
          color: colorScheme.primary,
        ),
        _StatCard(
          icon: Icons.check_circle_outline_rounded,
          label: 'Correct',
          value: correct.toString(),
          color: const Color(0xFF10B981),
        ),
        _StatCard(
          icon: Icons.highlight_off_rounded,
          label: 'Incorrect',
          value: incorrect.toString(),
          color: colorScheme.error,
        ),
        _StatCard(
          icon: Icons.timer_outlined,
          label: 'Time Spent',
          value: timeSpent,
          color: colorScheme.secondary,
        ),
      ],
    );
  }

  Widget _buildReviewHeader(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question Review',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Detailed look at your quiz performance',
          style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildQuestionsList(ColorScheme colorScheme) {
    return Column(
      children: List.generate(attempt.answers.length, (i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _QuestionCard(
            questionNumber: i + 1,
            answer: attempt.answers[i],
            colorScheme: colorScheme,
          ),
        );
      }),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inSeconds <= 0) return '—';
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  String _formatDateTime(DateTime date) {
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
    final hour = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '${months[date.month - 1]} ${date.day}, ${date.year} • $hour:$minute $period';
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
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
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool passed;
  final ColorScheme colorScheme;
  const _StatusChip({required this.passed, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final color = passed ? const Color(0xFF10B981) : colorScheme.error;
    final icon = passed ? Icons.check_circle_rounded : Icons.cancel_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            passed ? 'PASSED' : 'FAILED',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatefulWidget {
  final int questionNumber;
  final Answer answer;
  final ColorScheme colorScheme;

  const _QuestionCard({
    required this.questionNumber,
    required this.answer,
    required this.colorScheme,
  });

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  bool _isExpanded = false;

  String _extractLetterFromOption(String option) {
    final trimmed = option.trim().toLowerCase();
    final match = RegExp(r'^([a-d])\s*\)').firstMatch(trimmed);
    return match?.group(1) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final isCorrect = widget.answer.isCorrect;
    final statusColor = isCorrect
        ? const Color(0xFF10B981)
        : widget.colorScheme.error;
    final selection = widget.answer.selectedOption.toLowerCase().trim();
    final correct = widget.answer.correctAnswer.toLowerCase().trim();

    return Container(
      decoration: BoxDecoration(
        color: widget.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isExpanded
              ? statusColor.withOpacity(0.5)
              : widget.colorScheme.outlineVariant.withOpacity(0.3),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          title: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${widget.questionNumber}',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.answer.question,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: widget.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          trailing: Icon(
            isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: statusColor,
            size: 22,
          ),
          onExpansionChanged: (val) => setState(() => _isExpanded = val),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  Text(
                    widget.answer.question,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: widget.colorScheme.onSurface,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...widget.answer.options.map((option) {
                    final optionLetter = _extractLetterFromOption(option);
                    final isUserSelection = optionLetter == selection;
                    final isCorrectAnswer = optionLetter == correct;

                    Color itemColor = widget.colorScheme.onSurfaceVariant;
                    BoxDecoration? decoration;
                    String? badge;

                    if (isUserSelection && isCorrectAnswer) {
                      itemColor = const Color(0xFF10B981);
                      badge = 'Your Correct Answer';
                    } else if (isUserSelection) {
                      itemColor = widget.colorScheme.error;
                      badge = 'Your Answer';
                    } else if (isCorrectAnswer) {
                      itemColor = const Color(0xFF10B981);
                      badge = 'Correct Answer';
                    }

                    if (isUserSelection || isCorrectAnswer) {
                      decoration = BoxDecoration(
                        color: itemColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: itemColor.withOpacity(0.3),
                          width: 1.5,
                        ),
                      );
                    }

                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: decoration,
                      child: Row(
                        children: [
                          Icon(
                            isCorrectAnswer
                                ? Icons.check_circle_rounded
                                : (isUserSelection
                                      ? Icons.cancel_rounded
                                      : Icons.radio_button_off_rounded),
                            size: 18,
                            color: itemColor,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isUserSelection || isCorrectAnswer
                                        ? widget.colorScheme.onSurface
                                        : widget.colorScheme.onSurfaceVariant,
                                    fontWeight:
                                        isUserSelection || isCorrectAnswer
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                                if (badge != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    badge,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: itemColor,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  if (widget.answer.explanation != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: widget.colorScheme.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: widget.colorScheme.primary.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.auto_awesome_rounded,
                                size: 16,
                                color: widget.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Explanation',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: widget.colorScheme.primary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.answer.explanation!,
                            style: TextStyle(
                              fontSize: 13,
                              color: widget.colorScheme.onSurfaceVariant,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
