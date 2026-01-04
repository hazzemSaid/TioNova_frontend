import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/features/challenges/presentation/view/widgets/challenge_create_card.dart';
import 'package:tionova/features/challenges/presentation/view/widgets/challenge_web_option_card.dart';
import 'package:tionova/features/challenges/presentation/view/widgets/challenge_web_tab.dart';

class ChallengeWebLayout extends StatelessWidget {
  final bool boolean;
  final ValueChanged<bool> onTabChanged;

  const ChallengeWebLayout({
    super.key,
    required this.boolean,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxContentWidth = 1200.0;
    final horizontalPadding = screenWidth > maxContentWidth
        ? (screenWidth - maxContentWidth) / 2
        : 48.0;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        // Header Section
        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              40,
              horizontalPadding,
              32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Challenges',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: colorScheme.onBackground,
                    fontWeight: FontWeight.bold,
                    fontSize: 36,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Challenge yourself and improve your skills',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Tab Switcher
        SliverToBoxAdapter(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Row(
              children: [
                Flexible(
                  child: ChallengeWebTab(
                    label: 'Active Challenges',
                    icon: Icons.quiz_outlined,
                    isActive: boolean,
                    onTap: () => onTabChanged(true),
                  ),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: ChallengeWebTab(
                    label: 'Leaderboard',
                    icon: Icons.leaderboard_outlined,
                    isActive: !boolean,
                    onTap: () => onTabChanged(false),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),

        // Main Content Grid
        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column - Action Cards
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      ChallengeWebOptionCard(
                        gradientColors: const [
                          Color(0xFF006B54),
                          Color(0xFF00C46A),
                        ],
                        icon: Icons.qr_code_scanner,
                        title: 'Scan QR Code',
                        subtitle: 'Quick access with your camera',
                        actionLabel: 'Start Scanning',
                        onTap: () => context.push('/challenges/scan-qr'),
                      ),
                      const SizedBox(height: 24),
                      ChallengeWebOptionCard(
                        gradientColors: const [
                          Color(0xFF0035D4),
                          Color(0xFF0066FF),
                        ],
                        icon: Icons.person_add_alt_1_outlined,
                        title: 'Have an Invite Code?',
                        subtitle: 'Enter code manually to join',
                        actionLabel: 'Enter Code',
                        onTap: () => context.push('/enter-code'),
                        outlined: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Right Column - Create Challenge
                const Expanded(flex: 1, child: ChallengeWebCreateCard()),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 48)),
      ],
    );
  }
}
