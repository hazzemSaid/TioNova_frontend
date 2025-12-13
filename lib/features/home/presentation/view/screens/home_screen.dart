import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:tionova/core/get_it/services_locator.dart';
import 'package:tionova/core/services/app_usage_tracker_service.dart';
import 'package:tionova/features/folder/data/models/ChapterModel.dart';
import 'package:tionova/features/home/data/models/analysisModel.dart';
import 'package:tionova/features/home/presentation/bloc/Analysiscubit.dart';
import 'package:tionova/features/home/presentation/bloc/Analysisstate.dart';
import 'package:tionova/features/home/presentation/provider/index_mainLayout.dart';
import 'package:tionova/features/home/presentation/view/layouts/home_web_layout.dart';
import 'package:tionova/features/home/presentation/view/widgets/CustomHeaderDelegate.dart';
import 'package:tionova/features/home/presentation/view/widgets/SectionHeader.dart';
import 'package:tionova/utils/no_glow_scroll_behavior.dart';

// Utility: Format DateTime to 'time ago' string
String formatTimeAgo(dynamic date) {
  if (date == null) return 'Recently';
  DateTime? dateTime;
  if (date is DateTime) {
    dateTime = date;
  } else if (date is String) {
    try {
      dateTime = DateTime.tryParse(date);
    } catch (_) {
      return 'Recently';
    }
  }
  if (dateTime == null) return 'Recently';
  final now = DateTime.now();
  final diff = now.difference(dateTime);
  if (diff.inSeconds < 60) {
    return '${diff.inSeconds}s ago';
  } else if (diff.inMinutes < 60) {
    return '${diff.inMinutes}m ago';
  } else if (diff.inHours < 24) {
    return '${diff.inHours}h ago';
  } else if (diff.inDays < 7) {
    return '${diff.inDays}d ago';
  } else if (diff.inDays < 30) {
    return '${(diff.inDays / 7).floor()}w ago';
  } else if (diff.inDays < 365) {
    return '${(diff.inDays / 30).floor()}mo ago';
  } else {
    return '${(diff.inDays / 365).floor()}y ago';
  }
}

