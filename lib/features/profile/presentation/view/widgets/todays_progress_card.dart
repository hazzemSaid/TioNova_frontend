import 'package:flutter/material.dart';

class TodaysProgressCard extends StatelessWidget {
  final int dayStreak;
  final int chaptersRead;
  final int quizzesTaken;
  final String studyTime;

  const TodaysProgressCard({
    Key? key,
    required this.dayStreak,
    required this.chaptersRead,
    required this.quizzesTaken,
    required this.studyTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1C1C1E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: const [
                Icon(Icons.trending_up, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  "Today's Progress",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Day Streak Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF4A2B1A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Text(
                  '$dayStreak',
                  style: const TextStyle(
                    color: Color(0xFFFF8C42),
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Day Streak',
                        style: TextStyle(
                          color: Color(0xFFFF8C42),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Don't lose your streak!",
                        style: TextStyle(
                          color: Color(0xFFB8860B),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Stats Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('$chaptersRead', 'Chapters Read'),
                _buildStatItem('$quizzesTaken', 'Quizzes Taken'),
                _buildStatItem(studyTime, 'Study Time'),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Encouragement Text
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Keep up the great work! 💪',
                  style: TextStyle(color: Color(0xFF8E8E93), fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 12),
        ),
      ],
    );
  }
}
