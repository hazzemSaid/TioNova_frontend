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
                    const SizedBox(height: 20),
                    _buildTopThreePodium(),
                    const SizedBox(height: 32),
                    _buildTitle(),
                    const SizedBox(height: 8),
                    _buildSubtitle(),
                    const SizedBox(height: 24),
                    _buildPerformanceCard(),
                    const SizedBox(height: 24),
                    _buildFullRankings(),
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

  Widget _buildTopThreePodium() {
    if (leaderboard.length < 3) {
      return _buildTrophyIcon(); // Fallback to trophy if less than 3 players
    }

    final top3 = leaderboard.take(3).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place
          if (top3.length > 1)
            Expanded(
              child: _buildPodiumPlace(
                rank: 2,
                entry: top3[1],
                height: 100,
                medalColor: _silver,
              ),
            ),
          const SizedBox(width: 8),
          // 1st Place
          Expanded(
            child: _buildPodiumPlace(
              rank: 1,
              entry: top3[0],
              height: 130,
              medalColor: _gold,
            ),
          ),
          const SizedBox(width: 8),
          // 3rd Place
          if (top3.length > 2)
            Expanded(
              child: _buildPodiumPlace(
                rank: 3,
                entry: top3[2],
                height: 80,
                medalColor: _bronze,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPodiumPlace({
    required int rank,
    required Map<String, dynamic> entry,
    required double height,
    required Color medalColor,
  }) {
    final name = entry['name'] ?? entry['username'] ?? 'Player';
    final photoUrl = entry['photoUrl'] ?? '';
    final score = entry['score'] ?? 0;
    final isCurrentUser = rank == this.rank;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isCurrentUser ? _green : medalColor,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: medalColor.withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: photoUrl.isNotEmpty
              ? CircleAvatar(
                  radius: rank == 1 ? 36 : 30,
                  backgroundImage: NetworkImage(photoUrl),
                  backgroundColor: _cardBg,
                )
              : CircleAvatar(
                  radius: rank == 1 ? 36 : 30,
                  backgroundColor: medalColor.withOpacity(0.2),
                  child: Text(
                    name.length >= 2
                        ? name.substring(0, 2).toUpperCase()
                        : name.toUpperCase(),
                    style: TextStyle(
                      color: medalColor,
                      fontSize: rank == 1 ? 20 : 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 8),
        // Medal Icon
        Icon(
          rank == 1
              ? Icons.workspace_premium
              : rank == 2
              ? Icons.workspace_premium_outlined
              : Icons.military_tech_outlined,
          color: medalColor,
          size: rank == 1 ? 32 : 24,
        ),
        const SizedBox(height: 4),
        // Name
        Text(
          name,
          style: TextStyle(
            color: isCurrentUser ? _green : _textPrimary,
            fontSize: 13,
            fontWeight: isCurrentUser ? FontWeight.w700 : FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        // Score
        Text(
          '$score',
          style: TextStyle(
            color: medalColor,
            fontSize: rank == 1 ? 18 : 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        // Podium
        Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                medalColor.withOpacity(0.3),
                medalColor.withOpacity(0.1),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: medalColor.withOpacity(0.5), width: 2),
          ),
          child: Center(
            child: Text(
              '$rank',
              style: TextStyle(
                color: medalColor,
                fontSize: rank == 1 ? 48 : 36,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
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
      child: Icon(Icons.emoji_events, size: 64, color: _green),
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
        style: TextStyle(color: _textSecondary, fontSize: 16),
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
        Text(label, style: TextStyle(color: _textSecondary, fontSize: 13)),
      ],
    );
  }

  Widget _buildFullRankings() {
    // Show all rankings or rankings from 4th place onwards if there are more than 3
    final rankingsToShow = leaderboard.length > 3
        ? leaderboard.skip(3).toList()
        : leaderboard;

    if (rankingsToShow.isEmpty) {
      return const SizedBox.shrink(); // Don't show if no additional rankings
    }

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
              Icon(Icons.leaderboard_rounded, color: _green, size: 20),
              const SizedBox(width: 8),
              Text(
                leaderboard.length > 3 ? 'Other Rankings' : 'Rankings',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...rankingsToShow.map((entry) {
            final index = leaderboard.indexOf(entry);
            final currentRank = index + 1;
            final name =
                entry['name'] ?? entry['username'] ?? 'Player ${index + 1}';
            final photoUrl = entry['photoUrl'] ?? '';
            final score = entry['score'] ?? 0;
            final time = entry['time'] ?? '0s';
            final isCurrentUser = currentRank == rank;

            return _buildRankingEntry(
              rank: currentRank,
              name: name,
              photoUrl: photoUrl,
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
    required String name,
    String? photoUrl,
    required int score,
    required String time,
    required bool isCurrentUser,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentUser ? _green.withOpacity(0.1) : _panelBg,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser ? Border.all(color: _green, width: 2) : null,
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCurrentUser ? _green.withOpacity(0.2) : _cardBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  color: isCurrentUser ? _green : _textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Avatar: Photo or Initials
          if (photoUrl != null && photoUrl.isNotEmpty)
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(photoUrl),
              backgroundColor: _cardBg,
            )
          else
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  name.length >= 2
                      ? name.substring(0, 2).toUpperCase()
                      : name.toUpperCase(),
                  style: TextStyle(
                    color: _textSecondary,
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
                  name,
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Time: $time',
                  style: TextStyle(color: _textSecondary, fontSize: 12),
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
    final message =
        '''
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