// Home Screen with Enhanced UI/UX - Provider Wrapper
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = getIt<AnalysisCubit>();
        // Load data immediately after creating the cubit
        cubit.loadAnalysisData();
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
  late final AnalysisCubit _analysisCubit;

  @override
  void initState() {
    super.initState();
    // Get cubit reference in initState to avoid context issues during disposal
    _analysisCubit = context.read<AnalysisCubit>();
  }

  Future<void> _loadAnalysisData() async {
    if (!mounted) return;
    _analysisCubit.loadAnalysisData();
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

    return BlocListener<AnalysisCubit, AnalysisState>(
      listener: (context, state) {
        if (state is AnalysisLoaded && state.analysisData.profile != null) {
          final profile = state.analysisData.profile!;
          _usageTracker.updateProfileFromApi(
            streak: profile.streak,
            lastActiveDate: profile.lastActiveDate,
            totalQuizzesTaken: profile.totalQuizzesTaken,
            totalMindmapsCreated: profile.totalMindmapsCreated,
            totalSummariesCreated: profile.totalSummariesCreated,
            averageQuizScore: profile.averageQuizScore,
          );
        }
      },
      child: BlocBuilder<AnalysisCubit, AnalysisState>(
        buildWhen: (previous, current) => previous != current,
        builder: (context, state) {
          // Handle loading state
          if (state is AnalysisLoading) {
            return Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              body: Center(
                child: Lottie.asset(
                  'assets/animations/Loader cat.json',
                  width: 200,
                  height: 200,
                ),
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
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text('Failed to load data', style: textTheme.titleLarge),
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
          final analysisData = state is AnalysisLoaded
              ? state.analysisData
              : null;
          if (analysisData == null) {
            return Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              body: const Center(child: Text('No data available')),
            );
          }

          // Prepare data for today's progress from API
          final todayProgressData = analysisData.todayProgress;
          final todayProgress = {
            'completed': todayProgressData?.current ?? 0,
            'total': todayProgressData?.target ?? 0,
            'chapters': todayProgressData?.actual.chapters ?? 0,
            'quizzes': todayProgressData?.actual.quizzes ?? 0,
            'studyTime': _usageTracker.getTodayUsageMinutes(),
            'percentage': todayProgressData?.percentage ?? 0,
          };

          // Prepare statistics data
          final stats = _buildStatsList(analysisData);

          // Prepare chapters data from API
          final chaptersData = _buildChaptersList(analysisData);
          final chapters = chaptersData
              .map((ch) => ch['chapterModel'] as ChapterModel)
              .toList();

          // Prepare folders data from API
          final folders = _buildFoldersList(analysisData, colorScheme);

          // Prepare last summary data
          final lastSummary = _buildLastSummaryData(analysisData);

          // Prepare mind maps data
          final mindMaps = _buildMindMapsList(analysisData);

          // Check if all content sections are empty
          final hasChapters = chapters.isNotEmpty;
          final hasFolders = folders.isNotEmpty;
          final hasSummary = lastSummary != null;
          final hasMindMaps = mindMaps.isNotEmpty;
          final hasAnyContent =
              hasChapters || hasFolders || hasSummary || hasMindMaps;

          // Show empty state if no content
          if (!hasAnyContent) {
            if (isWeb) {
              return HomeWebLayout(
                theme: theme,
                analysisData: analysisData,
                stats: stats,
                chapters: const [],
                folders: const [],
                lastSummary: null,
                mindMaps: const [],
                todayProgress: todayProgress,
                onRefresh: _loadAnalysisData,
              );
            }

            return Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              body: RefreshIndicator(
                onRefresh: _loadAnalysisData,
                color: colorScheme.primary,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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

                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyStateWidget(
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                        horizontalPadding: horizontalPadding,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Return web layout if screen width > 800
          if (isWeb) {
            return HomeWebLayout(
              theme: theme,
              analysisData: analysisData,
              stats: stats,
              chapters: chapters,
              folders: folders,
              lastSummary: lastSummary,
              mindMaps: mindMaps,
              todayProgress: todayProgress,
              onRefresh: _loadAnalysisData,
            );
          }

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: RefreshIndicator(
              onRefresh: _loadAnalysisData,
              color: colorScheme.primary,
              child: ScrollConfiguration(
                behavior: const NoGlowScrollBehavior(),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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

                    // Statistics Cards
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio:
                              1.1, // Increased to provide more vertical space
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
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
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
                        ]),
                      ),
                    ),

                    // Recent Chapters Section - Only show if has chapters
                    if (hasChapters)
                      SliverPadding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
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
                    if (hasChapters)
                      SliverPadding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final chapterModel = chapters[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: screenHeight * 0.015,
                              ),
                              child: _EnhancedChapterCard(
                                title: chapterModel.title ?? 'Untitled',
                                subject: chapterModel.category ?? 'General',
                                progress: 0.0,
                                pages:
                                    '${chapterModel.description?.length ?? 0} content',
                                timeAgo: formatTimeAgo(chapterModel.createdAt),
                                colorScheme: colorScheme,
                                textTheme: textTheme,
                                onTap: () {
                                  // Navigate to chapter detail
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

                    // Recent Folders Section - Only show if has folders
                    if (hasFolders)
                      SliverPadding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
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
                    if (hasFolders)
                      SliverPadding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isTablet ? 3 : 2,
                                crossAxisSpacing:
                                    screenWidth * (isTablet ? 0.03 : 0.04),
                                mainAxisSpacing: screenHeight * 0.02,
                                childAspectRatio: isTablet ? 1.2 : 1.0,
                                mainAxisExtent: isTablet ? 180 : 160,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
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
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
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
                                // Navigate to summary viewer
                                // analysisData.lastSummary is guaranteed to be non-null here
                                // because lastSummary map is only created when it's not null
                                context.push(
                                  '/summary-viewer',
                                  extra: {
                                    'summaryData':
                                        analysisData.lastSummary!.summary,
                                    'chapterTitle': analysisData
                                        .lastSummary!
                                        .summary
                                        .chapterTitle,
                                    'accentColor': colorScheme.primary,
                                  },
                                );
                              },
                            ),
                            SizedBox(height: verticalSpacing * 2),
                          ]),
                        ),
                      ),

                    // Recent Mind Maps Section - Only show if has mind maps
                    if (hasMindMaps)
                      SliverPadding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
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
                    if (hasMindMaps)
                      SliverPadding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final mindMap = mindMaps[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: screenHeight * 0.015,
                              ),
                              child: _MindMapCard(
                                mindMap: mindMap,
                                colorScheme: colorScheme,
                                textTheme: textTheme,
                                onTap: () {
                                  // Navigate to mindmap viewer screen
                                  final mindmapModel = mindMap['mindmapModel'];
                                  if (mindmapModel != null) {
                                    context.push(
                                      '/mindmap-viewer',
                                      extra: {'mindmap': mindmapModel},
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Mind map data not found.',
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            );
                          }, childCount: mindMaps.length),
                        ),
                      ),

                    // Bottom spacing
                    SliverToBoxAdapter(
                      child: SizedBox(height: verticalSpacing * 2),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _buildStatsList(Analysismodel analysisData) {
    return [
      {
        'value': '${analysisData.profile?.streak ?? 0}',
        'label': 'Day Streak',
        'icon': Icons.local_fire_department,
      },
      {
        'value': '${analysisData.profile?.totalQuizzesTaken ?? 0}',
        'label': 'Quizzes',
        'icon': Icons.quiz,
      },
      {
        'value': analysisData.profile?.averageQuizScore != null
            ? '${analysisData.profile!.averageQuizScore.toStringAsFixed(1)}%'
            : '0%',
        'label': 'Avg Score',
        'icon': Icons.insights,
      },
      {
        'value': analysisData.lastRank != null
            ? '#${analysisData.lastRank}'
            : '-',
        'label': 'Rank',
        'icon': Icons.emoji_events,
      },
    ];
  }

  List<Map<String, dynamic>> _buildChaptersList(Analysismodel analysisData) {
    return (analysisData.recentChapters ?? [])
        .map(
          (chapter) => {
            'id': chapter.id,
            'title': chapter.title,
            'subject': chapter.category ?? 'General',
            'progress': 0.0, // TODO: Calculate based on actual progress
            'pages': '${chapter.description?.length ?? 0} content',
            'timeAgo': formatTimeAgo(chapter.createdAt),
            'chapterModel': chapter,
          },
        )
        .toList();
  }

  List<Map<String, dynamic>> _buildFoldersList(
    Analysismodel analysisData,
    ColorScheme colorScheme,
  ) {
    return (analysisData.recentFolders ?? []).asMap().entries.map((entry) {
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
        'timeAgo': formatTimeAgo(folder.createdAt),
        'color': colors[index % colors.length],
        'folderModel': folder,
      };
    }).toList();
  }

  Map<String, dynamic>? _buildLastSummaryData(Analysismodel analysisData) {
    if (analysisData.lastSummary == null) return null;

    final summaryData = analysisData.lastSummary!;
    // The summary field contains an array of summaries, get the first one
    final firstSummary = summaryData.summary;

    return {
      'title': firstSummary.chapterTitle,
      'chapterId': summaryData.chapterId,
      'timeAgo': formatTimeAgo(summaryData.createdAt),
      'keyPoints': firstSummary.keyPoints.length,
      'readTime': 8, // TODO: Calculate read time
      'badge': 'AI Generated',
    };
  }

  List<Map<String, dynamic>> _buildMindMapsList(Analysismodel analysisData) {
    return (analysisData.lastMindmaps ?? [])
        .map(
          (mindmap) => {
            'title': mindmap.title ?? 'Mind Map',
            'subject': 'Chapter', // TODO: Get chapter name
            'chapterId': mindmap.chapterId,
            'nodes': mindmap.nodes?.length ?? 0,
            'timeAgo': formatTimeAgo(mindmap.createdAt),
            'mindmapModel': mindmap, // Pass the full model for navigation
          },
        )
        .toList();
  }
}

