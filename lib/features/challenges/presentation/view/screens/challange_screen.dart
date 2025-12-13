import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/core/utils/safe_context_mixin.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/challenges/presentation/bloc/challenge_cubit.dart';
import 'package:tionova/features/challenges/presentation/view/widgets/OptionCard.dart';
import 'package:tionova/features/folder/presentation/bloc/chapter/chapter_cubit.dart';
import 'package:tionova/features/folder/presentation/bloc/folder/folder_cubit.dart';
import 'package:tionova/features/folder/presentation/view/widgets/BuildTap.dart';
import 'package:tionova/utils/no_glow_scroll_behavior.dart';
import 'package:tionova/utils/widgets/page_header.dart';

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
    final isTablet = screenWidth > 600 && screenWidth <= 800;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: const NoGlowScrollBehavior(),
          child: isWeb ? _buildWebLayout(context) : _buildMobileLayout(context),
        ),
      ),
    );
  }

  // Web Layout for larger screens
  Widget _buildWebLayout(BuildContext context) {
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
                  child: _buildWebTab(
                    context,
                    label: 'Active Challenges',
                    icon: Icons.quiz_outlined,
                    isActive: boolean,
                    onTap: () => setState(() => boolean = true),
                  ),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: _buildWebTab(
                    context,
                    label: 'Leaderboard',
                    icon: Icons.leaderboard_outlined,
                    isActive: !boolean,
                    onTap: () => setState(() => boolean = false),
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(child: const SizedBox(height: 40)),

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
                      _buildWebOptionCard(
                        context,
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
                      _buildWebOptionCard(
                        context,
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
                Expanded(flex: 1, child: _buildWebCreateChallengeCard(context)),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(child: const SizedBox(height: 48)),
      ],
    );
  }

  // Mobile Layout
  Widget _buildMobileLayout(BuildContext context) {
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
                    onTap: () => setState(() => boolean = true),
                  ),
                ),
                Expanded(
                  child: BuildTab(
                    label: 'Leaderboard',
                    icon: Icons.leaderboard_outlined,
                    isActive: !boolean,
                    onTap: () => setState(() => boolean = false),
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

        SliverToBoxAdapter(child: _buildMobileCreateChallengeCard(context)),

        SliverToBoxAdapter(child: const SizedBox(height: 24)),
      ],
    );
  }

  // Web Tab Widget
  Widget _buildWebTab(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: isActive ? colorScheme.primaryContainer : colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? colorScheme.primary.withOpacity(0.3)
                : colorScheme.outlineVariant.withOpacity(0.5),
            width: isActive ? 2 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                color: isActive ? colorScheme.primary : colorScheme.onSurface,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Web Option Card
  Widget _buildWebOptionCard(
    BuildContext context, {
    required List<Color> gradientColors,
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onTap,
    bool outlined = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: outlined
            ? null
            : LinearGradient(
                colors: gradientColors.map((c) => c.withOpacity(0.05)).toList(),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: outlined ? colorScheme.surface : null,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: outlined
              ? colorScheme.outlineVariant.withOpacity(0.5)
              : gradientColors.first.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    gradientColors.first.withOpacity(0.2),
                    gradientColors.last.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: gradientColors.first, size: 32),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: outlined
                      ? colorScheme.surface
                      : gradientColors.first,
                  foregroundColor: outlined
                      ? gradientColors.first
                      : Colors.white,
                  elevation: 0,
                  side: outlined
                      ? BorderSide(color: gradientColors.first, width: 2)
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  actionLabel,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Web Create Challenge Card
  Widget _buildWebCreateChallengeCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color.fromRGBO(0, 153, 102, 0.2),
                    const Color.fromRGBO(0, 153, 102, 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(
                Icons.emoji_events_outlined,
                color: const Color.fromRGBO(0, 153, 102, 1),
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Create Challenge',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Create a new challenge and invite your friends to compete',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToCreateChallenge(context),
                icon: const Icon(Icons.add_circle_outline, size: 22),
                label: const Text(
                  'Create Challenge',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C46A),
                  foregroundColor: Colors.black,
                  elevation: 2,
                  shadowColor: const Color(0xFF00C46A).withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mobile Create Challenge Card
  Widget _buildMobileCreateChallengeCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color.fromRGBO(0, 153, 102, 0.2),
                    const Color.fromRGBO(0, 153, 102, 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.emoji_events_outlined,
                color: Color.fromRGBO(0, 153, 102, 1),
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Create Challenge',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 18,
                letterSpacing: 0.2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a new challenge and challenge your friends',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToCreateChallenge(context),
                icon: const Icon(Icons.add_circle_outline, size: 20),
                label: const Text(
                  'Create Challenge',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.1,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C46A),
                  foregroundColor: Colors.black,
                  elevation: 2,
                  shadowColor: const Color(0xFF00C46A).withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCreateChallenge(BuildContext context) {
    if (!mounted) return;
    final router = GoRouter.maybeOf(context);
    router?.pushNamed(
      'challenge-select',
      extra: {
        'folderCubit': context.read<FolderCubit>(),
        'chapterCubit': context.read<ChapterCubit>(),
        'authCubit': context.read<AuthCubit>(),
        'challengeCubit': context.read<ChallengeCubit>(),
      },
    );
  }
}
