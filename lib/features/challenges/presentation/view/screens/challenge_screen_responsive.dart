import 'package:flutter/material.dart';
import 'package:tionova/features/challenges/presentation/view/screens/challange_screen.dart';
import 'package:tionova/features/challenges/presentation/view/screens/challenges_web_layout.dart';

/// Responsive wrapper for Challenge screens
/// Automatically switches between mobile (ChallengeScreen) and web (ChallengesWebLayout)
/// based on screen width
class ChallengeScreenResponsive extends StatelessWidget {
  const ChallengeScreenResponsive({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Use web layout for screens > 1024px (tablets and desktops)
    // Use mobile layout for screens <= 1024px (phones and small tablets)
    if (screenWidth > 1024) {
      return const ChallengesWebLayout();
    } else {
      return const ChallangeScreen();
    }
  }
}
