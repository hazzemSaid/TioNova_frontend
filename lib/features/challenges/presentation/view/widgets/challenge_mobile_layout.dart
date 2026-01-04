import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/features/challenges/presentation/view/widgets/OptionCard.dart';
import 'package:tionova/features/challenges/presentation/view/widgets/challenge_create_card.dart';
import 'package:tionova/features/folder/presentation/view/widgets/BuildTap.dart';
import 'package:tionova/utils/widgets/page_header.dart';

class ChallengeMobileLayout extends StatelessWidget {
  final bool boolean;
  final ValueChanged<bool> onTabChanged;

  const ChallengeMobileLayout({
    super.key,
    required this.boolean,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final verticalSpacing = MediaQuery.of(context).size.height * 0.02;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: [
                SizedBox(height: verticalSpacing * 1.5),
                const PageHeader(
                  title: 'Challenges',
                  subtitle: 'Challenge your self and improve your skills',
                ),
                SizedBox(height: verticalSpacing * 1.5),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: colorScheme.outlineVariant.withOpacity(0.6),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: BuildTab(
                    label: 'Active Challenges',
                    icon: Icons.quiz_outlined,
                    isActive: boolean,
                    onTap: () => onTabChanged(true),
                  ),
                ),
                Expanded(
                  child: BuildTab(
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

        SliverToBoxAdapter(child: SizedBox(height: verticalSpacing * 1.5)),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                OptionCard(
                  gradientColors: const [Color(0xFF006B54), Color(0xFF00C46A)],
                  icon: Icons.qr_code_scanner,
                  iconGradient: const [Color(0x3300C46A), Color(0x1A00C46A)],
                  title: 'Scan QR Code',
                  subtitle: 'Quick access with your camera',
                  actionLabel: 'Scan',
                  onTap: () => context.push('/challenges/scan-qr'),
                ),
                const SizedBox(height: 16),
                OptionCard(
                  gradientColors: const [Color(0xFF0035D4), Color(0xFF0066FF)],
                  icon: Icons.person_add_alt_1_outlined,
                  iconGradient: const [Color(0x330066FF), Color(0x1A0066FF)],
                  title: 'Have an invite code?',
                  subtitle: 'Enter code manually to join',
                  actionLabel: 'Enter Code',
                  onTap: () => context.push('/enter-code'),
                  outlined: true,
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: verticalSpacing * 1.5)),

        const SliverToBoxAdapter(child: ChallengeMobileCreateCard()),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}
