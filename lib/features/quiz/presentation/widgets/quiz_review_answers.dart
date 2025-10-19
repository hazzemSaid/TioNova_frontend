import 'package:flutter/material.dart';

class QuizReviewAnswers extends StatelessWidget {
  final List<Map<String, dynamic>> questions;
  final List<int?> answers;
  final VoidCallback onSubmit;
  final VoidCallback onContinue;

  const QuizReviewAnswers({
    super.key,
    required this.questions,
    required this.answers,
    required this.onSubmit,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final answeredCount = answers.where((answer) => answer != null).length;
    final unansweredCount = questions.length - answeredCount;
    final size = MediaQuery.of(context).size;
    final isWeb = size.width > 900;

    if (isWeb) {
      return _buildWebLayout(context, answeredCount, unansweredCount);
    }

    return CustomScrollView(
      slivers: [
        // Stats Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Answered Section
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '$answeredCount/${questions.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Answered',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  // Divider
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey.withOpacity(0.3),
                  ),

                  // Unanswered Section
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '$unansweredCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Unanswered',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),

        // Questions List
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverList.builder(
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final isAnswered = answers[index] != null;

              return Container(
                margin: const EdgeInsets.only(bottom: 12.0),
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Question ${index + 1}',
                            style: const TextStyle(
                              color: Color(0xFFFE9500),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            questions[index]['question'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.4,
                            ),
                          ),
                          if (isAnswered) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Your answer: ${questions[index]['options'][answers[index]!]}',
                              style: const TextStyle(
                                color: Color(0xFF34C759),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isAnswered
                              ? const Color(0xFF34C759)
                              : Colors.grey,
                          width: isAnswered ? 0 : 2,
                        ),
                        color: isAnswered
                            ? const Color(0xFF34C759)
                            : Colors.transparent,
                      ),
                      child: isAnswered
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Action Buttons Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 24),

                // Submit Quiz Button
                Container(
                  width: double.infinity,
                  height: 52,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ElevatedButton(
                    onPressed: onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Submit Quiz',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Continue Answering Button
                Container(
                  width: double.infinity,
                  height: 52,
                  margin: const EdgeInsets.only(bottom: 32),
                  child: ElevatedButton(
                    onPressed: onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1C1C1E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: BorderSide(
                          color: Colors.grey.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Continue Answering',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebLayout(
    BuildContext context,
    int answeredCount,
    int unansweredCount,
  ) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side - Questions list
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Text(
                      'Review Answers',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Questions grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 2.5,
                        ),
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      final isAnswered = answers[index] != null;

                      return Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F0F0F),
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: const Color(0xFF2A2A2A),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Question ${index + 1}',
                                    style: const TextStyle(
                                      color: Color(0xFFFE9500),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    questions[index]['question'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (isAnswered) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      'Answered',
                                      style: TextStyle(
                                        color: const Color(0xFF22C55E),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isAnswered
                                      ? const Color(0xFF22C55E)
                                      : const Color(0xFF4A4A4A),
                                  width: isAnswered ? 0 : 2,
                                ),
                                color: isAnswered
                                    ? const Color(0xFF22C55E)
                                    : Colors.transparent,
                              ),
                              child: isAnswered
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 18,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onContinue,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFF2A2A2A)),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Continue Answering',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Submit Quiz',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),
          // Right side - Stats
          Container(
            width: 320,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F0F),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Quiz Summary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                _buildStatRow(
                  'Answered',
                  '$answeredCount / ${questions.length}',
                  const Color(0xFF22C55E),
                ),
                const SizedBox(height: 16),
                _buildStatRow(
                  'Unanswered',
                  '$unansweredCount',
                  const Color(0xFFFE9500),
                ),
                const SizedBox(height: 16),
                _buildStatRow(
                  'Total Questions',
                  '${questions.length}',
                  Colors.white,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFFFE9500),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Make sure to answer all questions before submitting',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
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

  Widget _buildStatRow(String label, String value, Color valueColor) {
    return Row(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
