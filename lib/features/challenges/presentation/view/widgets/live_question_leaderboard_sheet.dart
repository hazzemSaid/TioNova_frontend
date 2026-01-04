import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/challenges/presentation/view/utils/live_question_theme.dart';
import 'package:tionova/features/challenges/presentation/view/widgets/leaderboard_entry.dart';

class LiveQuestionLeaderboardSheet extends StatelessWidget {
  final List<Map<String, dynamic>> leaderboard;

  const LiveQuestionLeaderboardSheet({super.key, required this.leaderboard});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: const [
              Icon(
                Icons.emoji_events,
                color: LiveQuestionTheme.green,
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Live Scoreboard',
                style: TextStyle(
                  color: LiveQuestionTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (leaderboard.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'No rankings yet',
                style: TextStyle(color: LiveQuestionTheme.textSecondary),
              ),
            )
          else ...[
            // Get current user ID
            Builder(
              builder: (context) {
                String? currentUserId;
                final state = context.read<AuthCubit>().state;
                if (state is AuthSuccess) {
                  currentUserId = state.user.id;
                }

                return Column(
                  children: leaderboard.take(5).map((entry) {
                    final rank = (leaderboard.indexOf(entry) + 1);
                    return LeaderboardEntry(
                      rank: rank,
                      username: entry['name'] ?? entry['username'] ?? 'Unknown',
                      score: entry['score'] ?? 0,
                      userId: entry['userId'],
                      currentUserId: currentUserId,
                      photoUrl: entry['photoUrl'],
                      cardBg: LiveQuestionTheme.cardBg,
                      textPrimary: LiveQuestionTheme.textPrimary,
                      textSecondary: LiveQuestionTheme.textSecondary,
                      accentGreen: LiveQuestionTheme.green,
                      bg: LiveQuestionTheme.bg,
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
