import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/core/get_it/services_locator.dart';
import 'package:tionova/core/services/app_usage_tracker_service.dart';
import 'package:tionova/features/auth/data/services/Tokenstorage.dart';
import 'package:tionova/features/folder/data/models/ChapterModel.dart';
import 'package:tionova/features/home/presentation/bloc/Analysiscubit.dart';
import 'package:tionova/features/home/presentation/bloc/Analysisstate.dart';
import 'package:tionova/features/home/presentation/view/widgets/CustomHeaderDelegate.dart';
import 'package:tionova/features/home/presentation/view/widgets/SectionHeader.dart';
import 'package:tionova/utils/no_glow_scroll_behavior.dart';
import 'package:tionova/utils/widgets/app_search_bar.dart';

// Home Screen with Enhanced UI/UX - Provider Wrapper
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = getIt<AnalysisCubit>();
        // Load data immediately after creating the cubit
        TokenStorage.getAccessToken().then((token) {
          if (token != null) {
            cubit.loadAnalysisData(token);
          }
        });
        return cubit;
      },
      child: const _HomeScreenContent(),
    );
  }
}

// Home Screen Content
class _HomeScreenContent extends StatefulWidget {
  const _HomeScreenContent();

  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent> {
  final _usageTracker = getIt<AppUsageTrackerService>();

  Future<void> _loadAnalysisData() async {
    final token = await TokenStorage.getAccessToken();
    if (token != null) {
      context.read<AnalysisCubit>().loadAnalysisData(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final topPadding = MediaQuery.of(context).padding.top;
    final bool isTablet = screenWidth > 600;
    final double horizontalPadding = screenWidth * (isTablet ? 0.08 : 0.05);
    final double verticalSpacing = screenHeight * 0.02;

    final bool isWeb = MediaQuery.of(context).size.width > 800.0;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return BlocBuilder<AnalysisCubit, AnalysisState>(
      builder: (context, state) {
        // Handle loading state
        if (state is AnalysisLoading) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            ),
          );
        }

        // Handle error state
        if (state is AnalysisError) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 64, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load data',
                    style: textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadAnalysisData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Extract data from loaded state
        final analysisData =
            state is AnalysisLoaded ? state.analysisData : null;
        if (analysisData == null) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: const Center(child: Text('No data available')),
          );
        }

        // Prepare data for today's progress
        final todayProgress = {
          'completed': 0, // TODO: Get from API if available
          'total': analysisData.totalChapters ?? 0,
          'chapters': analysisData.recentChapters?.length ?? 0,
          'quizzes': 0, // TODO: Get from API if available
          'studyTime': _usageTracker.getTodayUsageMinutes(),
        };

        // Prepare statistics data
        final stats = [
          {
            'value': '${_usageTracker.getCurrentStreak()}',
            'label': 'Day Streak',
            'icon': Icons.local_fire_department,
          },
          {
            'value': '${analysisData.totalChapters ?? 0}',
            'label': 'Chapters',
            'icon': Icons.menu_book
          },
          {
            'value': '${analysisData.avgScore ?? 0}%',
            'label': 'Avg Score',
            'icon': Icons.insights
          },
          {
            'value': analysisData.lastRank != null
                ? '#${analysisData.lastRank}'
                : '-',
            'label': 'Rank',
            'icon': Icons.emoji_events
          },
        ];

        // Prepare chapters data from API
        final chapters = (analysisData.recentChapters ?? [])
            .map((chapter) => {
                  'id': chapter.id,
                  'title': chapter.title,
                  'subject': chapter.category ?? 'General',
                  'progress': 0.0, // TODO: Calculate based on actual progress
                  'pages': '${chapter.description?.length ?? 0} content',
                  'timeAgo': chapter.createdAt ?? 'Recently',
                  'chapterModel': chapter,
                })
            .toList();

        // Prepare folders data from API
        final folders = (analysisData.recentFolders ?? [])
            .asMap()
            .entries
            .map((entry) {
          final index = entry.key;
          final folder = entry.value;
          // Rotate through theme colors
          final colors = [
            colorScheme.primary,
            colorScheme.tertiary,
            colorScheme.secondary,
            colorScheme.primaryContainer,
          ];
          return {
            'id': folder.id,
            'title': folder.title,
            'chapters': folder.chapterCount ?? 0,
            'timeAgo': 'Recently', // TODO: Calculate time ago if available
            'color': colors[index % colors.length],
            'folderModel': folder,
          };
        }).toList();

        // Prepare last summary data
        final lastSummary = (analysisData.lastSummary != null &&
                analysisData.lastSummary!.isNotEmpty)
            ? {
                'title': analysisData.lastSummary!.first.chapterTitle,
                'chapterId':
                    'unknown', // SummaryModel doesn't have chapterId directly
                'timeAgo': 'Recently',
                'keyPoints': analysisData.lastSummary!.first.keyPoints.length,
                'readTime': 8, // TODO: Calculate read time
                'badge': 'AI Generated',
              }
            : null;

        // Prepare mind maps data
        final mindMaps = (analysisData.lastMindmaps ?? [])
            .map((mindmap) => {
                  'title': mindmap.title ?? 'Mind Map',
                  'subject': 'Chapter', // TODO: Get chapter name
                  'chapterId': mindmap.chapterId,
                  'nodes': 20, // TODO: Calculate nodes if available
                  'timeAgo': 'Recently',
                })
            .toList();

        return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: ScrollConfiguration(
        behavior: const NoGlowScrollBehavior(),
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            // Custom Header
            if (!isWeb)
              SliverPersistentHeader(
                delegate: CustomHeaderDelegate(
                  minHeight: topPadding + (isTablet ? 60 : 80),
                  maxHeight: topPadding + (isTablet ? 70 : 100),
                  screenWidth: screenWidth,
                ),
              ),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Search Bar
                  const AppSearchBar(hintText: 'Search folders, chapters...'),
                  SizedBox(height: verticalSpacing * 1.5),
                ]),
              ),
            ),

            // Statistics Cards
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  return _StatCard(
                    value: stats[index]['value'] as String,
                    label: stats[index]['label'] as String,
                    icon: stats[index]['icon'] as IconData,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  );
                }, childCount: stats.length),
              ),
            ),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  SizedBox(height: verticalSpacing * 2),

                  // Today's Progress Section with real-time updates
                  StreamBuilder<int>(
                    stream: _usageTracker.getTodayUsageStream(),
                    initialData: _usageTracker.getTodayUsageMinutes(),
                    builder: (context, snapshot) {
                      final realTimeUsage = snapshot.data ?? 0;
                      final updatedProgress = {
                        ...todayProgress,
                        'studyTime': realTimeUsage,
                      };
                      return _TodayProgressCard(
                        progress: updatedProgress,
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                      );
                    },
                  ),
                  SizedBox(height: verticalSpacing * 2),

                  SizedBox(height: verticalSpacing * 2),

                  // Recent Chapters Section Header
                  SectionHeader(
                    title: "Recent Chapters",
                    actionText: "View All",
                    actionIcon: Icons.arrow_forward_ios,
                  ),
                  SizedBox(height: verticalSpacing),
                ]),
              ),
            ),

            // Recent Chapters List
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final chapter = chapters[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: screenHeight * 0.015),
                    child: _EnhancedChapterCard(
                      title: chapter['title'] as String,
                      subject: chapter['subject'] as String,
                      progress: chapter['progress'] as double,
                      pages: chapter['pages'] as String,
                      timeAgo: chapter['timeAgo'] as String,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                      onTap: () {
                        // Navigate to chapter detail
                        final chapterModel =
                            chapter['chapterModel'] as ChapterModel;
                        context.push(
                          '/chapter/${chapterModel.id}',
                          extra: {
                            'chapter': chapterModel,
                            'folderColor': colorScheme.primary,
                          },
                        );
                      },
                    ),
                  );
                }, childCount: chapters.length),
              ),
            ),

            // Recent Folders Section
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  SizedBox(height: verticalSpacing * 2),
                  SectionHeader(
                    title: "Recent Folders",
                    actionText: "View All",
                    actionIcon: Icons.arrow_forward_ios,
                  ),
                  SizedBox(height: verticalSpacing),
                ]),
              ),
            ),

            // Folders Grid
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isTablet ? 3 : 2,
                  crossAxisSpacing: screenWidth * (isTablet ? 0.03 : 0.04),
                  mainAxisSpacing: screenHeight * 0.02,
                  childAspectRatio: isTablet ? 1.2 : 1.0,
                  mainAxisExtent: isTablet ? 180 : 160,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final folder = folders[index];
                  return _EnhancedFolderCard(
                    title: folder['title'] as String,
                    chapters: folder['chapters'] as int,
                    timeAgo: folder['timeAgo'] as String,
                    color: folder['color'] as Color,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    onTap: () {
                      // Navigate to folder detail
                      final folderId = folder['id'] as String;
                      context.push(
                        '/folder/$folderId',
                        extra: {
                          'title': folder['title'],
                          'subtitle': folder['subject'] ?? '',
                          'chapters': folder['chapters'],
                          'passed': 0,
                          'attempted': 0,
                          'color': folder['color'],
                        },
                      );
                    },
                  );
                }, childCount: folders.length),
              ),
            ),

            // Last Summary Section
            if (lastSummary != null)
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    SizedBox(height: verticalSpacing * 2),
                    SectionHeader(
                      title: "Last Summary",
                      actionText: "",
                      actionIcon: Icons.description,
                    ),
                    SizedBox(height: verticalSpacing),
                    _SummaryCard(
                      summary: lastSummary,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                      onTap: () {
                        // Navigate to chapter detail to view summary
                        // For now, show a snackbar since we need actual summary data
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Opening summary for: ${lastSummary['title']}',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: verticalSpacing * 2),

                    // Recent Mind Maps Section Header
                    SectionHeader(
                      title: "Recent Mind Maps",
                      actionText: "View All",
                      actionIcon: Icons.arrow_forward_ios,
                    ),
                    SizedBox(height: verticalSpacing),
                  ]),
                ),
              ),

            // Mind Maps List
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final mindMap = mindMaps[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: screenHeight * 0.015),
                    child: _MindMapCard(
                      mindMap: mindMap,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                      onTap: () {
                        // Show snackbar for mind map navigation
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Opening mind map: ${mindMap['title']}',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  );
                }, childCount: mindMaps.length),
              ),
            ),

            // Bottom spacing
            SliverToBoxAdapter(child: SizedBox(height: verticalSpacing * 2)),
          ],
        ),
      ),
    );
      },
    );
  }
}

