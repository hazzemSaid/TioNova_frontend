// features/profile/presentation/view/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:tionova/features/profile/presentation/view/widgets/achievements_section.dart';
import 'package:tionova/features/profile/presentation/view/widgets/settings_section.dart';
import 'package:tionova/utils/no_glow_scroll_behavior.dart';
import 'package:tionova/utils/widgets/page_header.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  int _selectedTab = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedTab = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onNavBarTap(int index) {
    setState(() {
      _selectedTab = index;
      _tabController.animateTo(index);
    });
  }

  Widget _buildTabContent(int index, double screenHeight) {
    switch (index) {
      case 0:
        return _OverviewTab(screenHeight: screenHeight);
      case 1:
        return _ActivityTab(screenHeight: screenHeight);
      case 2:
        return _AchievementsTab(screenHeight: screenHeight);
      case 3:
        return _SettingsTab(screenHeight: screenHeight);
      default:
        return _OverviewTab(screenHeight: screenHeight);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final bool isTablet = screenWidth > 600;
    final double horizontalPadding = screenWidth * (isTablet ? 0.08 : 0.05);
    final double verticalSpacing = screenHeight * 0.02;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: const NoGlowScrollBehavior(),
          child: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalSpacing,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    SizedBox(height: verticalSpacing * .5),
                    const PageHeader(
                      title: 'Profile',
                      subtitle: 'Your personal study stats',
                    ),
                    // Profile Card Container
                    Card(
                      color:
                          theme.cardTheme.color ??
                          (isDark ? Colors.grey[900] : Colors.white),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 0,
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.08),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.35),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/me.jpg',
                                  fit: BoxFit.cover,
                                  filterQuality: FilterQuality.high,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'John Doe',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Computer Science Student',
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: 200,
                              child: ElevatedButton.icon(
                                onPressed: () {},
                                icon: Icon(Icons.edit, size: 18),
                                label: const Text('Edit Profile'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.surface,
                                  foregroundColor: theme.colorScheme.onSurface,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  textStyle: theme.textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            // Stats grid
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _StatCard(
                                        icon: Icons.local_fire_department,
                                        label: 'Study Streak',
                                        value: '7',
                                        sub: 'DAYS',
                                      ),
                                      const SizedBox(width: 14),
                                      _StatCard(
                                        icon: Icons.menu_book,
                                        label: 'Chapters',
                                        value: '42',
                                        sub: 'TOTAL',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _StatCard(
                                        icon: Icons.quiz,
                                        label: 'Quizzes',
                                        value: '28',
                                        sub: 'DONE',
                                      ),
                                      const SizedBox(width: 14),
                                      _StatCard(
                                        icon: Icons.percent,
                                        label: 'Score',
                                        value: '87',
                                        sub: 'AVG',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: isDark
                          ? theme.colorScheme.surface
                          : theme.colorScheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    labelColor: theme.colorScheme.onSurface,
                    unselectedLabelColor: theme.colorScheme.onSurface
                        .withOpacity(0.5),
                    labelStyle: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelPadding: const EdgeInsets.symmetric(vertical: 10),
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Activity'),
                      Tab(text: 'Achievements'),
                      Tab(text: 'Settings'),
                    ],
                  ),
                ),
              ),
              // Tab content as SliverToBoxAdapter, only one scrollable parent
              SliverToBoxAdapter(
                child: _buildTabContent(_selectedTab, screenHeight),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Stat Card Widget ---
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String sub;
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.4),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: theme.iconTheme.color, size: 26),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Overview Tab ---
class _OverviewTab extends StatelessWidget {
  final double screenHeight;
  const _OverviewTab({required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            title: 'Today',
            icon: Icons.trending_up,
            children: [
              _StatRow(
                label1: 'Chapters',
                value1: '3',
                label2: 'Quizzes',
                value2: '2',
                trailing: '45m',
                trailingLabel: 'Time',
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.015),
          _SectionCard(
            title: 'This Month',
            icon: Icons.calendar_today,
            children: [
              _StatRow(
                label1: 'Time',
                value1: '52h 15m',
                label2: 'Chapters',
                value2: '35',
                trailing: '87',
                trailingLabel: '%',
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.015),
          _SectionCard(
            title: 'Study Insights',
            icon: Icons.bar_chart,
            children: [
              _InsightRow(
                label: 'Total Folders',
                subtitle: 'Organized materials',
                value: '5',
                icon: Icons.folder_outlined,
              ),
              const SizedBox(height: 2),
              _InsightRow(
                label: 'Quizzes Completed',
                subtitle: 'Assessments',
                value: '28',
                icon: Icons.quiz_outlined,
              ),
              const SizedBox(height: 2),
              _InsightRow(
                label: 'Hours Studied',
                subtitle: 'Total learning time',
                value: '45',
                icon: Icons.access_time,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Activity Tab ---
class _ActivityTab extends StatelessWidget {
  final double screenHeight;
  const _ActivityTab({required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            title: 'Recent Activity',
            icon: Icons.bolt,
            children: [
              _ActivityItem(
                title: 'Completed Binary Search Quiz',
                subtitle: 'Score: 89%',
                timeAgo: '5 hours ago',
                icon: Icons.quiz,
              ),
              const SizedBox(height: 4),
              _ActivityItem(
                title: 'Read "Advanced Data Structures"',
                subtitle: '5 hours ago',
                timeAgo: '',
                icon: Icons.menu_book,
              ),
              const SizedBox(height: 4),
              _ActivityItem(
                title: 'Maintained 7-day streak',
                subtitle: '1 day ago',
                timeAgo: '',
                icon: Icons.local_fire_department,
              ),
              const SizedBox(height: 4),
              _ActivityItem(
                title: 'Earned "Quiz Master" badge',
                subtitle: '2 days ago',
                timeAgo: '',
                icon: Icons.military_tech,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Achievements Tab ---
class _AchievementsTab extends StatelessWidget {
  final double screenHeight;
  const _AchievementsTab({required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    final achievements = [
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
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: AchievementsSection(achievements: achievements),
    );
  }
}

// --- Settings Tab ---
class _SettingsTab extends StatelessWidget {
  final double screenHeight;
  const _SettingsTab({required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Column(
        children: [
          SettingsSection(
            notificationsEnabled: true,
            darkModeEnabled: true,
            onNotificationsToggle: () {},
            onDarkModeToggle: () {},
            onExportData: () {},
            onShareProgress: () {},
            onHelpSupport: () {},
            onSignOut: () {},
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _PremiumUpgradeCard(),
          ),
        ],
      ),
    );
  }
}

// --- Section Card Widget ---
class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final IconData? icon;
  const _SectionCard({required this.title, required this.children, this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.4),
          width: 1,
        ),
      ),
      color: theme.cardTheme.color,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18, color: theme.colorScheme.onSurface),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ...children,
          ],
        ),
      ),
    );
  }
}

// --- Stat Row Widget ---
class _StatRow extends StatelessWidget {
  final String label1, value1, label2, value2, trailing;
  final String trailingLabel;
  const _StatRow({
    required this.label1,
    required this.value1,
    required this.label2,
    required this.value2,
    this.trailing = '',
    this.trailingLabel = '',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value1,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              label1,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 11,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value2,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              label2,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 11,
              ),
            ),
          ],
        ),
        if (trailing.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trailing,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (trailingLabel.isNotEmpty)
                    Text(
                      trailingLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
              if (trailingLabel.isNotEmpty && trailingLabel != '%')
                Text(
                  trailingLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

// --- Insight Row Widget ---
class _InsightRow extends StatelessWidget {
  final String label, value;
  final String subtitle;
  final IconData? icon;
  const _InsightRow({
    required this.label,
    required this.value,
    this.subtitle = '',
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 20,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Activity Item Widget ---
class _ActivityItem extends StatelessWidget {
  final String title, subtitle, timeAgo;
  final IconData icon;
  const _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                if (timeAgo.isNotEmpty)
                  Text(
                    timeAgo,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Premium Upgrade Card ---
class _PremiumUpgradeCard extends StatelessWidget {
  const _PremiumUpgradeCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFF6B9D), // Pink
            Color(0xFFC869FF), // Purple
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Crown emoji icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Text('👑', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upgrade to Premium',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Unlock unlimited features and AI-powered learning',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFFC869FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Text(
              'Upgrade',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
