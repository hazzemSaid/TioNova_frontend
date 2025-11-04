// features/folder/presentation/view/screens/chapter_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tionova/core/services/download_service.dart';
import 'package:tionova/core/services/summary_cache_service.dart';
import 'package:tionova/core/utils/safe_context_mixin.dart';
import 'package:tionova/features/auth/data/services/Tokenstorage.dart';
import 'package:tionova/features/folder/data/models/ChapterModel.dart';
import 'package:tionova/features/folder/data/models/SummaryModel.dart';
import 'package:tionova/features/folder/presentation/bloc/chapter/chapter_cubit.dart';
import 'package:tionova/features/folder/presentation/view/widgets/ai_summary_section.dart';
import 'package:tionova/features/folder/presentation/view/widgets/chapter_detail_app_bar.dart';
import 'package:tionova/features/folder/presentation/view/widgets/chapter_preview_section.dart';
import 'package:tionova/features/folder/presentation/view/widgets/chatbot_content.dart';
import 'package:tionova/features/folder/presentation/view/widgets/mind_map_section.dart';
import 'package:tionova/features/folder/presentation/view/widgets/notes_section.dart';
import 'package:tionova/features/folder/presentation/view/widgets/quiz_chatbot_tabs.dart';
import 'package:tionova/features/folder/presentation/view/widgets/quiz_content.dart';
import 'package:tionova/utils/widgets/custom_dialogs.dart';

class ChapterDetailScreen extends StatefulWidget {
  final ChapterModel chapter;
  final Color folderColor;

  const ChapterDetailScreen({
    super.key,
    required this.chapter,
    required this.folderColor,
  });

  @override
  State<ChapterDetailScreen> createState() => _ChapterDetailScreenState();
}

