import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/core/get_it/services_locator.dart';
import 'package:tionova/core/services/app_usage_tracker_service.dart';
import 'package:tionova/features/folder/data/models/ChapterModel.dart';
import 'package:tionova/features/home/presentation/bloc/Analysiscubit.dart';
import 'package:tionova/features/home/presentation/bloc/Analysisstate.dart';
import 'package:tionova/features/home/presentation/view/layouts/home_web_layout.dart';
import 'package:tionova/features/home/presentation/view/utils/home_view_helper.dart';
import 'package:tionova/features/home/presentation/view/widgets/CustomHeaderDelegate.dart';
import 'package:tionova/features/home/presentation/view/widgets/DailyProgressWidget.dart';
import 'package:tionova/features/home/presentation/view/widgets/EmptyStateWidget.dart';
import 'package:tionova/features/home/presentation/view/widgets/home_chapters_section.dart';
import 'package:tionova/features/home/presentation/view/widgets/home_folders_section.dart';
import 'package:tionova/features/home/presentation/view/widgets/home_last_summary_section.dart';
import 'package:tionova/features/home/presentation/view/widgets/home_mindmaps_section.dart';
import 'package:tionova/features/home/presentation/view/widgets/home_stats_section.dart';
import 'package:tionova/utils/no_glow_scroll_behavior.dart';

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
              body: const Center(child: CircularProgressIndicator()),
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
          final stats = HomeViewHelper.buildStatsList(analysisData);

          // Prepare chapters data from API
          final chaptersData = HomeViewHelper.buildChaptersList(analysisData);
          final chapters = chaptersData
              .map((ch) => ch['chapterModel'] as ChapterModel)
              .toList();

          // Prepare folders data from API
          final folders = HomeViewHelper.buildFoldersList(
            analysisData,
            colorScheme,
          );

          // Prepare last summary data
          final lastSummary = HomeViewHelper.buildLastSummaryData(analysisData);

          // Prepare mind maps data
          final mindMaps = HomeViewHelper.buildMindMapsList(analysisData);

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
                    HomeStatsSection(
                      stats: stats,
                      horizontalPadding: horizontalPadding,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
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

                    // Recent Chapters Section
                    HomeChaptersSection(
                      chapters: chapters,
                      horizontalPadding: horizontalPadding,
                      verticalSpacing: verticalSpacing,
                      screenHeight: screenHeight,
                      colorScheme: colorScheme,
                    ),

                    // Recent Folders Section
                    HomeFoldersSection(
                      folders: folders,
                      horizontalPadding: horizontalPadding,
                      verticalSpacing: verticalSpacing,
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      isTablet: isTablet,
                    ),

                    // Last Summary Section
                    HomeLastSummarySection(
                      lastSummary: lastSummary,
                      horizontalPadding: horizontalPadding,
                      verticalSpacing: verticalSpacing,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),

                    // Recent Mind Maps Section
                    HomeMindMapsSection(
                      mindMaps: mindMaps,
                      horizontalPadding: horizontalPadding,
                      verticalSpacing: verticalSpacing,
                      screenHeight: screenHeight,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
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
}
