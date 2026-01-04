import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/features/challenges/presentation/view/utils/challenge_lobby_theme.dart';

class LobbyLeaveButton extends StatelessWidget {
  const LobbyLeaveButton({super.key});

  @override
  Widget build(BuildContext context) {
    final buttonHeight = ChallengeLobbyTheme.getResponsiveValue(
      context,
      mobile: 48,
      tablet: 52,
    );

    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: OutlinedButton.icon(
        onPressed: () => showLeaveDialog(context),
        icon: const Icon(Icons.exit_to_app, size: 20),
        label: const Text(
          'Leave Challenge',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: ChallengeLobbyTheme.textSecondary,
          side: const BorderSide(color: ChallengeLobbyTheme.cardBg, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static void showLeaveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: ChallengeLobbyTheme.cardBg,
        title: const Text(
          'Leave Challenge?',
          style: TextStyle(color: ChallengeLobbyTheme.textPrimary),
        ),
        content: const Text(
          'Are you sure you want to leave this challenge?',
          style: TextStyle(color: ChallengeLobbyTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(color: ChallengeLobbyTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Close dialog
              context.go('/challenges'); // Navigate back to challenges screen
            },
            child: const Text('Leave', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
