import 'package:flutter/material.dart';

class Achievement {
  final String title;
  final String description;
  final bool isEarned;

  Achievement({
    required this.title,
    required this.description,
    required this.isEarned,
  });
}

class AchievementsSection extends StatelessWidget {
  final List<Achievement> achievements;

  const AchievementsSection({Key? key, required this.achievements})
    : super(key: key);

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
                Icons.emoji_events_outlined,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Achievements',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Achievements List
          ...achievements.map((achievement) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildAchievementItem(achievement),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(Achievement achievement) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: achievement.isEarned
            ? const Color(0xFF2C2C2E)
            : const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Trophy Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: achievement.isEarned
                  ? const Color(0xFFFF8C42).withOpacity(0.2)
                  : const Color(0xFF1C1C1E),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events_outlined,
              color: achievement.isEarned
                  ? const Color(0xFFFF8C42)
                  : const Color(0xFF6A6A6A),
              size: 18,
            ),
          ),

          const SizedBox(width: 10),

          // Achievement Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(
                    color: achievement.isEarned
                        ? Colors.white
                        : const Color(0xFF8E8E93),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  achievement.description,
                  style: TextStyle(
                    color: achievement.isEarned
                        ? const Color(0xFF8E8E93)
                        : const Color(0xFF6A6A6A),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Earned Badge
          if (achievement.isEarned)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF34C759).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Earned',
                style: TextStyle(
                  color: Color(0xFF34C759),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
