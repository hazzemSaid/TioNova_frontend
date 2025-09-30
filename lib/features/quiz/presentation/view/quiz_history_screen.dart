// features/quiz/presentation/view/quiz_history_screen.dart
import 'package:flutter/material.dart';

class QuizHistoryScreen extends StatelessWidget {
  const QuizHistoryScreen({super.key});

  Map<String, dynamic> get _staticData => {
    "success": true,
    "message": "Quiz history retrieved successfully",
    "history": {
      "attempts": [
        {
          "startedAt": "2024-01-15T17:30:00.000Z",
          "completedAt": "2024-01-15T17:38:32.000Z",
          "totalQuestions": 10,
          "correct": 8,
          "degree": 80,
          "state": "Passed",
          "timeSpent": "8m 32s",
          "score": 85,
        },
        {
          "startedAt": "2024-01-14T14:15:00.000Z",
          "completedAt": "2024-01-14T14:27:45.000Z",
          "totalQuestions": 10,
          "correct": 7,
          "degree": 70,
          "state": "Passed",
          "timeSpent": "12m 45s",
          "score": 75,
        },
        {
          "startedAt": "2024-01-13T16:20:00.000Z",
          "completedAt": "2024-01-13T16:35:10.000Z",
          "totalQuestions": 10,
          "correct": 6,
          "degree": 60,
          "state": "Failed",
          "timeSpent": "15m 10s",
          "score": 60,
        },
      ],
      "overallStatus": "Passed",
      "overallScore": 73,
      "totalAttempts": 5,
      "bestScore": 90,
      "averageScore": 70,
      "passRate": 60,
    },
  };

  // Exact colors from the images
  Color get _bg => const Color(0xFF000000);
  Color get _cardBg => const Color(0xFF1C1C1E);
  Color get _textPrimary => const Color(0xFFFFFFFF);
  Color get _textSecondary => const Color(0xFF8E8E93);
  Color get _green => const Color(0xFF30D158);
  Color get _orange => const Color(0xFFFF9500);
  Color get _red => const Color(0xFFFF3B30);
  Color get _blue => const Color(0xFF007AFF);
  Color get _purple => const Color(0xFFAF52DE);
  Color get _teal => const Color(0xFF5AC8FA);

