// features/folder/presentation/view/layouts/chapter_detail_web_layout.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/core/navigation/navigation_utils.dart';
import 'package:tionova/features/chapter/data/models/ChapterModel.dart';
import 'package:tionova/features/chapter/data/models/SummaryModel.dart';
import 'package:tionova/features/chapter/presentation/bloc/chapter/chapter_cubit.dart';
import 'package:tionova/features/chapter/presentation/view/widgets/chapter_detail_action_card.dart';
import 'package:tionova/features/chapter/presentation/view/widgets/chapter_detail_ai_summary.dart';
import 'package:tionova/features/chapter/presentation/view/widgets/chapter_detail_quiz_selector.dart';
import 'package:tionova/features/chapter/presentation/view/widgets/chapter_detail_sidebar.dart';

class ChapterDetailWebLayout extends StatefulWidget {
  final ChapterModel chapter;
  final Color folderColor;
  final bool isSummaryLoading;
  final bool isMindmapLoading;
  final SummaryModel? summaryData;
  final String? rawSummaryText;
  final VoidCallback onDownloadPDF;
  final VoidCallback onGenerateSummary;
  final VoidCallback onViewSummary;
  final VoidCallback onGenerateMindmap;
  final String? folderOwnerId;

  const ChapterDetailWebLayout({
    super.key,
    required this.chapter,
    required this.folderColor,
    required this.isSummaryLoading,
    required this.isMindmapLoading,
    required this.summaryData,
    required this.rawSummaryText,
    required this.onDownloadPDF,
    required this.onGenerateSummary,
    required this.onViewSummary,
    required this.onGenerateMindmap,
    this.folderOwnerId,
  });

  @override
  State<ChapterDetailWebLayout> createState() => _ChapterDetailWebLayoutState();
}

class _ChapterDetailWebLayoutState extends State<ChapterDetailWebLayout> {
  String _activeTab = "";

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    final isLargeDesktop = screenWidth >= 1400;
    final isDesktop = screenWidth >= 1100;
    final horizontalPadding = isLargeDesktop ? 64.0 : (isDesktop ? 48.0 : 24.0);
    final sidebarWidth = isLargeDesktop ? 360.0 : (isDesktop ? 330.0 : 280.0);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surface,
            colorScheme.surfaceContainerLowest.withOpacity(0.5),
            colorScheme.surface,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeader(context, colorScheme, horizontalPadding, isDesktop),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 24,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ChapterDetailSidebar(
                    chapter: widget.chapter,
                    width: sidebarWidth,
                    onDownloadPDF: widget.onDownloadPDF,
                  ),
                  SizedBox(width: isDesktop ? 32 : 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ChapterDetailAISummaryCard(
                          isDesktop: isDesktop,
                          isLoading: widget.isSummaryLoading,
                          hasSummary:
                              widget.summaryData != null ||
                              widget.rawSummaryText != null ||
                              (widget.chapter.summaryId?.isNotEmpty ?? false),
                          onAction:
                              (widget.summaryData != null ||
                                  widget.rawSummaryText != null)
                              ? () => _openSummary(context)
                              : widget.onGenerateSummary,
                          onDownload: widget.onDownloadPDF,
                        ),
                        SizedBox(height: isDesktop ? 24 : 16),
                        _buildMainActionGrid(context, colorScheme, isDesktop),
                        const SizedBox(height: 64),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ColorScheme colorScheme,
    double padding,
    bool isDesktop,
  ) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.fromLTRB(padding, 40, padding, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ContextAwareBackNavigation.createStyledBackButton(
                  context,
                  iconColor: colorScheme.onSurface,
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Chapters',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        Text(
                          'Detail',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.chapter.title ?? 'Chapter',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: isDesktop ? 32 : 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (isDesktop)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: widget.folderColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.folderColor.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: widget.folderColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Mathematics', // This could be dynamic
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildMainActionGrid(
    BuildContext context,
    ColorScheme colorScheme,
    bool isDesktop,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Quiz Section (Flexible width)
        Expanded(
          flex: 3,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.05, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _activeTab == "quiz"
                ? ChapterDetailQuizSelector(
                    key: const ValueKey('quiz_selector'),
                    chapterId: widget.chapter.id,
                    chapterTitle: widget.chapter.title,
                    folderId: widget.chapter.folderId ?? '',
                    onBack: () => setState(() => _activeTab = ""),
                  )
                : ChapterDetailActionCard(
                    key: const ValueKey('quiz_action_card'),
                    icon: Icons.emoji_events_outlined,
                    title: 'Test Your Knowledge',
                    description:
                        'Challenge yourself with interactive quizzes and flashcards to master this chapter',
                    actionLabel: 'Start Practice',
                    actionIcon: Icons.play_arrow_rounded,
                    onAction: () => setState(() => _activeTab = "quiz"),
                    isLarge: true,
                  ),
          ),
        ),
        const SizedBox(width: 24),
        // Right Column: Mind Map and Notes (Stacked)
        Expanded(
          flex: 2,
          child: Column(
            children: [
              ChapterDetailActionCard(
                icon: Icons.account_tree_rounded,
                title: 'Mind Map',
                description: 'Visualize concepts with AI-generated insights',
                actionLabel: widget.isMindmapLoading
                    ? 'Generating...'
                    : (widget.chapter.mindmapId?.isNotEmpty ?? false
                          ? 'View Map'
                          : 'Open Map'),
                actionIcon: (widget.chapter.mindmapId?.isNotEmpty ?? false
                    ? Icons.visibility_outlined
                    : Icons.account_tree_rounded),
                onAction: () => _openMindmap(context),
                isLoading: widget.isMindmapLoading,
              ),
              const SizedBox(height: 24),
              ChapterDetailActionCard(
                icon: Icons.description_outlined,
                title: 'Smart Notes',
                description: 'Add text, voice, or image notes',
                actionLabel: 'Open Notes',
                actionIcon: Icons.description_outlined,
                onAction: () => _openNotes(context),
                backgroundColor: colorScheme.secondaryContainer,
                iconColor: colorScheme.secondary,
                iconContainerColor: colorScheme.secondary.withOpacity(0.2),
                textColor: colorScheme.onSecondaryContainer,
                subtitleColor: colorScheme.onSecondaryContainer.withOpacity(
                  0.7,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent(Widget child) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: child,
      ),
    );
  }

  void _openNotes(BuildContext context) {
    ContextAwareNavigator.navigateToChapterSubScreen(
      context,
      subScreen: 'notes',
      extra: {
        'chapterTitle': widget.chapter.title ?? 'Chapter',
        'accentColor': widget.folderColor,
        'chapterCubit': context.read<ChapterCubit>(),
        'folderOwnerId': widget.folderOwnerId,
      },
    );
  }

  void _openSummary(BuildContext context) {
    ContextAwareNavigator.navigateToChapterSubScreen(
      context,
      subScreen: 'summary',
      extra: {
        'summaryData': widget.summaryData,
        'chapterTitle': widget.chapter.title ?? 'Chapter',
        'accentColor': widget.folderColor,
        'chapterCubit': context.read<ChapterCubit>(),
      },
    );
  }

  void _openMindmap(BuildContext context) {
    ContextAwareNavigator.navigateToChapterSubScreen(
      context,
      subScreen: 'mindmap',
      extra: {
        'mindmap': null, // This should be passed from the parent or fetched
        'chapterCubit': context.read<ChapterCubit>(),
      },
    );
  }
}
