// features/folder/presentation/view/screens/chapter_detail_screen.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/core/services/summary_cache_service.dart';
import 'package:tionova/core/utils/safe_context_mixin.dart';
import 'package:tionova/features/chapter/data/models/ChapterModel.dart';
import 'package:tionova/features/chapter/data/models/SummaryModel.dart';
import 'package:tionova/features/chapter/presentation/bloc/chapter/chapter_cubit.dart';
import 'package:tionova/features/chapter/presentation/view/layouts/chapter_detail_mobile_layout.dart';
import 'package:tionova/features/chapter/presentation/view/layouts/chapter_detail_web_layout.dart';
import 'package:tionova/features/chapter/presentation/view/screens/create_chapter_screen.dart';
import 'package:tionova/utils/widgets/custom_dialogs.dart';

class ChapterDetailScreen extends StatefulWidget {
  final ChapterModel? chapter; // Made nullable for deep linking/refresh
  final String chapterId; // Added for lookups
  final String folderId; // Added for lookups
  final Color folderColor;
  final String? folderOwnerId;

  const ChapterDetailScreen({
    super.key,
    this.chapter,
    required this.chapterId,
    required this.folderId,
    required this.folderColor,
    this.folderOwnerId,
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
  String _activeTab = "";
  SummaryModel? _summaryData;
  String? _rawSummaryText;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  ChapterModel? _chapter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _chapter = widget.chapter;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _initializeData();
    _animationController.forward();
  }

  void _initializeData() {
    // If we have the chapter, load cached summary
    if (_chapter != null) {
      _checkAndLoadCachedSummary();
    } else {
      // Logic to recover chapter
      _recoverChapter();
    }
  }

  void _recoverChapter() {
    debugPrint(
      '🔎 [ChapterDetailScreen] Attempting to recover chapter ${widget.chapterId}...',
    );
    final cubit = context.read<ChapterCubit>();

    // Check if valid state already exists
    if (cubit.state is ChapterLoaded) {
      final chapters = (cubit.state as ChapterLoaded).chapters;
      if (chapters != null) {
        final found = chapters
            .where((c) => c.id == widget.chapterId)
            .firstOrNull;
        if (found != null) {
          setState(() {
            _chapter = found;
          });
          _checkAndLoadCachedSummary();
          return;
        }
      }
    }

    // Fetch chapters for the folder
    debugPrint(
      '🔄 [ChapterDetailScreen] Fetching chapters for folder ${widget.folderId}',
    );
    if (widget.folderId.isNotEmpty) {
      cubit.getChapters(folderId: widget.folderId);
    } else {
      debugPrint(
        '⚠️ [ChapterDetailScreen] Skipping getChapters: empty folderId (standalone chapter route)',
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && mounted && _chapter != null) {
      _checkAndLoadCachedSummary();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (mounted && _summaryData == null && _chapter != null) {
      _checkAndLoadCachedSummary();
    }
  }

  void _checkAndLoadCachedSummary() {
    if (_chapter == null) return;

    final chapterId = _chapter!.id;
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
    context.read<ChapterCubit>().checkCachedSummary(chapterId: chapterId);
  }

  Future<void> _generateSummary() async {
    if (_chapter == null) return;
    try {
      final chapterId = _chapter!.id;
      final summaryId = _chapter!.summaryId;

      if (summaryId != null && summaryId.isNotEmpty) {
        context.read<ChapterCubit>().getChapterSummary(chapterId: chapterId);
      } else {
        context.read<ChapterCubit>().generateSummary(
          chapterId: chapterId,
          chapterTitle: _chapter!.title,
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

  void _viewSummary() {
    if (_chapter == null) return;

    final folderId = _chapter!.folderId;
    final chapterId = _chapter!.id;
    final hasFolder = folderId != null && folderId.isNotEmpty;

    if (_summaryData != null) {
      final path = hasFolder
          ? '/folders/$folderId/chapters/$chapterId/summary'
          : '/chapters/$chapterId/summary';
      if (kIsWeb) {
        context.go(
          path,
          extra: {
            'summaryData': _summaryData!,
            'chapterTitle': _chapter!.title ?? 'Chapter',
            'accentColor': widget.folderColor,
            'folderId': folderId,
          },
        );
      } else {
        context.push(
          path,
          extra: {
            'summaryData': _summaryData!,
            'chapterTitle': _chapter!.title ?? 'Chapter',
            'accentColor': widget.folderColor,
            'folderId': folderId,
          },
        );
      }
    } else if (_rawSummaryText != null) {
      final path = hasFolder
          ? '/folders/$folderId/chapters/$chapterId/raw-summary'
          : '/chapters/$chapterId/raw-summary';
      if (kIsWeb) {
        context.go(
          path,
          extra: {
            'summaryText': _rawSummaryText!,
            'chapterTitle': _chapter!.title ?? 'Chapter',
            'accentColor': widget.folderColor,
            'folderId': folderId,
          },
        );
      } else {
        context.push(
          path,
          extra: {
            'summaryText': _rawSummaryText!,
            'chapterTitle': _chapter!.title ?? 'Chapter',
            'accentColor': widget.folderColor,
            'folderId': folderId,
          },
        );
      }
    }
  }

  void _viewPDF() {
    if (_chapter == null) return;

    final folderId = _chapter!.folderId;
    final chapterId = _chapter!.id;
    final hasFolder = folderId != null && folderId.isNotEmpty;

    final path = hasFolder
        ? '/folders/$folderId/chapters/$chapterId/pdf'
        : '/chapters/$chapterId/pdf';

    if (kIsWeb) {
      context.go(
        path,
        extra: {
          'chapterTitle': _chapter!.title ?? 'Chapter',
          'chapterCubit': context.read<ChapterCubit>(),
          'folderId': folderId,
        },
      );
    } else {
      context.push(
        path,
        extra: {
          'chapterTitle': _chapter!.title ?? 'Chapter',
          'chapterCubit': context.read<ChapterCubit>(),
          'folderId': folderId,
        },
      );
    }
  }

  Future<void> _generateMindmap() async {
    if (_chapter == null) return;
    try {
      final chapterId = _chapter!.id;
      final mindmapId = _chapter!.mindmapId;

      setState(() {
        _isMindmapLoading = true;
      });

      if (mindmapId != null && mindmapId.isNotEmpty) {
        context.read<ChapterCubit>().getMindmap(chapterId: chapterId);
      } else {
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

  @override
  Widget build(BuildContext context) {
    // FIX: Handle routing conflict where 'chapters/new' is interpreted as a chapterId
    if (widget.chapterId == 'new') {
      return CreateChapterScreen(
        folderId: widget.folderId,
        folderTitle: 'New Chapter',
      );
    }

    final size = MediaQuery.of(context).size;
    final isWeb = size.width > 900;

    // If chapter is null, show loading or error
    if (_chapter == null) {
      return BlocListener<ChapterCubit, ChapterState>(
        listener: (context, state) {
          if (state is ChapterLoaded) {
            final found = state.chapters
                ?.where((c) => c.id == widget.chapterId)
                .firstOrNull;
            if (found != null) {
              setState(() {
                _chapter = found;
              });
              _checkAndLoadCachedSummary();
            }
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Loading...')),
          body: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return BlocListener<ChapterCubit, ChapterState>(
      listener: (context, state) {
        // Listen for list updates that might impact our current chapter
        if (state is ChapterLoaded) {
          final found = state.chapters
              ?.where((c) => c.id == widget.chapterId)
              .firstOrNull;
          if (found != null && found != _chapter) {
            setState(() {
              _chapter = found;
            });
          }
        }

        // Handle mindmap generation
        if (state is CreateMindmapLoading) {
          setState(() {
            _isMindmapLoading = true;
          });
        } else if (state is CreateMindmapSuccess) {
          setState(() {
            _isMindmapLoading = false;
          });
          final folderId = _chapter!.folderId;
          final chapterId = _chapter!.id;
          final hasFolder = folderId != null && folderId.isNotEmpty;
          final path = hasFolder
              ? '/folders/$folderId/chapters/$chapterId/mindmap'
              : '/chapters/$chapterId/mindmap';
          if (kIsWeb) {
            context.go(
              path,
              extra: {
                'mindmap': state.mindmap,
                'folderId': folderId,
                'chapterId': chapterId,
              },
            );
          } else {
            context.push(
              path,
              extra: {
                'mindmap': state.mindmap,
                'folderId': folderId,
                'chapterId': chapterId,
              },
            );
          }
        } else if (state is CreateMindmapError) {
          setState(() {
            _isMindmapLoading = false;
          });
          CustomDialogs.showErrorDialog(
            context,
            title: 'Error!',
            message: 'Failed to generate mindmap: ${state.message.errMessage}',
          );
        } else if (state is GetChapterContentPdfSuccess) {
          // PDF download logic (commented out in original)
        } else if (state is GetChapterContentPdfError) {
          if (state.forDownload) {
            GoRouter.of(context).pop();
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
            _rawSummaryText = null;
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
        } else if (state is GenerateSummarySuccess) {
          setState(() {
            _isSummaryLoading = false;
            _rawSummaryText = state.summary;
            _summaryData = null;
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
      ),
    );
  }

  Widget _buildWebLayout() {
    return ChapterDetailWebLayout(
      chapter: _chapter!,
      folderColor: widget.folderColor,
      isSummaryLoading: _isSummaryLoading,
      isMindmapLoading: _isMindmapLoading,
      activeTab: _activeTab,
      summaryData: _summaryData,
      rawSummaryText: _rawSummaryText,
      onDownloadPDF: _viewPDF,
      onGenerateSummary: _generateSummary,
      onViewSummary: _viewSummary,
      onGenerateMindmap: _generateMindmap,
      onTabChanged: (tab) {
        setState(() {
          _activeTab = tab;
        });
      },
      folderOwnerId: widget.folderOwnerId,
    );
  }

  Widget _buildMobileLayout() {
    return ChapterDetailMobileLayout(
      chapter: _chapter!,
      folderColor: widget.folderColor,
      isSummaryLoading: _isSummaryLoading,
      isMindmapLoading: _isMindmapLoading,
      activeTab: _activeTab,
      summaryData: _summaryData,
      rawSummaryText: _rawSummaryText,
      onDownloadPDF: _viewPDF,

      onGenerateSummary: _generateSummary,
      onViewSummary: _viewSummary,
      onGenerateMindmap: _generateMindmap,
      onTabChanged: (tab) {
        setState(() {
          _activeTab = tab;
        });
      },
      folderOwnerId: widget.folderOwnerId,
    );
  }
}
