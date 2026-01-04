import 'package:flutter/material.dart';
import 'package:tionova/features/challenges/presentation/view/utils/challenge_lobby_theme.dart';

class LobbyStatusSection extends StatelessWidget {
  final String challengeName;
  final bool isSmallScreen;

  const LobbyStatusSection({
    super.key,
    required this.challengeName,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTitle(context),
        SizedBox(
          height: ChallengeLobbyTheme.getResponsiveValue(
            context,
            mobile: 12,
            tablet: 16,
          ),
        ),
        _buildWaitingMessage(context),
        SizedBox(
          height: ChallengeLobbyTheme.getResponsiveValue(
            context,
            mobile: 24,
            tablet: 48,
          ),
        ),
        _buildLoadingIndicator(context),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    final fontSize = ChallengeLobbyTheme.getResponsiveValue(
      context,
      mobile: 28,
      tablet: 32,
    );

    return Text(
      'Get Ready!',
      style: TextStyle(
        color: ChallengeLobbyTheme.textPrimary,
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildWaitingMessage(BuildContext context) {
    final titleFontSize = ChallengeLobbyTheme.getResponsiveValue(
      context,
      mobile: 16,
      tablet: 18,
    );
    final subtitleFontSize = ChallengeLobbyTheme.getResponsiveValue(
      context,
      mobile: 13,
      tablet: 15,
    );

    return Column(
      children: [
        Text(
          challengeName,
          style: TextStyle(
            color: ChallengeLobbyTheme.textPrimary,
            fontSize: titleFontSize,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Waiting for the host to start the challenge...',
          style: TextStyle(
            color: ChallengeLobbyTheme.textSecondary,
            fontSize: subtitleFontSize,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    final loaderSize = ChallengeLobbyTheme.getResponsiveValue(
      context,
      mobile: 36,
      tablet: 40,
    );
    final fontSize = ChallengeLobbyTheme.getResponsiveValue(
      context,
      mobile: 12,
      tablet: 14,
    );

    return Column(
      children: [
        SizedBox(
          width: loaderSize,
          height: loaderSize,
          child: const CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              ChallengeLobbyTheme.brandGreen,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Connected',
          style: TextStyle(
            color: ChallengeLobbyTheme.brandGreen,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
