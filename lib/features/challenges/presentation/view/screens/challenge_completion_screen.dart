import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChallengeCompletionScreen extends StatelessWidget {
  final String challengeName;
  final int finalScore;
  final int correctAnswers;
  final int totalQuestions;
  final double accuracy;
  final int rank;
  final List<Map<String, dynamic>> leaderboard;

  const ChallengeCompletionScreen({
    super.key,
    required this.challengeName,
    required this.finalScore,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.accuracy,
    required this.rank,
    required this.leaderboard,
  });

  Color get _bg => const Color(0xFF000000);
  Color get _cardBg => const Color(0xFF1C1C1E);
  Color get _panelBg => const Color(0xFF0E0E10);
  Color get _textPrimary => const Color(0xFFFFFFFF);
  Color get _textSecondary => const Color(0xFF8E8E93);
  Color get _green => const Color.fromRGBO(0, 153, 102, 1);
  Color get _gold => const Color(0xFFFFD700);
  Color get _silver => const Color(0xFFC0C0C0);
  Color get _bronze => const Color(0xFFCD7F32);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    _buildTrophyIcon(),
                    const SizedBox(height: 24),
                    _buildTitle(),
                    const SizedBox(height: 8),
                    _buildSubtitle(),
                    const SizedBox(height: 32),
                    _buildPerformanceCard(),
                    const SizedBox(height: 24),
                    _buildFinalRankings(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTrophyIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: _green.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.emoji_events,
        size: 64,
        color: _green,
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        'Challenge Complete!',
        style: TextStyle(
          color: _textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w800,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        challengeName,
        style: TextStyle(
          color: _textSecondary,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPerformanceCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _panelBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _green.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            'Your Performance',
            style: TextStyle(
              color: _textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPerformanceStat(
                label: 'Points',
                value: '$finalScore',
                color: _green,
              ),
              _buildPerformanceStat(
                label: 'Rank',
                value: '#$rank',
                color: rank <= 3 ? _gold : _textPrimary,
              ),
              _buildPerformanceStat(
                label: 'Accuracy',
                value: '${accuracy.toStringAsFixed(0)}%',
                color: _green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceStat({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 32,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: _textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildFinalRankings() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, color: _gold, size: 20),
              const SizedBox(width: 8),
              Text(
                'Final Rankings',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (leaderboard.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No rankings available',
                  style: TextStyle(color: _textSecondary),
                ),
              ),
            )
          else
            ...leaderboard.take(5).map((entry) {
              final index = leaderboard.indexOf(entry);
              final currentRank = index + 1;
              final username = entry['username'] ?? 'Player ${index + 1}';
              final score = entry['score'] ?? 0;
              final time = entry['time'] ?? '0s';
              final isCurrentUser = currentRank == rank;

              return _buildRankingEntry(
                rank: currentRank,
                username: username,
                score: score,
                time: time,
                isCurrentUser: isCurrentUser,
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildRankingEntry({
    required int rank,
    required String username,
    required int score,
    required String time,
    required bool isCurrentUser,
  }) {
    final isMedalist = rank <= 3;
    final medalColor = rank == 1
        ? _gold
        : rank == 2
            ? _silver
            : _bronze;

    IconData? medalIcon;
    if (rank == 1) {
      medalIcon = Icons.workspace_premium;
    } else if (rank == 2) {
      medalIcon = Icons.workspace_premium_outlined;
    } else if (rank == 3) {
      medalIcon = Icons.military_tech_outlined;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentUser ? _green.withOpacity(0.1) : _panelBg,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser
            ? Border.all(color: _green, width: 2)
            : null,
      ),
      child: Row(
        children: [
          if (isMedalist && medalIcon != null)
            Icon(medalIcon, color: medalColor, size: 28)
          else
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 12),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isMedalist ? medalColor.withOpacity(0.2) : _cardBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                username.length >= 2
                    ? username.substring(0, 2).toUpperCase()
                    : username.toUpperCase(),
                style: TextStyle(
                  color: isMedalist ? medalColor : _textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Time: $time',
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$score',
            style: TextStyle(
              color: _green,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Play again functionality
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.replay_rounded, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Play Again',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () {
                // TODO: Share results functionality
                _shareResults();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: _textPrimary,
                side: BorderSide(color: _cardBg, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.share_rounded, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Share Results',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _shareResults() {
    // Share functionality
    final message = '''
🏆 Challenge Complete!

Challenge: $challengeName
Score: $finalScore points
Rank: #$rank
Accuracy: ${accuracy.toStringAsFixed(0)}%

Join me on TioNova!
    ''';

    Clipboard.setData(ClipboardData(text: message));
  }
}
