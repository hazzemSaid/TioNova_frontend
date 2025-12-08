import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/core/utils/safe_context_mixin.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/challenges/presentation/bloc/challenge_cubit.dart';
import 'package:tionova/features/challenges/presentation/view/widgets/web_option_card.dart';
import 'package:tionova/features/folder/presentation/bloc/chapter/chapter_cubit.dart';
import 'package:tionova/features/folder/presentation/bloc/folder/folder_cubit.dart';
import 'package:tionova/utils/no_glow_scroll_behavior.dart';

class ChallengesWebLayout extends StatefulWidget {
  const ChallengesWebLayout({super.key});

  @override
  State<ChallengesWebLayout> createState() => _ChallengesWebLayoutState();
}

class _ChallengesWebLayoutState extends State<ChallengesWebLayout>
    with SafeContextMixin {
  bool _showActiveChallenges = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth > 1400
        ? 80.0
        : screenWidth > 1024
        ? 48.0
        : 32.0;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: const NoGlowScrollBehavior(),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  SizedBox(height: 48),
                  _buildHeader(context, colorScheme),
                  SizedBox(height: 56),

                  // Tab Navigation
                  _buildTabNavigation(context, colorScheme, theme),
                  SizedBox(height: 48),

                  // Content Based on Tab
                  if (_showActiveChallenges)
                    _buildActiveChallengesSection(context, colorScheme, theme)
                  else
                    _buildLeaderboardSection(context, colorScheme),

                  SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Challenges',
          style: TextStyle(
            color: colorScheme.onBackground,
            fontSize: 44,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Challenge yourself and improve your skills in real-time competitions',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildTabNavigation(
    BuildContext context,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              label: 'Active Challenges',
              isActive: _showActiveChallenges,
              onTap: () => setState(() => _showActiveChallenges = true),
              icon: Icons.flash_on,
              colorScheme: colorScheme,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: _buildTabButton(
              label: 'Leaderboard',
              isActive: !_showActiveChallenges,
              onTap: () => setState(() => _showActiveChallenges = false),
              icon: Icons.leaderboard,
              colorScheme: colorScheme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required IconData icon,
    required ColorScheme colorScheme,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isActive ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : colorScheme.onSurfaceVariant,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveChallengesSection(
    BuildContext context,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Column(
      children: [
        _buildQuickAccessGrid(context, colorScheme),
        SizedBox(height: 48),
        _buildChallengeHighlights(context, colorScheme, theme),
      ],
    );
  }

  Widget _buildQuickAccessGrid(BuildContext context, ColorScheme colorScheme) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 1200 ? 3 : 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Access',
          style: TextStyle(
            color: colorScheme.onBackground,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(height: 20),
        GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          childAspectRatio: 1.0,
          children: [
            WebOptionCard(
              title: 'Scan QR Code',
              description: 'Quick access with your camera',
              icon: Icons.qr_code_scanner,
              gradientColors: const [Color(0xFF006B54), Color(0xFF00C46A)],
              actionLabel: 'Scan',
              onTap: () {
                context.push('/challenges/scan-qr');
              },
            ),
            WebOptionCard(
              title: 'Enter Invite Code',
              description: 'Join challenge with code',
              icon: Icons.person_add_alt_1_outlined,
              gradientColors: const [Color(0xFF0035D4), Color(0xFF0066FF)],
              actionLabel: 'Enter Code',
              onTap: () {
                context.push('/enter-code');
              },
              outlined: true,
            ),
            WebOptionCard(
              title: 'Create Challenge',
              description: 'Start a new competition',
              icon: Icons.add_circle_outline,
              gradientColors: const [Color(0xFF006B54), Color(0xFF00C46A)],
              actionLabel: 'Create',
              onTap: () {
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
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChallengeHighlights(
    BuildContext context,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Featured Challenges',
          style: TextStyle(
            color: colorScheme.onBackground,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Color(0xFF006B54).withOpacity(0.15),
                Color(0xFF00C46A).withOpacity(0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: colorScheme.outlineVariant.withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.05),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF006B54).withOpacity(0.2),
                      Color(0xFF00C46A).withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(Icons.flash_on, color: Color(0xFF00C46A), size: 48),
              ),
              SizedBox(width: 32),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Challenge Active!',
                      style: TextStyle(
                        color: colorScheme.onBackground,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '"Quick BST Quiz" - 23 participants online',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.1,
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF00C46A),
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.arrow_forward, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Join Now',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardSection(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Performers',
          style: TextStyle(
            color: colorScheme.onBackground,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant.withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildLeaderboardHeader(colorScheme),
              Divider(
                height: 1,
                color: colorScheme.outlineVariant.withOpacity(0.2),
              ),
              ..._buildLeaderboardEntries(colorScheme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardHeader(ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              'Rank',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'User',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              'Score',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLeaderboardEntries(ColorScheme colorScheme) {
    final entries = [
      {'rank': '1', 'name': 'Alex Chen', 'score': '2450'},
      {'rank': '2', 'name': 'Sarah Kim', 'score': '2380'},
      {'rank': '3', 'name': 'Miller Johnson', 'score': '2210'},
      {'rank': '4', 'name': 'Emma Davis', 'score': '2050'},
      {'rank': '5', 'name': 'You', 'score': '1920'},
    ];

    return entries.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final isUserRow = data['name'] == 'You';

      return Container(
        color: isUserRow
            ? colorScheme.primaryContainer.withOpacity(0.3)
            : Colors.transparent,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              SizedBox(
                width: 50,
                child: index < 3
                    ? Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: _getMedalColors(index),
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            (index + 1).toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        data['rank']!,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  data['name']!,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: isUserRow ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(
                width: 80,
                child: Text(
                  data['score']!,
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Color> _getMedalColors(int index) {
    switch (index) {
      case 0:
        return [Color(0xFFFFD700), Color(0xFFFFA500)];
      case 1:
        return [Color(0xFFC0C0C0), Color(0xFF808080)];
      case 2:
        return [Color(0xFFCD7F32), Color(0xFF8B4513)];
      default:
        return [Color(0xFF00C46A), Color(0xFF006B54)];
    }
  }
}
