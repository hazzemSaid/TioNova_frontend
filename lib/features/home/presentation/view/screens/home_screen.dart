import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/core/get_it/services_locator.dart';
import 'package:tionova/features/chapter/data/models/ChapterModel.dart';
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

// Home Screen with Enhanced UI/UX
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AnalysisCubit _analysisCubit;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _analysisCubit = getIt<AnalysisCubit>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      if (_analysisCubit.state is! AnalysisLoaded) {
        _analysisCubit.loadAnalysisData();
      }
    }
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

    return BlocProvider<AnalysisCubit>.value(
      value: _analysisCubit,
      child: BlocListener<AnalysisCubit, AnalysisState>(
        listener: (context, state) {
          // Skip usage tracking on web
          if (!kIsWeb &&
              state is AnalysisLoaded &&
              state.analysisData.profile != null) {
            // Usage tracking disabled
          }
        },
        child: BlocBuilder<AnalysisCubit, AnalysisState>(
          buildWhen: (previous, current) => previous != current,
          builder: (context, state) {
            // Handle initial and loading state - show loading indicator
            if (state is AnalysisInitial || state is AnalysisLoading) {
              return Scaffold(
                backgroundColor: theme.scaffoldBackgroundColor,
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        'Loading...',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
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
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No data available',
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadAnalysisData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Prepare data
            final todayProgressData = analysisData.todayProgress;
            final todayProgressActual = todayProgressData?.actual;
            final todayProgress = {
              'completed': todayProgressData?.current ?? 0,
              'total': todayProgressData?.target ?? 0,
              'chapters': todayProgressActual?.chapters ?? 0,
              'quizzes': todayProgressActual?.quizzes ?? 0,
              'studyTime': 0,
              'percentage': todayProgressData?.percentage ?? 0,
            };

            final stats = HomeViewHelper.buildStatsList(analysisData);
            final chaptersData = HomeViewHelper.buildChaptersList(analysisData);
            final chapters = chaptersData
                .map((ch) => ch['chapterModel'] as ChapterModel)
                .toList();
            final folders = HomeViewHelper.buildFoldersList(
              analysisData,
              colorScheme,
            );
            final lastSummary = HomeViewHelper.buildLastSummaryData(
              analysisData,
            );
            final mindMaps = HomeViewHelper.buildMindMapsList(analysisData);

            final hasAnyContent =
                chapters.isNotEmpty ||
                folders.isNotEmpty ||
                lastSummary != null ||
                mindMaps.isNotEmpty;

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
                      if (!isWeb)
                        SliverPersistentHeader(
                          delegate: CustomHeaderDelegate(
                            minHeight: topPadding + (isTablet ? 60 : 80),
                            maxHeight: topPadding + (isTablet ? 70 : 100),
                            screenWidth: screenWidth,
                          ),
                        ),
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
                            DailyProgressWidget(
                              progress: todayProgress,
                              colorScheme: colorScheme,
                              textTheme: textTheme,
                            ),
                            SizedBox(height: verticalSpacing * 2),
                          ]),
                        ),
                      ),
                      HomeChaptersSection(
                        chapters: chapters,
                        horizontalPadding: horizontalPadding,
                        verticalSpacing: verticalSpacing,
                        screenHeight: screenHeight,
                        colorScheme: colorScheme,
                      ),
                      HomeFoldersSection(
                        folders: folders,
                        horizontalPadding: horizontalPadding,
                        verticalSpacing: verticalSpacing,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        isTablet: isTablet,
                      ),
                      HomeLastSummarySection(
                        lastSummary: lastSummary,
                        horizontalPadding: horizontalPadding,
                        verticalSpacing: verticalSpacing,
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                      ),
                      HomeMindMapsSection(
                        mindMaps: mindMaps,
                        horizontalPadding: horizontalPadding,
                        verticalSpacing: verticalSpacing,
                        screenHeight: screenHeight,
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                      ),
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
      ),
    );
  }
}
