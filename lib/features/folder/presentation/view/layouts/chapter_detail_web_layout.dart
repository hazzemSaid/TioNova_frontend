// features/folder/presentation/view/layouts/chapter_detail_web_layout.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/features/folder/data/models/ChapterModel.dart';
import 'package:tionova/features/folder/data/models/SummaryModel.dart';
import 'package:tionova/features/folder/presentation/bloc/chapter/chapter_cubit.dart';
import 'package:tionova/features/folder/presentation/view/widgets/chatbot_content.dart';
import 'package:tionova/features/folder/presentation/view/widgets/quiz_content.dart';
import 'package:tionova/utils/widgets/custom_dialogs.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Folder feature uses light mode styling
    return Container(
      color: colorScheme.surface,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header with back button and title
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(48, 32, 48, 24),
              child: Row(
                children: [
                  // Back button
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
                  // Title and subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chapter.title ?? 'Chapter',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Computer Science • 36 pages',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Share button
                  IconButton(
                    icon: Icon(
                      Icons.share,
                      color: colorScheme.onSurface,
                      size: 20,
                    ),
                    onPressed: () {},
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Main content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left sidebar - PDF Preview
                  _buildLeftSidebar(context, colorScheme),
                  const SizedBox(width: 24),
                  // Right content area
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // AI Summary Card
                        _buildAISummaryCard(context, colorScheme),
                        const SizedBox(height: 20),
                        // Mind Map and Smart Notes Row
                        _buildMindMapAndNotesRow(context, colorScheme),
                        const SizedBox(height: 20),
                        // Test Your Knowledge and Your Stats Row
                        _buildQuizAndStatsRow(context, colorScheme),
                        const SizedBox(height: 20),
                        // AI Learning Assistant Card
                        _buildAIAssistantCard(context, colorScheme),
                        // Quiz Content - Show when quiz tab is active
                        if (activeTab == "quiz")
                          Padding(
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
                              child: QuizContent(
                                key: const ValueKey('quiz'),
                                chapterId: chapter.id,
                                chapterTitle: chapter.title,
                              ),
                            ),
                          ),
                        // Chatbot Content - Show when chatbot tab is active
                        if (activeTab == "chatbot")
                          Padding(
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
                              child: const ChatbotContent(
                                key: ValueKey('chatbot'),
                              ),
                            ),
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

  Widget _buildLeftSidebar(BuildContext context, ColorScheme colorScheme) {
    return Container(
      width: 330,
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline, width: 1),
      ),
      child: Column(
        children: [
          // Document Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: colorScheme.outline, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Document',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'pages',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // PDF Preview Area
          Container(
            height: 340,
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outline, width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 80,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'PDF Preview',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Click to view full document',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Stats Section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Last Opened',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 28),
                    child: Text(
                      'Jan 15',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(
                      Icons.bar_chart_rounded,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Progress',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 28),
                    child: Text(
                      '85%',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Download Button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: onDownloadPDF,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.surfaceVariant,
                      foregroundColor: colorScheme.onSurface,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: colorScheme.outline, width: 1),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.download_rounded, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Download PDF',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Share Button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.onSurface,
                      side: BorderSide(color: colorScheme.outline, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.share_rounded, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Share Chapter',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAISummaryCard(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: colorScheme.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI-Powered Summary',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Get key points, definitions, practice questions, and quick reference cards generated by AI',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          ElevatedButton(
            onPressed: isSummaryLoading
                ? null
                : (summaryData != null ||
                      rawSummaryText != null ||
                      (chapter.summaryId != null &&
                          chapter.summaryId!.isNotEmpty))
                ? (summaryData != null || rawSummaryText != null)
                      ? onViewSummary
                      : onGenerateSummary // If not loaded but ID exists, generate calls fetch
                : onGenerateSummary,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, size: 18),
                const SizedBox(width: 8),
                Text(
                  isSummaryLoading
                      ? 'Generating...'
                      : (summaryData != null ||
                            rawSummaryText != null ||
                            (chapter.summaryId != null &&
                                chapter.summaryId!.isNotEmpty))
                      ? 'View Full Summary'
                      : 'Generate Summary',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: onDownloadPDF,
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.onSurface,
              side: BorderSide(color: colorScheme.outline, width: 1),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.download_rounded, size: 18),
                SizedBox(width: 8),
                Text(
                  'Download PDF',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMindMapAndNotesRow(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outline, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.account_tree_rounded,
                    color: colorScheme.onSurface,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Mind Map',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Visualize concepts in an interactive mind map with AI-generated insights',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: isMindmapLoading ? null : onGenerateMindmap,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.onSurface,
                      side: BorderSide(color: colorScheme.outline, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isMindmapLoading
                              ? Icons.hourglass_empty
                              : (chapter.mindmapId != null &&
                                    chapter.mindmapId!.isNotEmpty)
                              ? Icons.visibility_outlined
                              : Icons.account_tree_rounded,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isMindmapLoading
                              ? 'Generating...'
                              : (chapter.mindmapId != null &&
                                    chapter.mindmapId!.isNotEmpty)
                              ? 'View Mind Map'
                              : 'Open Mind Map',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outline, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    color: colorScheme.secondary,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Smart Notes',
                  style: TextStyle(
                    color: colorScheme.onSecondaryContainer,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Add text, voice, or image notes with advanced organization',
                  style: TextStyle(
                    color: colorScheme.onSecondaryContainer.withOpacity(0.7),
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () {
                      final chapterCubit = context.read<ChapterCubit>();
                      final chapterId = chapter.id.isNotEmpty
                          ? chapter.id
                          : 'temp';
                      context.pushNamed(
                        'chapter-notes',
                        pathParameters: {'chapterId': chapterId},
                        extra: {
                          'chapterTitle': chapter.title ?? 'Chapter',
                          'accentColor': folderColor,
                          'chapterCubit': chapterCubit,
                        },
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.onSecondaryContainer,
                      side: BorderSide(color: colorScheme.secondary, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.description_outlined, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Open Notes',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizAndStatsRow(BuildContext context, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Test Your Knowledge Card
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outline, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.emoji_events_outlined,
                        color: colorScheme.onSurface,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Test Your Knowledge',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Challenge yourself with interactive quizzes based on this chapter. Track your progress and identify areas for improvement.',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          context.push('/quiz/${chapter.id}');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.emoji_events_outlined, size: 20),
                            SizedBox(width: 10),
                            Text(
                              'Start New Quiz',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: () {
                        // Practice mode - can be implemented later
                        CustomDialogs.showInfoDialog(
                          context,
                          title: 'Info',
                          message: 'Practice mode coming soon!',
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.onSurface,
                        side: BorderSide(color: colorScheme.outline, width: 1),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Practice Mode',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: () async {
                        context.push(
                          '/quiz-history/${chapter.id}',
                          extra: {'quizTitle': chapter.title},
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.onSurfaceVariant,
                        side: BorderSide(color: colorScheme.outline, width: 1),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.history, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'History',
                            style: TextStyle(
                              fontSize: 15,
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
        ),
        const SizedBox(width: 20),
        // Your Stats Card
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outline, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Stats',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 24),
                // Best Score
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Best Score',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '92%',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.92,
                    backgroundColor: colorScheme.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.tertiary,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 24),
                // Attempts
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Attempts',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '5',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Avg Time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Avg. Time',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '8m 32s',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAIAssistantCard(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              color: colorScheme.onSurface,
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Learning Assistant',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Get instant answers to your questions about this chapter. Our AI assistant can explain concepts, provide examples, and help you understand complex topics.',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          ElevatedButton(
            onPressed: () {
              onTabChanged("chatbot");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.chat_bubble_outline, size: 20),
                SizedBox(width: 10),
                Text(
                  'Start Conversation',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
