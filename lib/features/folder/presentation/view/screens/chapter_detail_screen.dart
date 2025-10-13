// features/folder/presentation/view/screens/chapter_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tionova/core/services/download_service.dart';
import 'package:tionova/core/services/summary_cache_service.dart';
import 'package:tionova/features/auth/data/services/Tokenstorage.dart';
import 'package:tionova/features/folder/data/models/ChapterModel.dart';
import 'package:tionova/features/folder/data/models/SummaryModel.dart';
import 'package:tionova/features/folder/presentation/bloc/chapter/chapter_cubit.dart';
import 'package:tionova/features/folder/presentation/view/screens/RawSummaryViewerScreen.dart';
import 'package:tionova/features/folder/presentation/view/screens/SummaryViewerScreen.dart';
import 'package:tionova/features/folder/presentation/view/widgets/ai_summary_section.dart';
import 'package:tionova/features/folder/presentation/view/widgets/chapter_detail_app_bar.dart';
import 'package:tionova/features/folder/presentation/view/widgets/chapter_preview_section.dart';
import 'package:tionova/features/folder/presentation/view/widgets/chatbot_content.dart';
import 'package:tionova/features/folder/presentation/view/widgets/mind_map_section.dart';
import 'package:tionova/features/folder/presentation/view/widgets/notes_section.dart';
import 'package:tionova/features/folder/presentation/view/widgets/quiz_chatbot_tabs.dart';
import 'package:tionova/features/folder/presentation/view/widgets/quiz_content.dart';

class ChapterDetailScreen extends StatefulWidget {
  final ChapterModel chapter;
  final Color folderColor;

  const ChapterDetailScreen({
    Key? key,
    required this.chapter,
    required this.folderColor,
  }) : super(key: key);

  @override
  State<ChapterDetailScreen> createState() => _ChapterDetailScreenState();
}

