import 'package:flutter/material.dart';
import 'package:tionova/features/challenges/presentation/view/utils/challenge_lobby_theme.dart';

class LobbyTrophyIcon extends StatelessWidget {
  const LobbyTrophyIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final trophySize = ChallengeLobbyTheme.getResponsiveValue(
      context,
      mobile: 100,
      tablet: 120,
    );
    final iconSize = ChallengeLobbyTheme.getResponsiveValue(
      context,
      mobile: 56,
      tablet: 64,
    );

    return Container(
      width: trophySize,
      height: trophySize,
      decoration: BoxDecoration(
        color: ChallengeLobbyTheme.brandGreen.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.emoji_events_outlined,
        size: iconSize,
        color: ChallengeLobbyTheme.brandGreen,
      ),
    );
  }
}
