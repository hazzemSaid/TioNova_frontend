import 'package:flutter/material.dart';

class AllTimeStatistics extends StatelessWidget {
  final int chapters;
  final int quizzes;
  final String studyTime;
  final int achievements;

  const AllTimeStatistics({
    Key? key,
    required this.chapters,
    required this.quizzes,
    required this.studyTime,
    required this.achievements,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1C1C1E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.analytics_outlined,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'All-Time Statistics',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // First Row
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '$chapters',
                  'Chapters',
                  Icons.menu_book_outlined,
                  const Color(0xFF007AFF),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildStatItem(
                  '$quizzes',
                  'Quizzes',
                  Icons.quiz_outlined,
                  const Color(0xFF34C759),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Second Row
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  studyTime,
                  'Studied',
                  Icons.access_time_outlined,
                  const Color(0xFF8E44AD),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildStatItem(
                  '$achievements',
                  'Achievements',
                  Icons.emoji_events_outlined,
                  const Color(0xFFFF8C42),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String value,
    String label,
    IconData icon,
    Color iconColor,
  ) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
