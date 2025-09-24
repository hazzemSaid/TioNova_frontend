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
import 'package:tionova/features/folder/presentation/view/screens/pdf_viewer_screen.dart';
import 'package:provider/provider.dart';
import 'package:tionova/core/get_it/services_locator.dart';
import 'package:tionova/features/quiz/presentation/bloc/quizcubit.dart';
import 'package:tionova/features/quiz/presentation/view/quiz_screen.dart';

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
  bool _isCachedSummary = false; // Track if current summary is from cache
  String _cacheAge = ""; // Store cache age for display

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
          _isCachedSummary = true;
          _cacheAge = cachedData.cacheAge;
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

  // Quiz Content Widget
  Widget _buildQuizContent() {
    // Use a distinct purple color for the quiz section
    final Color quizAccentColor = Color(0xFF8E44AD);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.quiz_outlined, size: 24, color: quizAccentColor),
          ),
          const SizedBox(height: 16),
          const Text(
            'Test Your Knowledge',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Take a quiz based on this chapter to test your understanding',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),

          // Quiz Buttons
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              final token = await TokenStorage.getAccessToken();
              if (!mounted) return;
              
              if (token != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Provider<QuizCubit>(
                      create: (context) => getIt<QuizCubit>(),
                      child: QuizScreen(
                        token: token,
                        chapterId: widget.chapter.id ?? '',
                      ),
                    ),
                  ),
                );
              } else {
                // Handle case where token is not available
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please login to take the quiz')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              backgroundColor: quizAccentColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            child: const Text(
              'Start New Quiz',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 46),
                    side: const BorderSide(color: Color(0xFF1C1C1E)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(23),
                    ),
                  ),
                  child: Text(
                    'Practice Mode',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 46),
                    side: const BorderSide(color: Color(0xFF1C1C1E)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(23),
                    ),
                  ),
                  icon: Icon(
                    Icons.history,
                    color: Colors.white.withOpacity(0.8),
                    size: 18,
                  ),
                  label: Text(
                    'History',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Chatbot Content Widget
  Widget _buildChatbotContent() {
    // Use a distinct teal color for the chatbot section
    final Color chatbotAccentColor = Color(0xFF16A085);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 24,
              color: chatbotAccentColor,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ask Questions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Chat with AI about this chapter to clarify concepts',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),

          // Chatbot Button
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              backgroundColor: chatbotAccentColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            child: const Text(
              'Start Conversation',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build status chip/badge
  Widget _buildStatusBadge(String status) {
    Color bgColor;

    // Define colors based on status
    switch (status.toLowerCase()) {
      case 'passed':
        bgColor = const Color(0xFF28A745);
        break;
      case 'failed':
        bgColor = const Color(0xFFDC3545);
        break;
      case 'in progress':
        bgColor = const Color(0xFFFFC107);
        break;
      default:
        bgColor = const Color(0xFF6C757D);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: status.toLowerCase() == 'in progress'
              ? Colors.black
              : Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
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

  // Handle summary regeneration
  Future<void> _regenerateSummary() async {
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
      context.read<ChapterCubit>().regenerateSummary(
        token: token,
        chapterId: chapterId,
        chapterTitle: widget.chapter.title,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to regenerate summary: $e'),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final horizontalPadding = screenWidth * (isTablet ? 0.08 : 0.05);

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
            _isCachedSummary = false; // This is a fresh summary
            _cacheAge = "Just generated";
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
            _isCachedSummary = true;
            _cacheAge = state.cacheAge;
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
            // App bar with back button, title and share button
            SliverAppBar(
              backgroundColor: Colors.black,
              pinned: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                widget.chapter.title ?? 'Chapter Preview',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share_outlined, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),

            // Chapter preview section
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.all(horizontalPadding),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E0E10),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1C1C1E)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with title and status
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Chapter Preview',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '${widget.chapter.quizScore ?? 0} pages',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildStatusBadge(
                                widget.chapter.quizStatus ?? 'Not Started',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // PDF Preview
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PDFViewerScreen(
                              chapterId: widget.chapter.id!,
                              chapterTitle: widget.chapter.title ?? 'Chapter',
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 200,
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C1C1E),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF1C1C1E)),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2C2C2E),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.description_outlined,
                                  size: 24,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'PDF Preview',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to view full document',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Last opened info
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Last opened',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatDate(widget.chapter.createdAt),
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Download button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: ElevatedButton.icon(
                        onPressed: _downloadChapterPDF,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                          backgroundColor: const Color(0xFF1C1C1E),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        icon: const Icon(
                          Icons.download_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: const Text(
                          'Download PDF',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // AI Summary Section
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  0,
                  horizontalPadding,
                  16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E0E10),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1C1C1E)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with cache status indicator
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.smart_toy_outlined,
                            color: Colors.white70,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'AI-Generated Summary',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          // Cache status indicator
                          if (_summaryData != null || _rawSummaryText != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _summaryData != null
                                    ? (_isCachedSummary
                                          ? Colors.blue.withOpacity(0.2)
                                          : Colors.green.withOpacity(0.2))
                                    : Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _summaryData != null
                                      ? (_isCachedSummary
                                            ? Colors.blue.withOpacity(0.5)
                                            : Colors.green.withOpacity(0.5))
                                      : Colors.orange.withOpacity(0.5),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _summaryData != null
                                        ? (_isCachedSummary
                                              ? Icons.cached
                                              : Icons.new_releases)
                                        : Icons.text_snippet,
                                    size: 12,
                                    color: _summaryData != null
                                        ? (_isCachedSummary
                                              ? Colors.blue
                                              : Colors.green)
                                        : Colors.orange,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _summaryData != null
                                        ? (_isCachedSummary
                                              ? 'Cached'
                                              : 'Fresh')
                                        : 'Text Format',
                                    style: TextStyle(
                                      color: _summaryData != null
                                          ? (_isCachedSummary
                                                ? Colors.blue
                                                : Colors.green)
                                          : Colors.orange,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Summary content or CTA with cache info
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (_summaryData != null || _rawSummaryText != null)
                                ? (_summaryData != null
                                      ? (_isCachedSummary
                                            ? 'AI summary available from cache ($_cacheAge). View or regenerate to get updated insights.'
                                            : 'Fresh AI summary generated. View the insights or regenerate if needed.')
                                      : 'AI summary generated in text format. View the summary or regenerate for structured format.')
                                : 'Generate an AI-powered summary of this chapter to get key insights and main concepts.',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),

                          // Show cache age for cached summaries
                          if (_summaryData != null && _isCachedSummary)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 14,
                                    color: Colors.grey[500],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Cached $_cacheAge',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Generate button for new summaries
                    if (_summaryData == null && _rawSummaryText == null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: ElevatedButton.icon(
                          onPressed: _isSummaryLoading
                              ? null
                              : _generateSummary,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 52),
                            backgroundColor: _isSummaryLoading
                                ? const Color(0xFF2C2C2E)
                                : widget.folderColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          icon: _isSummaryLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.auto_awesome,
                                  color: Colors.white,
                                  size: 20,
                                ),
                          label: Text(
                            _isSummaryLoading
                                ? 'Generating Summary...'
                                : 'Generate AI Summary',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                    // Action buttons when summary exists
                    if (_summaryData != null || _rawSummaryText != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          children: [
                            // View Summary button - Primary action
                            ElevatedButton.icon(
                              onPressed: _viewSummary,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 52),
                                backgroundColor: widget.folderColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(26),
                                ),
                              ),
                              icon: const Icon(
                                Icons.visibility,
                                color: Colors.white,
                                size: 20,
                              ),
                              label: Text(
                                _isCachedSummary
                                    ? 'View Cached Summary'
                                    : 'View Summary',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Regenerate button - Secondary action
                            OutlinedButton.icon(
                              onPressed: _isSummaryLoading
                                  ? null
                                  : _regenerateSummary,
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                                side: BorderSide(
                                  color: _isSummaryLoading
                                      ? const Color(0xFF2C2C2E)
                                      : const Color(0xFF1C1C1E),
                                  width: 1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              icon: _isSummaryLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        color: Colors.white70,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(
                                      Icons.refresh,
                                      color: _isSummaryLoading
                                          ? Colors.grey
                                          : Colors.white.withOpacity(0.8),
                                      size: 18,
                                    ),
                              label: Text(
                                _isSummaryLoading
                                    ? 'Regenerating...'
                                    : (_isCachedSummary
                                          ? 'Generate Fresh Summary'
                                          : 'Regenerate Summary'),
                                style: TextStyle(
                                  color: _isSummaryLoading
                                      ? Colors.grey
                                      : Colors.white.withOpacity(0.8),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ), // Quiz and Chatbot Section
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  0,
                  horizontalPadding,
                  16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E0E10),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1C1C1E)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tab Selector
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: const Color(0xFF1C1C1E),
                            width: 1,
                          ),
                        ),
                        color: const Color(0xFF1C1C1E),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Quiz Tab
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _activeTab = _activeTab == "quiz"
                                      ? ""
                                      : "quiz";
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: _activeTab == "quiz"
                                      ? Border(
                                          bottom: BorderSide(
                                            color: Color(0xFF8E44AD),
                                            width: 2,
                                          ),
                                        )
                                      : null,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.quiz_outlined,
                                      color: _activeTab == "quiz"
                                          ? Color(0xFF8E44AD)
                                          : Color(0xFF8E8E93),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Quiz',
                                      style: TextStyle(
                                        color: _activeTab == "quiz"
                                            ? Color(0xFF8E44AD)
                                            : Color(0xFF8E8E93),
                                        fontSize: 16,
                                        fontWeight: _activeTab == "quiz"
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Chatbot Tab
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _activeTab = _activeTab == "chatbot"
                                      ? ""
                                      : "chatbot";
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: _activeTab == "chatbot"
                                      ? Border(
                                          bottom: BorderSide(
                                            color: Color(0xFF16A085),
                                            width: 2,
                                          ),
                                        )
                                      : null,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline,
                                      color: _activeTab == "chatbot"
                                          ? Color(0xFF16A085)
                                          : Color(0xFF8E8E93),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Chatbot',
                                      style: TextStyle(
                                        color: _activeTab == "chatbot"
                                            ? Color(0xFF16A085)
                                            : Color(0xFF8E8E93),
                                        fontSize: 16,
                                        fontWeight: _activeTab == "chatbot"
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content Area - Show content based on active tab
                    if (_activeTab == "quiz") _buildQuizContent(),
                    if (_activeTab == "chatbot") _buildChatbotContent(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ), // End of Scaffold
    ); // End of BlocListener
  }
}
