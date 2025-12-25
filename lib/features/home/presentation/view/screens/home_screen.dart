import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/core/get_it/services_locator.dart';
import 'package:tionova/core/services/app_usage_tracker_service.dart';
import 'package:tionova/features/folder/data/models/ChapterModel.dart';
import 'package:tionova/features/home/data/models/analysisModel.dart';
import 'package:tionova/features/home/presentation/bloc/Analysiscubit.dart';
import 'package:tionova/features/home/presentation/bloc/Analysisstate.dart';
import 'package:tionova/features/home/presentation/view/layouts/home_web_layout.dart';
import 'package:tionova/features/home/presentation/view/widgets/CustomHeaderDelegate.dart';
import 'package:tionova/features/home/presentation/view/widgets/DailyProgressWidget.dart';
import 'package:tionova/features/home/presentation/view/widgets/EmptyStateWidget.dart';
import 'package:tionova/features/home/presentation/view/widgets/MindMapCard.dart';
import 'package:tionova/features/home/presentation/view/widgets/SectionHeader.dart';
import 'package:tionova/features/home/presentation/view/widgets/StatisticsCard.dart';
import 'package:tionova/features/home/presentation/view/widgets/SummaryCard.dart';
import 'package:tionova/features/home/presentation/view/widgets/enhanced_chapter_card.dart';
import 'package:tionova/features/home/presentation/view/widgets/enhanced_folder_card.dart';
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
              body: Center(child: CircularProgressIndicator()),
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
                      child: EmptyStateWidget(
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
                          return StatisticsCard(
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
                              return DailyProgressWidget(
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
                              child: EnhancedChapterCard(
                                timeAgo: formatTimeAgo(chapterModel.createdAt),
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
                                title: '${chapterModel.title}',
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
                            return EnhancedFolderCard(
                              title: folder['title'] as String,
                              chapters: folder['chapters'] as int,
                              timeAgo: folder['timeAgo'] as String,
                              color: folder['color'] as Color,
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
                            SummaryCard(
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
                              child: MindMapCard(
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
      'summaryModel': firstSummary, // Pass the full model for navigation
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