  @override
  Widget build(BuildContext context) {
    final history = _staticData["history"] as Map<String, dynamic>;
    final attempts = List<Map<String, dynamic>>.from(history["attempts"]);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: _textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'Quiz History',
              style: TextStyle(
                color: _textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Binary Search Trees',
              style: TextStyle(
                color: _textSecondary,
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
              onPressed: () {},
              icon: Icon(Icons.add, size: 16, color: _textPrimary),
              label: Text(
                'New Quiz',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _cardBg,
                foregroundColor: _textPrimary,
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
            // Metrics Grid
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
                  iconColor: _blue,
                  value: '5',
                  label: 'Total Attempts',
                ),
                _MetricCard(
                  icon: Icons.emoji_events,
                  iconColor: _green,
                  value: '90%',
                  label: 'Best Score',
                ),
                _MetricCard(
                  icon: Icons.trending_up,
                  iconColor: _purple,
                  value: '70%',
                  label: 'Average Score',
                ),
                _MetricCard(
                  icon: Icons.radio_button_checked,
                  iconColor: _orange,
                  value: '60%',
                  label: 'Pass Rate',
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Recent Attempts Header
            Row(
              children: [
                Icon(Icons.schedule, color: _textSecondary, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Recent Attempts',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Attempts List
            ...attempts.asMap().entries.map((entry) {
              final index = entry.key;
              final attempt = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == attempts.length - 1 ? 0 : 12,
                ),
                child: _AttemptCard(attempt: attempt),
              );
            }).toList(),
          ],
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

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8E8E93),
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
  final Map<String, dynamic> attempt;

  const _AttemptCard({required this.attempt});

  Color get _green => const Color(0xFF30D158);
  Color get _red => const Color(0xFFFF3B30);

  @override
  Widget build(BuildContext context) {
    final degree = attempt["degree"] as int;
    final total = attempt["totalQuestions"] as int;
    final correct = attempt["correct"] as int;
    final state = (attempt["state"] as String).toLowerCase();
    final passed = state == 'passed';
    final DateTime started = DateTime.parse(attempt["startedAt"]);
    final timeSpent = attempt["timeSpent"] as String;
    final score = attempt["score"] as int;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizReviewScreen(attempt: attempt),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _StatusChip(passed: passed),
                const Spacer(),
                Text(
                  _formatDate(started),
                  style: const TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.visibility_outlined,
                  color: const Color(0xFF8E8E93),
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '$degree%',
              style: TextStyle(
                color: passed ? _green : _red,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$correct/$total correct',
              style: const TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.schedule_outlined,
                  color: const Color(0xFF8E8E93),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  timeSpent,
                  style: const TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Text(
                  'Score: $score/100',
                  style: const TextStyle(
                    color: Color(0xFF8E8E93),
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

  const _StatusChip({required this.passed});

  @override
  Widget build(BuildContext context) {
    final color = passed ? const Color(0xFF30D158) : const Color(0xFFFF3B30);
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
  final Map<String, dynamic> attempt;

  const QuizReviewScreen({super.key, required this.attempt});

  Color get _bg => const Color(0xFF000000);
  Color get _cardBg => const Color(0xFF1C1C1E);
  Color get _green => const Color(0xFF30D158);
  Color get _red => const Color(0xFFFF3B30);
  Color get _blue => const Color(0xFF007AFF);
  Color get _purple => const Color(0xFFAF52DE);

  @override
  Widget build(BuildContext context) {
    final degree = attempt["degree"] as int;
    final total = attempt["totalQuestions"] as int;
    final correct = attempt["correct"] as int;
    final incorrect = total - correct;
    final timeSpent = attempt["timeSpent"] as String;
    final score = attempt["score"] as int;
    final passed = (attempt["state"] as String).toLowerCase() == 'passed';
    final DateTime started = DateTime.parse(attempt["startedAt"]);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: const [
            Text(
              'Quiz Review',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Binary Search Trees',
              style: TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white, size: 20),
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
                backgroundColor: _cardBg,
                foregroundColor: Colors.white,
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
                color: _cardBg,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _StatusChip(passed: passed),
                  const SizedBox(height: 16),
                  Text(
                    '$degree%',
                    style: TextStyle(
                      color: passed ? _green : _red,
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDateTime(started),
                    style: const TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Progress bar
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2E),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      widthFactor: degree / 100,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          color: passed ? _green : _red,
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
                  iconColor: _blue,
                  value: score.toString(),
                  label: 'Total Score',
                ),
                _StatCard(
                  icon: Icons.check_circle,
                  iconColor: _green,
                  value: correct.toString(),
                  label: 'Correct',
                ),
                _StatCard(
                  icon: Icons.cancel,
                  iconColor: _red,
                  value: incorrect.toString(),
                  label: 'Incorrect',
                ),
                _StatCard(
                  icon: Icons.schedule,
                  iconColor: _purple,
                  value: timeSpent,
                  label: 'Time Spent',
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Question Review Header
            const Text(
              'Question Review',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Review your answers and see detailed explanations',
              style: TextStyle(color: Color(0xFF8E8E93), fontSize: 15),
            ),

            const SizedBox(height: 20),

            // Sample Questions (since we don't have real data)
            _QuestionCard(
              questionNumber: 1,
              question:
                  'What is the primary function of mitochondria in cellular respiration?',
              userAnswer: 'Energy production through ATP synthesis',
              isCorrect: true,
            ),

            const SizedBox(height: 12),

            _QuestionCard(
              questionNumber: 5,
              question: 'What is the role of ribosomes in the cell?',
              userAnswer: 'Lipid synthesis',
              correctAnswer: 'Protein synthesis',
              explanation:
                  'Ribosomes are the cellular machinery responsible for protein synthesis, translating mRNA into proteins.',
              isCorrect: false,
            ),
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

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13),
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

  const _QuestionCard({
    required this.questionNumber,
    required this.question,
    required this.userAnswer,
    this.correctAnswer,
    this.explanation,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isCorrect
        ? const Color(0xFF30D158)
        : const Color(0xFFFF3B30);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
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
                style: const TextStyle(
                  color: Colors.white,
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCorrect
                  ? const Color(0xFF30D158).withOpacity(0.1)
                  : const Color(0xFFFF3B30).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCorrect
                    ? const Color(0xFF30D158).withOpacity(0.3)
                    : const Color(0xFFFF3B30).withOpacity(0.3),
              ),
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
                  userAnswer,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
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
                color: const Color(0xFF30D158).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF30D158).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Correct Answer:',
                    style: TextStyle(
                      color: Color(0xFF30D158),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    correctAnswer!,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
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
                color: const Color(0xFF007AFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF007AFF).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Explanation:',
                    style: TextStyle(
                      color: Color(0xFF007AFF),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    explanation!,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
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
