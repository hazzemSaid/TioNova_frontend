// features/folder/presentation/view/layouts/chapter_detail_web_layout.dart
import 'package:flutter/material.dart';
import 'package:tionova/core/navigation/navigation_utils.dart';
import 'package:tionova/features/chapter/data/models/ChapterModel.dart';
import 'package:tionova/features/chapter/data/models/SummaryModel.dart';
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
  final VoidCallback onViewNotes;
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
    required this.onViewNotes,
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
    final isMobile = screenWidth < 900;
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
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ChapterDetailSidebar(
                          chapter: widget.chapter,
                          width: double.infinity,
                          onDownloadPDF: widget.onDownloadPDF,
                        ),
                        const SizedBox(height: 24),
                        ChapterDetailAISummaryCard(
                          isDesktop: false,
                          isLoading: widget.isSummaryLoading,
                          hasSummary:
                              widget.summaryData != null ||
                              widget.rawSummaryText != null ||
                              (widget.chapter.summaryId?.isNotEmpty ?? false),
                          onAction:
                              (widget.summaryData != null ||
                                  widget.rawSummaryText != null)
                              ? widget.onViewSummary
                              : widget.onGenerateSummary,
                          onDownload: widget.onDownloadPDF,
                        ),
                        const SizedBox(height: 16),
                        _buildMainActionGrid(
                          context,
                          colorScheme,
                          false,
                          isMobile,
                        ),
                        const SizedBox(height: 64),
                      ],
                    )
                  : Row(
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
                                    (widget.chapter.summaryId?.isNotEmpty ??
                                        false),
                                onAction:
                                    (widget.summaryData != null ||
                                        widget.rawSummaryText != null)
                                    ? widget.onViewSummary
                                    : widget.onGenerateSummary,
                                onDownload: widget.onDownloadPDF,
                              ),
                              SizedBox(height: isDesktop ? 24 : 16),
                              _buildMainActionGrid(
                                context,
                                colorScheme,
                                isDesktop,
                                isMobile,
                              ),
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
    bool isMobile,
  ) {
    if (isMobile) {
      return Column(
        children: [
          AnimatedSwitcher(
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
          const SizedBox(height: 24),
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
            onAction: widget.onGenerateMindmap,
            isLoading: widget.isMindmapLoading,
          ),
          const SizedBox(height: 24),
          ChapterDetailActionCard(
            icon: Icons.description_outlined,
            title: 'Smart Notes',
            description: 'Add text, voice, or image notes',
            actionLabel: 'Open Notes',
            actionIcon: Icons.description_outlined,
            onAction: widget.onViewNotes,
            backgroundColor: colorScheme.secondaryContainer,
            iconColor: colorScheme.secondary,
            iconContainerColor: colorScheme.secondary.withOpacity(0.2),
            textColor: colorScheme.onSecondaryContainer,
            subtitleColor: colorScheme.onSecondaryContainer.withOpacity(0.7),
          ),
        ],
      );
    }

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
                onAction: widget.onGenerateMindmap,
                isLoading: widget.isMindmapLoading,
              ),
              const SizedBox(height: 24),
              ChapterDetailActionCard(
                icon: Icons.description_outlined,
                title: 'Smart Notes',
                description: 'Add text, voice, or image notes',
                actionLabel: 'Open Notes',
                actionIcon: Icons.description_outlined,
                onAction: widget.onViewNotes,
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
}
