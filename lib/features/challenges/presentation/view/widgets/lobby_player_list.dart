import 'package:flutter/material.dart';
import 'package:tionova/features/challenges/presentation/view/utils/challenge_lobby_theme.dart';

class LobbyPlayerList extends StatelessWidget {
  final int participantCount;
  final List<Map<String, dynamic>> participants;

  const LobbyPlayerList({
    super.key,
    required this.participantCount,
    required this.participants,
  });

  @override
  Widget build(BuildContext context) {
    final activeParticipants = participants
        .where((p) => p['active'] == true)
        .toList();

    final containerPadding = ChallengeLobbyTheme.getResponsiveValue(
      context,
      mobile: 16,
      tablet: 20,
    );
    final maxListHeight = MediaQuery.of(context).size.height * 0.25;
    final fontSize = ChallengeLobbyTheme.getResponsiveValue(
      context,
      mobile: 18,
      tablet: 20,
    );

    return Container(
      padding: EdgeInsets.all(containerPadding),
      decoration: BoxDecoration(
        color: ChallengeLobbyTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ChallengeLobbyTheme.brandGreen.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.people_rounded,
                color: ChallengeLobbyTheme.brandGreen,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                '$participantCount players',
                style: TextStyle(
                  color: ChallengeLobbyTheme.textPrimary,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: ChallengeLobbyTheme.brandGreen,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          if (activeParticipants.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              constraints: BoxConstraints(maxHeight: maxListHeight),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ChallengeLobbyTheme.panelBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Players in Lobby',
                      style: TextStyle(
                        color: ChallengeLobbyTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: activeParticipants.map((participant) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: ChallengeLobbyTheme.cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: ChallengeLobbyTheme.brandGreen.withOpacity(
                                0.2,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: ChallengeLobbyTheme.brandGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  participant['username'] ?? 'Unknown',
                                  style: const TextStyle(
                                    color: ChallengeLobbyTheme.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
