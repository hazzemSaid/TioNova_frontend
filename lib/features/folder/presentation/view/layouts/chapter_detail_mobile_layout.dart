// features/folder/presentation/view/layouts/chapter_detail_mobile_layout.dart
import 'package:flutter/material.dart';
import 'package:tionova/features/folder/data/models/ChapterModel.dart';
import 'package:tionova/features/folder/data/models/SummaryModel.dart';
import 'package:tionova/features/folder/presentation/view/widgets/ai_summary_section.dart';
import 'package:tionova/features/folder/presentation/view/widgets/chapter_detail_app_bar.dart';
import 'package:tionova/features/folder/presentation/view/widgets/chapter_preview_section.dart';
import 'package:tionova/features/folder/presentation/view/widgets/mind_map_section.dart';
import 'package:tionova/features/folder/presentation/view/widgets/notes_section.dart';
import 'package:tionova/features/folder/presentation/view/widgets/quiz_chatbot_tabs.dart';
import 'package:tionova/features/folder/presentation/view/widgets/quiz_content.dart';

class ChapterDetailMobileLayout extends StatelessWidget {
  final ChapterModel chapter;
  final Color folderColor;
  final bool isSummaryLoading;
  final bool isMindmapLoading;
  final String activeTab;
  final SummaryModel? summaryData;
  final String? rawSummaryText;
  final String Function(String?) formatDate;
  final VoidCallback onDownloadPDF;
  final VoidCallback onGenerateSummary;
  final VoidCallback onViewSummary;
  final VoidCallback onGenerateMindmap;
  final Function(String) onTabChanged;
  final String? folderOwnerId;

  const ChapterDetailMobileLayout({
    super.key,
    required this.chapter,
    required this.folderColor,
    required this.isSummaryLoading,
    required this.isMindmapLoading,
    required this.activeTab,
    required this.summaryData,
    required this.rawSummaryText,
    required this.formatDate,
    required this.onDownloadPDF,
    required this.onGenerateSummary,
    required this.onViewSummary,
    required this.onGenerateMindmap,
    required this.onTabChanged,
    this.folderOwnerId,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        ChapterDetailAppBar(title: chapter.title),
        SliverToBoxAdapter(
          child: ChapterPreviewSection(
            chapter: chapter,
            formatDate: formatDate,
            onDownloadPDF: onDownloadPDF,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverToBoxAdapter(
          child: AISummarySection(
            isSummaryAvailable:
                summaryData != null ||
                rawSummaryText != null ||
                (chapter.summaryId != null && chapter.summaryId!.isNotEmpty),
            isSummaryLoading: isSummaryLoading,
            onViewSummary: (summaryData != null || rawSummaryText != null)
                ? onViewSummary
                : onGenerateSummary, // If not loaded but ID exists, generate calls fetch
            onGenerateSummary: onGenerateSummary,
          ),
        ),
        SliverToBoxAdapter(
          child: MindMapSection(
            isLoading: isMindmapLoading,
            onOpen: onGenerateMindmap,
            isAvailable:
                chapter.mindmapId != null && chapter.mindmapId!.isNotEmpty,
          ),
        ),
        SliverToBoxAdapter(
          child: NotesSection(
            chapterId: chapter.id,
            chapterTitle: chapter.title ?? 'Chapter',
            accentColor: folderColor,
            folderOwnerId: folderOwnerId,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverToBoxAdapter(
          child: QuizChatbotTabs(
            activeTab: activeTab,
            onTabChanged: onTabChanged,
          ),
        ),
        if (activeTab == "quiz")
          SliverToBoxAdapter(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: QuizContent(
                key: const ValueKey('quiz'),
                chapterId: chapter.id,
                chapterTitle: chapter.title,
              ),
            ),
          ),
        if (activeTab == "chatbot")
          SliverToBoxAdapter(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Container(
                key: const ValueKey('chatbot'),
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.construction,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Not Available Yet',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Chatbot feature is coming soon',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}