// Empty State Widget
class _EmptyStateWidget extends StatelessWidget {
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final double horizontalPadding;

  const _EmptyStateWidget({
    required this.colorScheme,
    required this.textTheme,
    required this.horizontalPadding,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bool isTablet = screenSize.width > 600;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          // Animated Icon with gradient background
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: isTablet ? 140 : 120,
                  height: isTablet ? 140 : 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primaryContainer,
                        colorScheme.secondaryContainer,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    size: isTablet ? 72 : 64,
                    color: colorScheme.primary,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 40),

          // Title with animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Text(
              'Your Learning Journey\nAwaits!',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),

          // Subtitle with animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Start by creating your first folder and adding chapters to begin your amazing learning experience',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 48),

          // Action Buttons with animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<IndexMainLayout>().index = 1;
                  },
                  icon: const Icon(Icons.create_new_folder),
                  label: const Text('Go to Folders'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 32 : 24,
                      vertical: isTablet ? 16 : 14,
                    ),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(flex: 3),

          // Bottom hint
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1400),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(opacity: value, child: child);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Tip: Organize your content in folders for better learning',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              value,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
                fontSize: 16, // Reduced size for better mobile fit
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 9,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
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
    final total = progress['total'] as int;
    final completed = progress['completed'] as int;
    // Use percentage from API if available, otherwise calculate
    final progressPercent = progress['percentage'] != null
        ? (progress['percentage'] as int) / 100.0
        : (total > 0 ? completed / total : 0.0);

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
    final isCompleted = progress >= 1.0;
    final progressColor = isCompleted ? Colors.green : colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and progress badge
            Row(
              children: [
                // Chapter Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        progressColor.withOpacity(0.2),
                        progressColor.withOpacity(0.08),
                      ],
                    ),
                    border: Border.all(
                      color: progressColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    isCompleted
                        ? Icons.check_circle_outline
                        : Icons.article_outlined,
                    color: progressColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // Title and subject
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                          height: 1.3,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.folder_outlined,
                            size: 13,
                            color: colorScheme.onSurfaceVariant.withOpacity(
                              0.7,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              subject,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant.withOpacity(
                                  0.9,
                                ),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Time ago display
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 15,
                  color: colorScheme.primary.withOpacity(0.7),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    timeAgo,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 0.2,
                    ),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isLarge = screenWidth > 900;

    // Responsive sizing - optimized to prevent overflow
    final cardPadding = isLarge ? 15.0 : (isTablet ? 14.0 : 13.0);
    final iconSize = isLarge ? 56.0 : (isTablet ? 54.0 : 52.0);
    final iconInnerSize = isLarge ? 32.0 : (isTablet ? 31.0 : 30.0);
    final iconRadius = isLarge ? 13.0 : (isTablet ? 12.5 : 12.0);
    final spacing1 = isLarge ? 11.0 : (isTablet ? 10.0 : 9.0);
    final spacing2 = isLarge ? 3.5 : (isTablet ? 3.0 : 2.5);
    final spacing3 = isLarge ? 1.5 : (isTablet ? 1.0 : 0.5);
    final titleFontSize = isLarge ? 15.0 : (isTablet ? 14.5 : 14.0);
    final chapterFontSize = isLarge ? 12.0 : (isTablet ? 11.5 : 11.0);
    final timeFontSize = isLarge ? 10.5 : 10.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
      child: Container(
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
          border: Border.all(color: colorScheme.outline.withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Folder Icon
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(iconRadius),
              ),
              child: Icon(
                Icons.folder_outlined,
                color: color,
                size: iconInnerSize,
              ),
            ),
            SizedBox(height: spacing1),
            Text(
              title,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
                fontSize: titleFontSize,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: spacing2),
            Text(
              '$chapters chapters',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: chapterFontSize,
              ),
            ),
            SizedBox(height: spacing3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                timeAgo,
                style: textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: timeFontSize,
                  letterSpacing: 0.2,
                ),
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      summary['timeAgo'] as String,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 0.2,
                      ),
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.tertiary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          mindMap['timeAgo'] as String,
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.tertiary,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 0.2,
                          ),
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
