import 'package:flutter/material.dart';

class LeaderboardEntry extends StatelessWidget {
  final int rank;
  final String username;
  final int score;
  final String? userId;
  final String? currentUserId;
  final String? photoUrl;

  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentGreen;
  final Color bg;

  const LeaderboardEntry({
    super.key,
    required this.rank,
    required this.username,
    required this.score,
    this.userId,
    this.currentUserId,
    this.photoUrl,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentGreen,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMedalist = rank <= 3;
    final bool isCurrentUser = userId != null && userId == currentUserId;
    final Color medalColor = rank == 1
        ? const Color(0xFFFFD700)
        : rank == 2
        ? const Color(0xFFC0C0C0)
        : const Color(0xFFCD7F32);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: isCurrentUser ? Border.all(color: accentGreen, width: 2) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isMedalist ? medalColor.withOpacity(0.2) : bg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  color: isMedalist ? medalColor : textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Avatar or initials
          if (photoUrl != null && photoUrl!.isNotEmpty)
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(photoUrl!),
              backgroundColor: bg,
            )
          else
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCurrentUser ? accentGreen.withOpacity(0.2) : bg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  username.length > 2
                      ? username.substring(0, 2).toUpperCase()
                      : username.toUpperCase(),
                  style: TextStyle(
                    color: isCurrentUser ? accentGreen : textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              username,
              style: TextStyle(
                color: isCurrentUser ? accentGreen : textPrimary,
                fontSize: 15,
                fontWeight: isCurrentUser ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            '$score',
            style: TextStyle(
              color: accentGreen,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.circle, color: accentGreen, size: 8),
        ],
      ),
    );
  }
}
