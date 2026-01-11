// features/folder/presentation/view/layouts/chapter_detail_mobile_layout.dart
import 'package:flutter/material.dart';
import 'package:tionova/features/chapter/data/models/ChapterModel.dart';
import 'package:tionova/features/chapter/data/models/SummaryModel.dart';
import 'package:tionova/features/chapter/presentation/view/widgets/chapter_detail_app_bar.dart';
import 'package:tionova/features/chapter/presentation/view/widgets/note/notes_section.dart';
import 'package:tionova/features/chapter/presentation/view/widgets/quiz/quiz_content.dart';
import 'package:tionova/features/chapter/presentation/view/widgets/summaries/ai_summary_section.dart';
import 'package:tionova/features/folder/presentation/view/utils/folder_detail_view_helper.dart';
import 'package:tionova/features/folder/presentation/view/widgets/chapter_preview_section.dart';
import 'package:tionova/features/folder/presentation/view/widgets/mind_map_section.dart';

class ChapterDetailMobileLayout extends StatelessWidget {
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

  const ChapterDetailMobileLayout({
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
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final horizontalPadding = isTablet ? 32.0 : 24.0;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        ChapterDetailAppBar(title: chapter.title),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 8.0 : 0.0),
            child: ChapterPreviewSection(
              chapter: chapter,
              formatDate: FolderDetailViewHelper.formatDate,
              onDownloadPDF: onDownloadPDF,
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: isTablet ? 12 : 8)),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 8.0 : 0.0),
            child: AISummarySection(
              isSummaryAvailable:
                  summaryData != null ||
                  rawSummaryText != null ||
                  (chapter.summaryId != null && chapter.summaryId!.isNotEmpty),
              isSummaryLoading: isSummaryLoading,
              onViewSummary: (summaryData != null || rawSummaryText != null)
                  ? onViewSummary
                  : onGenerateSummary,
              onGenerateSummary: onGenerateSummary,
            ),
          ),
        ),
        // For tablets, show MindMap and Notes side by side
        if (isTablet)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 8,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: MindMapSection(
                      isLoading: isMindmapLoading,
                      onOpen: onGenerateMindmap,
                      isAvailable:
                          chapter.mindmapId != null &&
                          chapter.mindmapId!.isNotEmpty,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: NotesSection(
                      chapterId: chapter.id,
                      chapterTitle: chapter.title ?? 'Chapter',
                      folderId: chapter.folderId ?? '',
                      accentColor: folderColor,
                      folderOwnerId: folderOwnerId,
                    ),
                  ),
                ],
              ),
            ),
          )
        else ...[
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
              folderId: chapter.folderId ?? '',
              accentColor: folderColor,
              folderOwnerId: folderOwnerId,
            ),
          ),
        ],
        SliverToBoxAdapter(child: SizedBox(height: isTablet ? 12 : 8)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: QuizContent(
              chapterId: chapter.id,
              chapterTitle: chapter.title,
              folderId: chapter.folderId ?? '',
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}
