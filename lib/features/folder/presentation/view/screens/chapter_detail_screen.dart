// features/folder/presentation/view/screens/chapter_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tionova/core/services/download_service.dart';
import 'package:tionova/core/services/summary_cache_service.dart';
import 'package:tionova/core/utils/safe_context_mixin.dart';
import 'package:tionova/features/folder/data/models/ChapterModel.dart';
import 'package:tionova/features/folder/data/models/SummaryModel.dart';
import 'package:tionova/features/folder/presentation/bloc/chapter/chapter_cubit.dart';
import 'package:tionova/features/folder/presentation/view/layouts/chapter_detail_mobile_layout.dart';
import 'package:tionova/features/folder/presentation/view/layouts/chapter_detail_web_layout.dart';
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

  // Handle summary generation or fetching
  Future<void> _generateSummary() async {
    try {
      final chapterId = widget.chapter.id;
      final summaryId = widget.chapter.summaryId;

      if (summaryId != null && summaryId.isNotEmpty) {
        // Fetch existing summary
        context.read<ChapterCubit>().getChapterSummary(chapterId: chapterId);
      } else {
        // Generate new summary
        context.read<ChapterCubit>().generateSummary(
          chapterId: chapterId,
          chapterTitle: widget.chapter.title,
        );
      }
    } catch (e) {
      CustomDialogs.showErrorDialog(
        context,
        title: 'Error!',
        message: 'Failed to process summary: $e',
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

  // Handle mindmap generation or fetching
  Future<void> _generateMindmap() async {
    try {
      final chapterId = widget.chapter.id;
      final mindmapId = widget.chapter.mindmapId;

      setState(() {
        _isMindmapLoading = true;
      });

      if (mindmapId != null && mindmapId.isNotEmpty) {
        // Fetch existing mindmap
        context.read<ChapterCubit>().getMindmap(chapterId: chapterId);
      } else {
        // Generate new mindmap
        context.read<ChapterCubit>().createMindmap(chapterId: chapterId);
      }
    } catch (e) {
      setState(() {
        _isMindmapLoading = false;
      });
      CustomDialogs.showErrorDialog(
        context,
        title: 'Error!',
        message: 'Failed to process mindmap: $e',
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
    return ChapterDetailWebLayout(
      chapter: widget.chapter,
      folderColor: widget.folderColor,
      isSummaryLoading: _isSummaryLoading,
      isMindmapLoading: _isMindmapLoading,
      activeTab: _activeTab,
      summaryData: _summaryData,
      rawSummaryText: _rawSummaryText,
      onDownloadPDF: _downloadChapterPDF,
      onGenerateSummary: _generateSummary,
      onViewSummary: _viewSummary,
      onGenerateMindmap: _generateMindmap,
      onTabChanged: (tab) {
        setState(() {
          _activeTab = tab;
        });
      },
    );
  }

  Widget _buildMobileLayout() {
    return ChapterDetailMobileLayout(
      chapter: widget.chapter,
      folderColor: widget.folderColor,
      isSummaryLoading: _isSummaryLoading,
      isMindmapLoading: _isMindmapLoading,
      activeTab: _activeTab,
      summaryData: _summaryData,
      rawSummaryText: _rawSummaryText,
      formatDate: _formatDate,
      onDownloadPDF: _downloadChapterPDF,
      onGenerateSummary: _generateSummary,
      onViewSummary: _viewSummary,
      onGenerateMindmap: _generateMindmap,
      onTabChanged: (tab) {
        setState(() {
          _activeTab = tab;
        });
      },
    );
  }
}
