import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/profile/data/models/profile_model.dart';
import 'package:tionova/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:tionova/features/profile/presentation/cubit/profile_state.dart';
import 'package:tionova/features/profile/presentation/view/screens/profile_card.dart';
import 'package:tionova/features/profile/presentation/view/widgets/achievements_section.dart';
import 'package:tionova/features/profile/presentation/view/widgets/activity_tab.dart';
import 'package:tionova/features/profile/presentation/view/widgets/overview_tab.dart';
import 'package:tionova/features/profile/presentation/view/widgets/settings_section.dart';
import 'package:tionova/utils/no_glow_scroll_behavior.dart';
import 'package:tionova/utils/widgets/page_header.dart';
import 'package:tionova/utils/widgets/sliver_app_bar_delegate.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ProfileScreenContent();
  }
}

class _ProfileScreenContent extends StatefulWidget {
  const _ProfileScreenContent();

  @override
  State<_ProfileScreenContent> createState() => _ProfileScreenContentState();
}

class _ProfileScreenContentState extends State<_ProfileScreenContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Fetch profile data when screen loads
    Future.microtask(() {
      context.read<ProfileCubit>().fetchProfile();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshProfile() async {
    if (!mounted) return;
    await context.read<ProfileCubit>().fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return RefreshIndicator(
              onRefresh: _refreshProfile,
              color: theme.colorScheme.primary,
              child: const CustomScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              ),
            );
          } else if (state is ProfileError) {
            return RefreshIndicator(
              onRefresh: _refreshProfile,
              color: theme.colorScheme.primary,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading profile',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<ProfileCubit>().retry();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (state is ProfileLoaded) {
            final profile = state.profile;
            return RefreshIndicator(
              onRefresh: _refreshProfile,
              color: theme.colorScheme.primary,
              child: ScrollConfiguration(
                behavior: const NoGlowScrollBehavior(),
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 60, 16, 0),
                          child: Column(
                            children: [
                              const PageHeader(
                                title: 'Profile',
                                subtitle: 'Your personal study stats',
                              ),
                              // Profile Card Container
                              ProfileCard(profile: profile),
                            ],
                          ),
                        ),
                      ),
                      SliverPersistentHeader(
                        delegate: SliverAppBarDelegate(
                          TabBar(
                            controller: _tabController,
                            isScrollable: true,
                            labelColor: theme.colorScheme.primary,
                            unselectedLabelColor: theme.hintColor,
                            indicatorColor: theme.colorScheme.primary,
                            indicatorWeight: 3,
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            unselectedLabelStyle: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                            dividerColor: Colors.transparent,
                            tabAlignment: TabAlignment.start,
                            tabs: const [
                              Tab(text: 'Overview'),
                              Tab(text: 'Activity'),
                              Tab(text: 'Achievements'),
                              Tab(text: 'Settings'),
                            ],
                          ),
                        ),
                        pinned: true,
                      ),
                    ];
                  },
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTabContent(0, screenHeight, profile),
                      _buildTabContent(1, screenHeight, profile),
                      _buildTabContent(2, screenHeight, profile),
                      _buildTabContent(3, screenHeight, profile),
                    ],
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildTabContent(int index, double screenHeight, Profile profile) {
    switch (index) {
      case 0:
        return OverviewTab(screenHeight: screenHeight, profile: profile);
      case 1:
        return ActivityTab(screenHeight: screenHeight, profile: profile);
      case 2:
        return SingleChildScrollView(
          child: AchievementsSection(
            achievements: [
              Achievement(
                title: 'First Quiz',
                description: 'Completed your first quiz',
                isEarned: true,
                emoji: '🔥',
              ),
              Achievement(
                title: '7 Day Streak',
                description: '7 days in a row',
                isEarned: true,
                emoji: '🔥',
              ),
              Achievement(
                title: 'High Scorer',
                description: 'Scored 90%+ on 5 quizzes',
                isEarned: true,
                emoji: '⚡',
              ),
              Achievement(
                title: 'Speed Reader',
                description: 'Complete 10 chapters in a week',
                isEarned: false,
                emoji: '⚡',
              ),
              Achievement(
                title: 'Challenge Master',
                description: 'Win 3 challenges',
                isEarned: false,
                emoji: '🏆',
              ),
              Achievement(
                title: 'Study Buddy',
                description: 'Help 5 other students',
                isEarned: false,
                emoji: '🥇',
              ),
            ],
          ),
        );
      case 3:
        return SingleChildScrollView(
          child: SettingsSection(
            notificationsEnabled: true,
            darkModeEnabled: true,
            onNotificationsToggle: () {},
            onDarkModeToggle: () {},
            onExportData: () {},
            onShareProgress: () {},
            onHelpSupport: () {},
            onSignOut: () {
              context.read<AuthCubit>().signOut();
            },
          ),
        );
      default:
        return const Center(child: Text("Content Not Found"));
    }
  }
}
