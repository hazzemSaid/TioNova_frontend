// features/folder/presentation/view/layouts/chapter_detail_web_layout.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/features/folder/data/models/ChapterModel.dart';
import 'package:tionova/features/folder/data/models/SummaryModel.dart';
import 'package:tionova/features/folder/presentation/bloc/chapter/chapter_cubit.dart';
import 'package:tionova/features/folder/presentation/view/widgets/chapter_detail_action_card.dart';
import 'package:tionova/features/folder/presentation/view/widgets/chapter_detail_ai_assistant.dart';
import 'package:tionova/features/folder/presentation/view/widgets/chapter_detail_ai_summary.dart';
import 'package:tionova/features/folder/presentation/view/widgets/chapter_detail_sidebar.dart';
import 'package:tionova/features/folder/presentation/view/widgets/chapter_detail_stats_card.dart';
import 'package:tionova/features/folder/presentation/view/widgets/chatbot_content.dart';
import 'package:tionova/features/folder/presentation/view/widgets/quiz_content.dart';

class ChapterDetailWebLayout extends StatelessWidget {
  final ChapterModel chapter;
  final Color folderColor;
  final bool isSummaryLoading;
  final bool isMindmapLoading;
  final String activeTab;
  final SummaryModel? summaryData;
  final String? rawSummaryText;
  final VoidCallback onDownloadPDF;
  final VoidCallback onGenerateSummary;
  final VoidCallback onViewSummary;
  final VoidCallback onGenerateMindmap;
  final Function(String) onTabChanged;
  final String? folderOwnerId;

  const ChapterDetailWebLayout({
    super.key,
    required this.chapter,
    required this.folderColor,
    required this.isSummaryLoading,
    required this.isMindmapLoading,
    required this.activeTab,
    required this.summaryData,
    required this.rawSummaryText,
    required this.onDownloadPDF,
    required this.onGenerateSummary,
    required this.onViewSummary,
    required this.onGenerateMindmap,
    required this.onTabChanged,
    this.folderOwnerId,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    final isLargeDesktop = screenWidth >= 1400;
    final isDesktop = screenWidth >= 1100;
    final horizontalPadding = isLargeDesktop ? 64.0 : (isDesktop ? 48.0 : 24.0);
    final sidebarWidth = isLargeDesktop ? 360.0 : (isDesktop ? 330.0 : 280.0);

    return Container(
      color: colorScheme.surface,
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
                    chapter: chapter,
                    width: sidebarWidth,
                    onDownloadPDF: onDownloadPDF,
                  ),
                  SizedBox(width: isDesktop ? 24 : 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ChapterDetailAISummaryCard(
                          isDesktop: isDesktop,
                          isLoading: isSummaryLoading,
                          hasSummary:
                              summaryData != null ||
                              rawSummaryText != null ||
                              (chapter.summaryId?.isNotEmpty ?? false),
                          onAction:
                              (summaryData != null || rawSummaryText != null)
                              ? onViewSummary
                              : onGenerateSummary,
                          onDownload: onDownloadPDF,
                        ),
                        SizedBox(height: isDesktop ? 20 : 16),
                        _buildMindMapAndNotesRow(
                          context,
                          colorScheme,
                          isDesktop,
                        ),
                        SizedBox(height: isDesktop ? 20 : 16),
                        _buildQuizAndStatsRow(context, colorScheme, isDesktop),
                        SizedBox(height: isDesktop ? 20 : 16),
                        ChapterDetailAIAssistant(
                          onAction: () => onTabChanged("chatbot"),
                        ),
                        if (activeTab == "quiz")
                          _buildTabContent(
                            QuizContent(
                              chapterId: chapter.id,
                              chapterTitle: chapter.title,
                              folderId: chapter.folderId ?? '',
                            ),
                          ),
                        if (activeTab == "chatbot")
                          _buildTabContent(const ChatbotContent()),
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
        padding: EdgeInsets.fromLTRB(padding, 32, padding, 24),
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: colorScheme.onSurface,
                size: 24,
              ),
              onPressed: () => Navigator.of(context).pop(),
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              chapter.title ?? 'Chapter',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: isDesktop ? 24 : 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMindMapAndNotesRow(
    BuildContext context,
    ColorScheme colorScheme,
    bool isDesktop,
  ) {
    return Row(
      children: [
        Expanded(
          child: ChapterDetailActionCard(
            icon: Icons.account_tree_rounded,
            title: 'Mind Map',
            description:
                'Visualize concepts in an interactive mind map with AI-generated insights',
            actionLabel: isMindmapLoading
                ? 'Generating...'
                : (chapter.mindmapId?.isNotEmpty ?? false
                      ? 'View Mind Map'
                      : 'Open Mind Map'),
            actionIcon: (chapter.mindmapId?.isNotEmpty ?? false
                ? Icons.visibility_outlined
                : Icons.account_tree_rounded),
            onAction: onGenerateMindmap,
            isLoading: isMindmapLoading,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: ChapterDetailActionCard(
            icon: Icons.description_outlined,
            title: 'Smart Notes',
            description:
                'Add text, voice, or image notes with advanced organization',
            actionLabel: 'Open Notes',
            actionIcon: Icons.description_outlined,
            onAction: () => _openNotes(context),
            backgroundColor: colorScheme.secondaryContainer,
            iconColor: colorScheme.secondary,
            iconContainerColor: colorScheme.secondary.withOpacity(0.2),
            textColor: colorScheme.onSecondaryContainer,
            subtitleColor: colorScheme.onSecondaryContainer.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizAndStatsRow(
    BuildContext context,
    ColorScheme colorScheme,
    bool isDesktop,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: ChapterDetailActionCard(
            icon: Icons.emoji_events_outlined,
            title: 'Test Your Knowledge',
            description:
                'Challenge yourself with interactive quizzes and flashcards to master this chapter',
            actionLabel: 'Start Practice',
            actionIcon: Icons.play_arrow_rounded,
            onAction: () => onTabChanged("quiz"),
            isLarge: true,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 1,
          child: ChapterDetailStatsCard(
            passed: chapter.quizScore ?? 0,
            attempted: chapter.quizCompleted == true ? 1 : 0,
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
    final folderId = chapter.folderId;
    final hasFolder = folderId != null && folderId.isNotEmpty;
    final chapterId = chapter.id.isNotEmpty ? chapter.id : 'temp';

    if (hasFolder) {
      context.pushNamed(
        'chapter-notes',
        pathParameters: {'folderId': folderId, 'chapterId': chapterId},
        extra: {
          'chapterTitle': chapter.title ?? 'Chapter',
          'accentColor': folderColor,
          'chapterCubit': context.read<ChapterCubit>(),
          'folderOwnerId': folderOwnerId,
        },
      );
    } else {
      context.pushNamed(
        'chapter-notes-quick',
        pathParameters: {'chapterId': chapterId},
        extra: {
          'chapterTitle': chapter.title ?? 'Chapter',
          'accentColor': folderColor,
          'chapterCubit': context.read<ChapterCubit>(),
          'folderOwnerId': folderOwnerId,
        },
      );
    }
  }
}