class _ChapterDetailScreenState extends State<ChapterDetailScreen>
    with
        WidgetsBindingObserver,
        SingleTickerProviderStateMixin,
        SafeContextMixin {
  bool _isSummaryLoading = false;
  bool _isMindmapLoading = false;
  String _activeTab = ""; // Empty string means no tab is selected
  SummaryModel? _summaryData; // Store the parsed summary data
  String? _rawSummaryText; // Store raw text summary when JSON parsing fails
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Add observer to detect app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    // Check for cached summary on screen load
    _checkAndLoadCachedSummary();
  }

  @override
  void dispose() {
    // Remove observer when disposing
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
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
        CustomDialogs.showErrorDialog(
          context,
          title: 'Error!',
          message: 'Authentication required',
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
      CustomDialogs.showErrorDialog(
        context,
        title: 'Error!',
        message: 'Failed to generate summary: $e',
      );
    }
  }

  // Navigate to summary viewer
  void _viewSummary() {
    if (_summaryData != null) {
      // Navigate to structured summary viewer
      context.push(
        '/summary-viewer',
        extra: {
          'summaryData': _summaryData!,
          'chapterTitle': widget.chapter.title ?? 'Chapter',
          'accentColor': widget.folderColor,
        },
      );
    } else if (_rawSummaryText != null) {
      // Navigate to raw text summary viewer
      context.push(
        '/raw-summary-viewer',
        extra: {
          'summaryText': _rawSummaryText!,
          'chapterTitle': widget.chapter.title ?? 'Chapter',
          'accentColor': widget.folderColor,
        },
      );
    }
  }

  // Handle mindmap generation
  Future<void> _generateMindmap() async {
    try {
      final token = await TokenStorage.getAccessToken();
      if (token == null) {
        CustomDialogs.showErrorDialog(
          context,
          title: 'Error!',
          message: 'Authentication required',
        );
        return;
      }

      final chapterId = widget.chapter.id ?? '';
      setState(() {
        _isMindmapLoading = true;
      });

      context.read<ChapterCubit>().createMindmap(
        token: token,
        chapterId: chapterId,
      );
    } catch (e) {
      setState(() {
        _isMindmapLoading = false;
      });
      CustomDialogs.showErrorDialog(
        context,
        title: 'Error!',
        message: 'Failed to generate mindmap: $e',
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
            CustomDialogs.showSuccessDialog(
              context,
              title: 'Success!',
              message: 'PDF downloaded from cache',
            );
          }
          return;
        }
      }

      // If not cached, fetch from API
      print('Fetching PDF from API for download');
      final token = await TokenStorage.getAccessToken();
      if (token == null) {
        CustomDialogs.showErrorDialog(
          context,
          title: 'Error!',
          message: 'Authentication required',
        );
        return;
      }

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );

      // Fetch PDF content using the cubit
      context.read<ChapterCubit>().getChapterContentPdf(
        token: token,
        chapterId: chapterId,
        forDownload: true, // This is a download operation
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      CustomDialogs.showErrorDialog(
        context,
        title: 'Error!',
        message: 'Download failed: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWeb = size.width > 900;

    return BlocListener<ChapterCubit, ChapterState>(
      listener: (context, state) {
        // Handle mindmap generation
        if (state is CreateMindmapLoading) {
          setState(() {
            _isMindmapLoading = true;
          });
        } else if (state is CreateMindmapSuccess) {
          setState(() {
            _isMindmapLoading = false;
          });
          // Navigate to mindmap viewer
          context.pushNamed(
            'mindmap-viewer',
            extra: {'mindmap': state.mindmap},
          );
        } else if (state is CreateMindmapError) {
          setState(() {
            _isMindmapLoading = false;
          });
          CustomDialogs.showErrorDialog(
            context,
            title: 'Error!',
            message: 'Failed to generate mindmap: ${state.message.errMessage}',
          );
        }
        // Handle PDF download
        else if (state is GetChapterContentPdfSuccess) {
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
            CustomDialogs.showErrorDialog(
              context,
              title: 'Error!',
              message: 'Download failed: ${state.message.errMessage}',
            );
          }
        } else if (state is SummaryCachedFound) {
          setState(() {
            _isSummaryLoading = false;
            _summaryData = state.summaryData;
          });
          CustomDialogs.showInfoDialog(
            context,
            title: 'Cache',
            message: 'Summary loaded from cache (${state.cacheAge})',
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
          CustomDialogs.showSuccessDialog(
            context,
            title: 'Success!',
            message: message,
          );
        } else if (state is SummaryCachedFound) {
          setState(() {
            _isSummaryLoading = false;
            _summaryData = state.summaryData;
            _rawSummaryText =
                null; // Clear raw text when we get cached structured data
          });
          CustomDialogs.showInfoDialog(
            context,
            title: 'Cache',
            message: 'Found cached summary (${state.cacheAge})',
          );
        } else if (state is GenerateSummarySuccess) {
          setState(() {
            _isSummaryLoading = false;
            _rawSummaryText = state.summary; // Store the raw text summary
            _summaryData = null; // Clear structured data when we get raw text
          });
          CustomDialogs.showInfoDialog(
            context,
            title: 'Info',
            message: 'Summary generated (text format)',
          );
        } else if (state is GenerateSummaryError) {
          setState(() {
            _isSummaryLoading = false;
          });
          CustomDialogs.showErrorDialog(
            context,
            title: 'Error!',
            message: 'Failed to generate summary: ${state.message.errMessage}',
          );
        }
      },
      child: Scaffold(
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: isWeb ? _buildWebLayout() : _buildMobileLayout(),
        ),
      ), // End of Scaffold
    ); // End of BlocListener
  }

  Widget _buildWebLayout() {
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
                          widget.chapter.title ?? 'Chapter',
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
                  Container(
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
                              bottom: BorderSide(
                                color: colorScheme.outline,
                                width: 1,
                              ),
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
                            border: Border.all(
                              color: colorScheme.outline,
                              width: 1,
                            ),
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
                                  padding: EdgeInsets.only(left: 28),
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
                                  padding: EdgeInsets.only(left: 28),
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
                                  onPressed: _downloadChapterPDF,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.surfaceVariant,
                                    foregroundColor: colorScheme.onSurface,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                        color: colorScheme.outline,
                                        width: 1,
                                      ),
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
                                    side: BorderSide(
                                      color: colorScheme.outline,
                                      width: 1,
                                    ),
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
                  ),
                  const SizedBox(width: 24),
                  // Right content area
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // AI Summary Card
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colorScheme.outline,
                              width: 1,
                            ),
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
                                onPressed: _isSummaryLoading
                                    ? null
                                    : (_summaryData != null ||
                                          _rawSummaryText != null)
                                    ? _viewSummary
                                    : _generateSummary,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: colorScheme.onPrimary,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.auto_awesome_rounded,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _isSummaryLoading
                                          ? 'Generating...'
                                          : 'View Full Summary',
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
                                onPressed: _downloadChapterPDF,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: colorScheme.onSurface,
                                  side: BorderSide(
                                    color: colorScheme.outline,
                                    width: 1,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 14,
                                  ),
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
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Mind Map and Smart Notes Row
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(28),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: colorScheme.outline,
                                    width: 1,
                                  ),
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
                                        onPressed: _isMindmapLoading
                                            ? null
                                            : _generateMindmap,
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor:
                                              colorScheme.onSurface,
                                          side: BorderSide(
                                            color: colorScheme.outline,
                                            width: 1,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              _isMindmapLoading
                                                  ? Icons.hourglass_empty
                                                  : Icons.account_tree_rounded,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _isMindmapLoading
                                                  ? 'Generating...'
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
                                  border: Border.all(
                                    color: colorScheme.outline,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: colorScheme.secondary
                                            .withOpacity(0.2),
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
                                        color: colorScheme.onSecondaryContainer
                                            .withOpacity(0.7),
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
                                          final chapterCubit = context
                                              .read<ChapterCubit>();
                                          final chapterId =
                                              widget.chapter.id?.isNotEmpty ==
                                                  true
                                              ? widget.chapter.id!
                                              : 'temp';
                                          context.pushNamed(
                                            'chapter-notes',
                                            pathParameters: {
                                              'chapterId': chapterId,
                                            },
                                            extra: {
                                              'chapterTitle':
                                                  widget.chapter.title ??
                                                  'Chapter',
                                              'accentColor': widget.folderColor,
                                              'chapterCubit': chapterCubit,
                                            },
                                          );
                                        },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor:
                                              colorScheme.onSecondaryContainer,
                                          side: BorderSide(
                                            color: colorScheme.secondary,
                                            width: 1,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.description_outlined,
                                              size: 18,
                                            ),
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
                        ),
                        const SizedBox(height: 20),
                        // Test Your Knowledge and Your Stats Row
                        Row(
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
                                  border: Border.all(
                                    color: colorScheme.outline,
                                    width: 1,
                                  ),
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
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                                                  color: colorScheme
                                                      .onSurfaceVariant,
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
                                              final token =
                                                  await TokenStorage.getAccessToken();
                                              if (!mounted) return;
                                              if (token != null) {
                                                context.push(
                                                  '/quiz/${widget.chapter.id ?? ''}',
                                                  extra: {'token': token},
                                                );
                                              } else {
                                                if (!mounted) return;
                                                CustomDialogs.showErrorDialog(
                                                  context,
                                                  title: 'Error!',
                                                  message:
                                                      'Please login to take the quiz',
                                                );
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  colorScheme.primary,
                                              foregroundColor:
                                                  colorScheme.onPrimary,
                                              elevation: 0,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 16,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            child: const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.emoji_events_outlined,
                                                  size: 20,
                                                ),
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
                                              message:
                                                  'Practice mode coming soon!',
                                            );
                                          },
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor:
                                                colorScheme.onSurface,
                                            side: BorderSide(
                                              color: colorScheme.outline,
                                              width: 1,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
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
                                            final token =
                                                await TokenStorage.getAccessToken();
                                            if (!mounted) return;
                                            if (token == null) {
                                              CustomDialogs.showErrorDialog(
                                                context,
                                                title: 'Error!',
                                                message:
                                                    'Please login to view history',
                                              );
                                              return;
                                            }
                                            context.push(
                                              '/quiz-history/${widget.chapter.id ?? ''}',
                                              extra: {
                                                'token': token,
                                                'quizTitle':
                                                    widget.chapter.title ?? '',
                                              },
                                            );
                                          },
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor:
                                                colorScheme.onSurfaceVariant,
                                            side: BorderSide(
                                              color: colorScheme.outline,
                                              width: 1,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
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
                                  border: Border.all(
                                    color: colorScheme.outline,
                                    width: 1,
                                  ),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                        backgroundColor:
                                            colorScheme.surfaceVariant,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              colorScheme.tertiary,
                                            ),
                                        minHeight: 6,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    // Attempts
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                        ),
                        const SizedBox(height: 20),
                        // AI Learning Assistant Card
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colorScheme.outline,
                              width: 1,
                            ),
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
                                  setState(() => _activeTab = "chatbot");
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: colorScheme.onPrimary,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
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
                        ),
                        // Quiz Content - Show when quiz tab is active
                        if (_activeTab == "quiz")
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
                                chapterId: widget.chapter.id,
                                chapterTitle: widget.chapter.title,
                              ),
                            ),
                          ),
                        // Chatbot Content - Show when chatbot tab is active
                        if (_activeTab == "chatbot")
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

  Widget _buildMobileLayout() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),

      slivers: [
        ChapterDetailAppBar(title: widget.chapter.title),

        SliverToBoxAdapter(
          child: ChapterPreviewSection(
            chapter: widget.chapter,
            formatDate: _formatDate,
            onDownloadPDF: _downloadChapterPDF,
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 8)),

        SliverToBoxAdapter(
          child: AISummarySection(
            isSummaryAvailable: _summaryData != null || _rawSummaryText != null,
            isSummaryLoading: _isSummaryLoading,
            onViewSummary: _viewSummary,
            onGenerateSummary: _generateSummary,
          ),
        ),

        SliverToBoxAdapter(
          child: MindMapSection(
            isLoading: _isMindmapLoading,
            onOpen: _generateMindmap,
          ),
        ),

        SliverToBoxAdapter(
          child: NotesSection(
            chapterId: widget.chapter.id ?? '',
            chapterTitle: widget.chapter.title ?? 'Chapter',
            accentColor: widget.folderColor,
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 8)),

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

        if (_activeTab == "quiz")
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
                chapterId: widget.chapter.id,
                chapterTitle: widget.chapter.title,
              ),
            ),
          ),
        if (_activeTab == "chatbot")
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
