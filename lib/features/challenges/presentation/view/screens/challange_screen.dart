import 'package:flutter/material.dart';
import 'package:tionova/core/utils/safe_context_mixin.dart';
import 'package:tionova/features/challenges/presentation/view/widgets/challenge_mobile_layout.dart';
import 'package:tionova/features/challenges/presentation/view/widgets/challenge_web_layout.dart';
import 'package:tionova/utils/no_glow_scroll_behavior.dart';

class ChallangeScreen extends StatefulWidget {
  const ChallangeScreen({super.key});

  @override
  State<ChallangeScreen> createState() => _ChallangeScreenState();
}

class _ChallangeScreenState extends State<ChallangeScreen>
    with SafeContextMixin {
  var boolean = true;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final isWeb = screenWidth > 800;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: const NoGlowScrollBehavior(),
          child: isWeb
              ? ChallengeWebLayout(
                  boolean: boolean,
                  onTabChanged: (value) => setState(() => boolean = value),
                )
              : ChallengeMobileLayout(
                  boolean: boolean,
                  onTabChanged: (value) => setState(() => boolean = value),
                ),
        ),
      ),
    );
  }
}
