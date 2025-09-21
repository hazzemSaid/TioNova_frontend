// features/profile/presentation/view/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/utils/no_glow_scroll_behavior.dart';

import '../widgets/achievements_section.dart';
import '../widgets/all_time_statistics.dart';
import '../widgets/profile_header.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/settings_section.dart';
import '../widgets/this_week_card.dart';
import '../widgets/todays_progress_card.dart';
import '../widgets/user_profile_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool notificationsEnabled = true;
  bool darkModeEnabled = true;

  // Sample data
  final List<Achievement> achievements = [
    Achievement(
      title: 'First Quiz',
      description: 'Completed your first quiz',
      isEarned: true,
    ),
    Achievement(
      title: 'Study Streak',
      description: '7 days in a row',
      isEarned: true,
    ),
    Achievement(
      title: 'High Scorer',
      description: 'Scored 90%+ on 5 quizzes',
      isEarned: true,
    ),
    Achievement(
      title: 'Speed Reader',
      description: 'Complete 10 chapters in a week',
      isEarned: false,
    ),
    Achievement(
      title: 'Challenge Master',
      description: 'Win 3 challenges',
      isEarned: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: const NoGlowScrollBehavior(),
          child: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: ProfileHeader(
                  onThemeToggle: () {
                    // TODO: Implement theme toggle
                  },
                ),
              ),

              // Content
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                ).copyWith(bottom: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Today's Progress
                    const TodaysProgressCard(
                      dayStreak: 7,
                      chaptersRead: 3,
                      quizzesTaken: 2,
                      studyTime: '45m',
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // This Week
                    const ThisWeekCard(
                      totalTime: '12h 30m',
                      chapters: 8,
                      avgScore: '89%',
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // User Profile
                    const UserProfileCard(
                      name: 'John Doe',
                      role: 'Student',
                      level: 'Level 3 Learner',
                      dayStreak: 7,
                      avgScore: '87%',
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Quick Actions
                    QuickActionsGrid(
                      onReviewNotes: () {},
                      onAISummary: () {},
                      onTakeQuiz: () {},
                      onChallenges: () {},
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // All-Time Statistics
                    const AllTimeStatistics(
                      chapters: 42,
                      quizzes: 28,
                      studyTime: '45h',
                      achievements: 3,
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Achievements
                    AchievementsSection(achievements: achievements),
                    SizedBox(height: screenHeight * 0.02),

                    // Settings
                    SettingsSection(
                      notificationsEnabled: notificationsEnabled,
                      darkModeEnabled: darkModeEnabled,
                      onNotificationsToggle: () {
                        setState(() {
                          notificationsEnabled = !notificationsEnabled;
                        });
                      },
                      onDarkModeToggle: () {
                        setState(() {
                          darkModeEnabled = !darkModeEnabled;
                        });
                      },
                      onExportData: () {},
                      onShareProgress: () {},
                      onHelpSupport: () {},
                      onSignOut: () {
                        context.read<AuthCubit>().signOut();
                      },
                    ),
                    SizedBox(height: 12),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
