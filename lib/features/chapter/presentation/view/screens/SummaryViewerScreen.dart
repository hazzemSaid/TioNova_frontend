import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/core/navigation/helpers/navigation_helper.dart';
import 'package:tionova/core/utils/safe_context_mixin.dart';
import 'package:tionova/features/chapter/data/models/SummaryModel.dart';
import 'package:tionova/features/chapter/presentation/bloc/chapter/chapter_cubit.dart';
import 'package:tionova/utils/widgets/dot_painter.dart';

class SummaryViewerScreen extends StatefulWidget {
  final SummaryModel? summaryData;
  final String chapterId;
  final String? folderId;
  final String chapterTitle;
  final Color accentColor;

  const SummaryViewerScreen({
    super.key,
    this.summaryData,
    required this.chapterId,
    this.folderId,
    required this.chapterTitle,
    this.accentColor = Colors.blue,
  });

  @override
  State<SummaryViewerScreen> createState() => _SummaryViewerScreenState();
}

class _SummaryViewerScreenState extends State<SummaryViewerScreen>
    with SingleTickerProviderStateMixin, SafeContextMixin {
  late TabController _tabController;
  int _currentFlashcardIndex = 0;
  bool _showFlashcardAnswer = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // If summary data is not provided, fetch it
    if (widget.summaryData == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ChapterCubit>().getChapterSummary(
          chapterId: widget.chapterId,
        );
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'important':
        return Colors.orange;
      case 'concept':
        return Colors.blue;
      case 'example':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isWeb = size.width > 900;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: BlocBuilder<ChapterCubit, ChapterState>(
        builder: (context, state) {
          SummaryModel? currentSummary = widget.summaryData;
          bool isLoading = false;

          if (state is GenerateSummaryLoading) {
            isLoading = true;
          } else if (state is GenerateSummaryStructuredSuccess) {
            currentSummary = state.summaryData;
          } else if (state is SummaryCachedFound) {
            currentSummary = state.summaryData;
          } else if (state is GenerateSummaryError && currentSummary == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load summary',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message.errMessage,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ChapterCubit>().getChapterSummary(
                        chapterId: widget.chapterId,
                      );
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          if (currentSummary == null || isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Loading Chapter Summary...',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              // Background Pattern
              Positioned.fill(
                child: CustomPaint(
                  painter: DotPainter(
                    colorScheme.primary.withOpacity(
                      theme.brightness == Brightness.dark ? 0.05 : 0.03,
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    _buildAppBar(context, colorScheme, isWeb, currentSummary),
                    Expanded(
                      child: Center(
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: double.infinity,
                          ),
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildOverviewTab(isWeb, currentSummary),
                              _buildKeyPointsTab(isWeb, currentSummary),
                              _buildDefinitionsTab(isWeb, currentSummary),
                              _buildFlashcardsTab(isWeb, currentSummary),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    ColorScheme colorScheme,
    bool isWeb,
    SummaryModel? currentSummary,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(isWeb ? 48 : 4, 8, isWeb ? 48 : 8, 0),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.8),
        border: Border(
          bottom: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: colorScheme.onSurface,
                  size: 20,
                ),
                onPressed: () {
                  final fId = widget.folderId;
                  if (fId != null && fId.isNotEmpty) {
                    NavigationHelper.navigateToChapter(
                      context,
                      folderId: fId,
                      chapterId: widget.chapterId,
                    );
                  } else {
                    NavigationHelper.navigateToFoldersList(context);
                  }
                },
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Chapter Summary',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: isWeb ? 28 : 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      (currentSummary != null &&
                              currentSummary.chapterTitle.isNotEmpty)
                          ? currentSummary.chapterTitle
                          : widget.chapterTitle,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isWeb)
                _buildWebActions(colorScheme)
              else
                _buildMobileActions(colorScheme),
            ],
          ),
          const SizedBox(height: 16),
          _buildTabBar(colorScheme),
        ],
      ),
    );
  }

  Widget _buildWebActions(ColorScheme colorScheme) {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.download_rounded, size: 18),
          label: const Text('Export PDF'),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.accentColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileActions(ColorScheme colorScheme) {
    return IconButton(
      onPressed: () {},
      icon: Icon(Icons.save_alt_rounded, color: colorScheme.onSurface),
      style: IconButton.styleFrom(
        backgroundColor: colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildTabBar(ColorScheme colorScheme) {
    return TabBar(
      controller: _tabController,
      labelColor: widget.accentColor,
      unselectedLabelColor: colorScheme.onSurfaceVariant,
      indicatorColor: widget.accentColor,
      indicatorWeight: 4,
      dividerColor: Colors.transparent,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
      tabs: const [
        Tab(text: 'Overview'),
        Tab(text: 'Key Points'),
        Tab(text: 'Definitions'),
        Tab(text: 'Flashcards'),
      ],
    );
  }

  Widget _buildOverviewTab(bool isWeb, SummaryModel summaryData) {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: EdgeInsets.all(isWeb ? 48 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
            ),
            child: Text(
              summaryData.chapterOverview.summary,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 18,
                height: 1.8,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 48),
          if (summaryData.keyTakeaways.isNotEmpty) ...[
            Text(
              'Key Takeaways',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            isWeb
                ? LayoutBuilder(
                    builder: (context, constraints) {
                      return Wrap(
                        spacing: 24,
                        runSpacing: 24,
                        children: summaryData.keyTakeaways
                            .asMap()
                            .entries
                            .map(
                              (e) => SizedBox(
                                width: (constraints.maxWidth - 24) / 2,
                                child: _buildTakeawayCard(
                                  e.key + 1,
                                  e.value,
                                  colorScheme,
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                  )
                : Column(
                    children: summaryData.keyTakeaways
                        .asMap()
                        .entries
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildTakeawayCard(
                              e.key + 1,
                              e.value,
                              colorScheme,
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ],
          const SizedBox(height: 48),
          _buildAIBadge(colorScheme),
        ],
      ),
    );
  }

  Widget _buildTakeawayCard(int index, String text, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.accentColor.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: widget.accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$index',
              style: TextStyle(
                color: widget.accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyPointsTab(bool isWeb, SummaryModel summaryData) {
    final colorScheme = Theme.of(context).colorScheme;
    if (summaryData.keyPoints.isEmpty)
      return _buildEmptyState(
        Icons.lightbulb_outline,
        'No key points available',
        colorScheme,
      );

    return GridView.builder(
      padding: EdgeInsets.all(isWeb ? 48 : 16),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 600,
        mainAxisExtent: isWeb ? 220 : 200,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: summaryData.keyPoints.length,
      itemBuilder: (context, index) {
        final kp = summaryData.keyPoints[index];
        final typeColor = _getTypeColor(kp.type);
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: typeColor.withOpacity(0.2), width: 2),
            boxShadow: [
              BoxShadow(
                color: typeColor.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: typeColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        kp.type.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        kp.title,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    kp.content,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDefinitionsTab(bool isWeb, SummaryModel summaryData) {
    final colorScheme = Theme.of(context).colorScheme;
    if (summaryData.definitions.isEmpty)
      return _buildEmptyState(
        Icons.menu_book_outlined,
        'No definitions available',
        colorScheme,
      );

    return ListView.builder(
      padding: EdgeInsets.all(isWeb ? 48 : 16),
      itemCount: summaryData.definitions.length,
      itemBuilder: (context, index) {
        final def = summaryData.definitions[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: widget.accentColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      def.term,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      def.definition,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFlashcardsTab(bool isWeb, SummaryModel summaryData) {
    final colorScheme = Theme.of(context).colorScheme;
    if (summaryData.flashcards.isEmpty)
      return _buildEmptyState(
        Icons.style_outlined,
        'No flashcards available',
        colorScheme,
      );

    final card = summaryData.flashcards[_currentFlashcardIndex];
    return Padding(
      padding: EdgeInsets.all(isWeb ? 48 : 16),
      child: Column(
        children: [
          Text(
            'Card ${_currentFlashcardIndex + 1} / ${summaryData.flashcards.length}',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isWeb ? 24 : 12),
          Expanded(
            child: GestureDetector(
              onTap: () =>
                  setState(() => _showFlashcardAnswer = !_showFlashcardAnswer),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                layoutBuilder:
                    (Widget? currentChild, List<Widget> previousChildren) {
                      return Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          ...previousChildren,
                          if (currentChild != null) currentChild,
                        ],
                      );
                    },
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return RotationTransition(
                    turns: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: Container(
                  key: ValueKey(_showFlashcardAnswer),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(isWeb ? 32 : 24),
                    border: Border.all(
                      color:
                          (_showFlashcardAnswer
                                  ? Colors.green
                                  : widget.accentColor)
                              .withOpacity(0.3),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (_showFlashcardAnswer
                                    ? Colors.green
                                    : widget.accentColor)
                                .withOpacity(0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _showFlashcardAnswer
                            ? Icons.check_circle_rounded
                            : Icons.help_center_rounded,
                        size: 48,
                        color: _showFlashcardAnswer
                            ? Colors.green
                            : widget.accentColor,
                      ),
                      SizedBox(height: isWeb ? 32 : 16),
                      Text(
                        _showFlashcardAnswer ? 'THE ANSWER' : 'THE QUESTION',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                      SizedBox(height: isWeb ? 24 : 12),
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            child: Text(
                              _showFlashcardAnswer
                                  ? card.answer
                                  : card.question,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: isWeb ? 24 : 18,
                                fontWeight: FontWeight.w600,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: isWeb ? 32 : 16),
                      Text(
                        'Click to flip',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: isWeb ? 48 : 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildNavBtn(
                Icons.arrow_back_rounded,
                'Prev',
                _currentFlashcardIndex > 0
                    ? () => setState(() {
                        _currentFlashcardIndex--;
                        _showFlashcardAnswer = false;
                      })
                    : null,
                isWeb,
              ),
              SizedBox(width: isWeb ? 32 : 16),
              _buildNavBtn(
                Icons.arrow_forward_rounded,
                'Next',
                _currentFlashcardIndex < summaryData.flashcards.length - 1
                    ? () => setState(() {
                        _currentFlashcardIndex++;
                        _showFlashcardAnswer = false;
                      })
                    : null,
                isWeb,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavBtn(
    IconData icon,
    String label,
    VoidCallback? onTap,
    bool isWeb,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: isWeb ? 24 : 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.surfaceContainerHighest,
        foregroundColor: colorScheme.onSurface,
        padding: EdgeInsets.symmetric(
          horizontal: isWeb ? 32 : 16,
          vertical: isWeb ? 20 : 12,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        textStyle: TextStyle(
          fontSize: isWeb ? 16 : 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String text, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: colorScheme.onSurfaceVariant.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            text,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildAIBadge(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, color: widget.accentColor, size: 16),
          const SizedBox(width: 8),
          Text(
            'Synthesized by TioNova AI Engine',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