class _ChapterDetailScreenState extends State<ChapterDetailScreen>
    with WidgetsBindingObserver {
  bool _isSummaryLoading = false;
  String _activeTab = ""; // Empty string means no tab is selected
  SummaryModel? _summaryData; // Store the parsed summary data
  String? _rawSummaryText; // Store raw text summary when JSON parsing fails

  @override
  void initState() {
    super.initState();
    // Add observer to detect app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
    // Check for cached summary on screen load
    _checkAndLoadCachedSummary();
  }

  @override
  void dispose() {
    // Remove observer when disposing
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // When app comes to foreground, check for cached summary again
    if (state == AppLifecycleState.resumed && mounted) {
      _checkAndLoadCachedSummary();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check for cached summary when dependencies change (e.g., returning to screen)
    if (mounted && _summaryData == null) {
      _checkAndLoadCachedSummary();
    }
  }

  // Check for cached summary and load it if available
  void _checkAndLoadCachedSummary() {
    final chapterId = widget.chapter.id ?? '';
    // First check if we have cached summary
    if (SummaryCacheService.isSummaryCached(chapterId)) {
      final cachedData = SummaryCacheService.getCachedSummaryWithMetadata(
        chapterId,
      );
      if (cachedData != null) {
        setState(() {
          _summaryData = cachedData.summaryData;
        });
      }
    }
    // Also trigger the cubit check for consistency
    context.read<ChapterCubit>().checkCachedSummary(chapterId: chapterId);
  }

  // Format date for display
  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('M/d/yyyy').format(date);
    } catch (e) {
      return '';
    }
  }

  // Handle summary generation
  Future<void> _generateSummary() async {
    try {
      final token = await TokenStorage.getAccessToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication required'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final chapterId = widget.chapter.id ?? '';
      context.read<ChapterCubit>().generateSummary(
        token: token,
        chapterId: chapterId,
        chapterTitle: widget.chapter.title,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate summary: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Navigate to summary viewer
  void _viewSummary() {
    if (_summaryData != null) {
      // Navigate to structured summary viewer
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SummaryViewerScreen(
            summaryData: _summaryData!,
            chapterTitle: widget.chapter.title ?? 'Chapter',
            accentColor: widget.folderColor,
          ),
        ),
      );
    } else if (_rawSummaryText != null) {
      // Navigate to raw text summary viewer
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RawSummaryViewerScreen(
            summaryText: _rawSummaryText!,
            chapterTitle: widget.chapter.title ?? 'Chapter',
            accentColor: widget.folderColor,
          ),
        ),
      );
    }
  }

  // Handle PDF download
  Future<void> _downloadChapterPDF() async {
    try {
      final chapterId = widget.chapter.id ?? '';

      // Check if PDF is already cached
      if (DownloadService.isPDFCached(chapterId)) {
        print('Using cached PDF for download');
        final cachedPdfBytes = DownloadService.getCachedPDF(chapterId);

        if (cachedPdfBytes != null) {
          // Download from cache immediately
          final fileName = DownloadService.sanitizeFileName(
            widget.chapter.title ?? 'chapter',
          );
          final success = await DownloadService.downloadPDF(
            pdfBytes: cachedPdfBytes,
            fileName: fileName,
            context: context,
          );

          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('PDF downloaded from cache'),
                backgroundColor: Colors.green,
              ),
            );
          }
          return;
        }
      }

      // If not cached, fetch from API
      print('Fetching PDF from API for download');
      final token = await TokenStorage.getAccessToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication required'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
      );

      // Fetch PDF content using the cubit
      context.read<ChapterCubit>().getChapterContentPdf(
        token: token,
        chapterId: chapterId,
        forDownload: true, // This is a download operation
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChapterCubit, ChapterState>(
      listener: (context, state) {
        if (state is GetChapterContentPdfSuccess) {
          // Only handle download side-effects when explicitly for download
          if (state.forDownload) {
            Navigator.of(context).pop(); // Close loading dialog
            final fileName = DownloadService.sanitizeFileName(
              widget.chapter.title ?? 'chapter',
            );
            // Cache the PDF data for future use
            DownloadService.cachePDF(
              widget.chapter.id.toString(),
              state.pdfData,
              fileName: '$fileName.pdf',
              chapterTitle: widget.chapter.title,
            );
            // Download the PDF to device
            DownloadService.downloadPDF(
              pdfBytes: state.pdfData,
              fileName: fileName,
              context: context,
            );
          }
        } else if (state is GetChapterContentPdfError) {
          // Only close dialog and show error when it was a download request
          if (state.forDownload) {
            Navigator.of(context).pop(); // Close loading dialog
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Download failed: ${state.message.errMessage}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else if (state is SummaryCachedFound) {
          setState(() {
            _isSummaryLoading = false;
            _summaryData = state.summaryData;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Summary loaded from cache (${state.cacheAge})'),
              backgroundColor: Colors.blue,
            ),
          );
        } else if (state is GenerateSummaryLoading ||
            state is SummaryRegenerateLoading) {
          setState(() {
            _isSummaryLoading = true;
          });
        } else if (state is GenerateSummaryStructuredSuccess ||
            state is SummaryRegenerateSuccess) {
          setState(() {
            _isSummaryLoading = false;
            _rawSummaryText =
                null; // Clear raw text when we get structured data
            if (state is GenerateSummaryStructuredSuccess) {
              _summaryData = state.summaryData;
            } else if (state is SummaryRegenerateSuccess) {
              _summaryData = state.summaryData;
            }
          });
          final message = state is SummaryRegenerateSuccess
              ? 'Summary regenerated successfully!'
              : 'Summary generated successfully!';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.green),
          );
        } else if (state is SummaryCachedFound) {
          setState(() {
            _isSummaryLoading = false;
            _summaryData = state.summaryData;
            _rawSummaryText =
                null; // Clear raw text when we get cached structured data
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Found cached summary (${state.cacheAge})'),
              backgroundColor: Colors.blue,
            ),
          );
        } else if (state is GenerateSummarySuccess) {
          setState(() {
            _isSummaryLoading = false;
            _rawSummaryText = state.summary; // Store the raw text summary
            _summaryData = null; // Clear structured data when we get raw text
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Summary generated (text format)'),
              backgroundColor: Colors.orange,
            ),
          );
        } else if (state is GenerateSummaryError) {
          setState(() {
            _isSummaryLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to generate summary: ${state.message.errMessage}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            ChapterDetailAppBar(title: widget.chapter.title),

            SliverToBoxAdapter(
              child: ChapterPreviewSection(
                chapter: widget.chapter,
                formatDate: _formatDate,
                onDownloadPDF: _downloadChapterPDF,
              ),
            ),

            SliverToBoxAdapter(
              child: AISummarySection(
                isSummaryAvailable:
                    _summaryData != null || _rawSummaryText != null,
                isSummaryLoading: _isSummaryLoading,
                onViewSummary: _viewSummary,
                onGenerateSummary: _generateSummary,
              ),
            ),

            // Mind Map Section
            SliverToBoxAdapter(
              child: MindMapSection(
                onOpen: () {
                  // TODO: Implement Mind Map functionality
                },
              ),
            ),

            // Notes Section
            SliverToBoxAdapter(
              child: NotesSection(
                onOpen: () {
                  // TODO: Implement Notes functionality
                },
              ),
            ),

            // Quiz and Chatbot Tabs
            SliverToBoxAdapter(
              child: QuizChatbotTabs(
                activeTab: _activeTab,
                onTabChanged: (tab) {
                  setState(() {
                    _activeTab = tab;
                  });
                },
              ),
            ),

            // Quiz/Chatbot Content
            if (_activeTab == "quiz")
              SliverToBoxAdapter(
                child: QuizContent(
                  chapterId: widget.chapter.id,
                  chapterTitle: widget.chapter.title,
                ),
              ),
            if (_activeTab == "chatbot")
              const SliverToBoxAdapter(child: ChatbotContent()),
          ],
        ),
      ), // End of Scaffold
    ); // End of BlocListener
  }
}
