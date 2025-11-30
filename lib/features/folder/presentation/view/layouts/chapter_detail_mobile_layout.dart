// features/folder/presentation/view/layouts/chapter_detail_mobile_layout.dart
import 'package:flutter/material.dart';
import 'package:tionova/features/folder/data/models/ChapterModel.dart';
import 'package:tionova/features/folder/data/models/SummaryModel.dart';
import 'package:tionova/features/folder/presentation/view/widgets/ai_summary_section.dart';
import 'package:tionova/features/folder/presentation/view/widgets/chapter_detail_app_bar.dart';
import 'package:tionova/features/folder/presentation/view/widgets/chapter_preview_section.dart';
import 'package:tionova/features/folder/presentation/view/widgets/chatbot_content.dart';
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
              child: const ChatbotContent(key: ValueKey('chatbot')),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}