// Statistics Card Widget
class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// Today's Progress Card Widget
class _TodayProgressCard extends StatelessWidget {
  final Map<String, dynamic> progress;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _TodayProgressCard({
    required this.progress,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final progressPercent = progress['completed'] / progress['total'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Today's Progress",
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Text(
                '${progress['completed']}/${progress['total']}',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progressPercent,
              minHeight: 8,
              backgroundColor: colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
          const SizedBox(height: 16),
          // Metrics Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MetricItem(
                value: '${progress['chapters']}',
                label: 'Chapters',
                icon: Icons.menu_book,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              _MetricItem(
                value: '${progress['quizzes']}',
                label: 'Quizzes',
                icon: Icons.quiz,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              _MetricItem(
                value: '${progress['studyTime']}m',
                label: 'Study Time',
                icon: Icons.access_time,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Metric Item Widget
class _MetricItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _MetricItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
        const SizedBox(height: 4),
        Text(
          value,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

// Enhanced Chapter Card Widget
class _EnhancedChapterCard extends StatelessWidget {
  final String title;
  final String subject;
  final double progress;
  final String pages;
  final String timeAgo;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback? onTap;

  const _EnhancedChapterCard({
    required this.title,
    required this.subject,
    required this.progress,
    required this.pages,
    required this.timeAgo,
    required this.colorScheme,
    required this.textTheme,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progressPercent = (progress * 100).toInt();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colorScheme.outline.withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subject,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: progress >= 1.0
                        ? colorScheme.primary.withOpacity(0.15)
                        : colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$progressPercent%',
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: progress >= 1.0
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 1.0 ? colorScheme.primary : colorScheme.tertiary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  pages,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  timeAgo,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced Folder Card Widget
class _EnhancedFolderCard extends StatelessWidget {
  final String title;
  final int chapters;
  final String timeAgo;
  final Color color;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback? onTap;

  const _EnhancedFolderCard({
    required this.title,
    required this.chapters,
    required this.timeAgo,
    required this.color,
    required this.colorScheme,
    required this.textTheme,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colorScheme.outline.withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Folder Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.folder_outlined, color: color, size: 32),
            ),
            const Spacer(),
            Text(
              title,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '$chapters chapters',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              timeAgo,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.outline,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Summary Card Widget
class _SummaryCard extends StatelessWidget {
  final Map<String, dynamic> summary;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback? onTap;

  const _SummaryCard({
    required this.summary,
    required this.colorScheme,
    required this.textTheme,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colorScheme.outline.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.description_outlined,
                color: colorScheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          summary['title'] as String,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          summary['badge'] as String,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${summary['keyPoints']} key points',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        ' • ',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                      Text(
                        '${summary['readTime']} min read',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    summary['timeAgo'] as String,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Mind Map Card Widget
class _MindMapCard extends StatelessWidget {
  final Map<String, dynamic> mindMap;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback? onTap;

  const _MindMapCard({
    required this.mindMap,
    required this.colorScheme,
    required this.textTheme,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colorScheme.outline.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.account_tree_outlined,
                color: colorScheme.tertiary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mindMap['title'] as String,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mindMap['subject'] as String,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${mindMap['nodes']} nodes',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        ' • ',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                      Text(
                        mindMap['timeAgo'] as String,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.info_outline,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
