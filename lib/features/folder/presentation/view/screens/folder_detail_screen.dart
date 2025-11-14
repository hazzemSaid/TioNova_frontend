// features/folder/presentation/view/screens/folder_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tionova/core/get_it/services_locator.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/folder/data/models/ChapterModel.dart';
import 'package:tionova/features/folder/presentation/bloc/chapter/chapter_cubit.dart';
import 'package:tionova/features/folder/presentation/view/screens/EditChapterDialog.dart';
import 'package:tionova/features/folder/presentation/view/widgets/DashedBorderPainter.dart';
import 'package:tionova/utils/no_glow_scroll_behavior.dart';
import 'package:tionova/utils/static.dart';

class FolderDetailScreen extends StatelessWidget {
  final String folderId;
  final String title;
  final String subtitle;
  final int chapters;
  final int passed;
  final int attempted;
  final Color color;

  const FolderDetailScreen({
    super.key,
    required this.folderId,
    required this.title,
    required this.subtitle,
    required this.chapters,
    required this.passed,
    required this.attempted,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 900;
    final isTablet = screenWidth > 600;
    final horizontalPadding = screenWidth * (isTablet ? 0.08 : 0.05);
    final colorScheme = Theme.of(context).colorScheme;

    return BlocProvider(
      create: (_) => getIt<ChapterCubit>(),
      child: Builder(
        builder: (context) {
          // Get auth state for token
          final authState = context.read<AuthCubit>().state;
          final token = authState is AuthSuccess ? authState.token : '';

          // Load chapters when widget builds
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (token.isNotEmpty) {
              context.read<ChapterCubit>().getChapters(
                folderId: folderId,
                token: token,
              );
            }
          });

          return Scaffold(
            backgroundColor: colorScheme.surface,
            body: isWeb
                ? _buildWebLayout(context, token, colorScheme)
                : _buildMobileLayout(
                    context,
                    token,
                    horizontalPadding,
                    colorScheme,
                  ),
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    String token,
    double horizontalPadding,
    ColorScheme colorScheme,
  ) {
    return ScrollConfiguration(
      behavior: NoGlowScrollBehavior(),
      child: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          // Header with back button, title, and share button
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: horizontalPadding,
                right: horizontalPadding,
                bottom: 24,
              ),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: colorScheme.outline),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: colorScheme.onSurface,
                        size: 16,
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
                          title,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Share button
                  GestureDetector(
                    onTap: () {
                      // Handle share action
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: colorScheme.outline),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.share,
                        color: colorScheme.onSurface,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Stats cards
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard('Chapters', chapters.toString()),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Passed', passed.toString())),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard('Attempted', attempted.toString()),
                  ),
                ],
              ),
            ),
          ),

          // Add Chapter button
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(horizontalPadding),
              child: GestureDetector(
                onTap: () async {
                  final chapterCubit = context.read<ChapterCubit>();
                  final result = await context.pushNamed(
                    'create-chapter',
                    pathParameters: {'folderId': folderId},
                    extra: {'folderTitle': title, 'chapterCubit': chapterCubit},
                  );
                  if (result == true && token.isNotEmpty) {
                    chapterCubit.getChapters(folderId: folderId, token: token);
                  }
                },
                child: CustomPaint(
                  size: Size(double.infinity, 44),
                  isComplex: true,
                  willChange: true,
                  painter: DashedBorderPainter(
                    color: color.withValues(alpha: 0.22),
                  ),
                  child: Container(
                    height: 44,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: colorScheme.outline),
                    ),
                    child: Center(
                      child: Text(
                        'Add Chapter',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Dynamic chapter list from cubit
          BlocBuilder<ChapterCubit, ChapterState>(
            builder: (context, state) {
              if (state is ChapterLoading) {
                // Show skeleton loading cards with skeletonizer
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, idx) => Skeletonizer(
                      enabled: true,
                      child: _buildChapterCard(
                        context,
                        ChapterModel(
                          id: 'loading',
                          title: 'Loading Chapter Title',
                          description:
                              'Loading chapter description text that will be replaced with actual content',
                          createdAt: DateTime.now().toIso8601String(),
                          quizStatus: 'Not Taken',
                        ),
                      ),
                    ),
                    childCount: 3, // Show 3 skeleton cards
                  ),
                );
              } else if (state is ChapterLoaded) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate((ctx, idx) {
                    final chapter = state.chapters[idx];
                    return _buildChapterCard(context, chapter);
                  }, childCount: state.chapters.length),
                );
              } else if (state is ChapterError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'Failed to load chapters: ${state.message}',
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),
                );
              } else {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No chapters found',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWebLayout(
    BuildContext context,
    String token,
    ColorScheme colorScheme,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = 1400.0;
    final horizontalPadding = (screenWidth - maxWidth) / 2;
    final effectivePadding = horizontalPadding > 0 ? horizontalPadding : 40.0;

    return ScrollConfiguration(
      behavior: NoGlowScrollBehavior(),
      child: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          // Web Header
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 32,
                left: effectivePadding,
                right: effectivePadding,
                bottom: 32,
              ),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorScheme.outline),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: colorScheme.onSurface,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Title and subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Share button
                  GestureDetector(
                    onTap: () {
                      // Handle share action
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorScheme.outline),
                      ),
                      child: Icon(
                        Icons.share,
                        color: colorScheme.onSurface,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Stats cards and Add Chapter button - Side by side on web
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: effectivePadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats cards column
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Chapters',
                            chapters.toString(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard('Passed', passed.toString()),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Attempted',
                            attempted.toString(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Add Chapter button
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () async {
                        final chapterCubit = context.read<ChapterCubit>();
                        final result = await context.pushNamed(
                          'create-chapter',
                          pathParameters: {'folderId': folderId},
                          extra: {
                            'folderTitle': title,
                            'chapterCubit': chapterCubit,
                          },
                        );
                        if (result == true && token.isNotEmpty) {
                          chapterCubit.getChapters(
                            folderId: folderId,
                            token: token,
                          );
                        }
                      },
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: color.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                color: color,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Add Chapter',
                                style: TextStyle(
                                  color: color,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),

          // Dynamic chapter list in grid for web
          BlocBuilder<ChapterCubit, ChapterState>(
            builder: (context, state) {
              if (state is ChapterLoading) {
                // Show skeleton loading cards in grid for web
                return SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: effectivePadding),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          childAspectRatio: 2.5,
                        ),
                    delegate: SliverChildBuilderDelegate(
                      (ctx, idx) => Skeletonizer(
                        enabled: true,
                        child: _buildWebChapterCard(
                          context,
                          ChapterModel(
                            id: 'loading',
                            title: 'Loading Chapter Title',
                            description:
                                'Loading chapter description text that will be replaced with actual content',
                            createdAt: DateTime.now().toIso8601String(),
                            quizStatus: 'Not Taken',
                          ),
                        ),
                      ),
                      childCount: 4, // Show 4 skeleton cards for web
                    ),
                  ),
                );
              } else if (state is ChapterLoaded) {
                return SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: effectivePadding),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          childAspectRatio: 2.5,
                        ),
                    delegate: SliverChildBuilderDelegate((ctx, idx) {
                      final chapter = state.chapters[idx];
                      return _buildWebChapterCard(context, chapter);
                    }, childCount: state.chapters.length),
                  ),
                );
              } else if (state is ChapterError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'Failed to load chapters: ${state.message}',
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),
                );
              } else {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No chapters found',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                );
              }
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Container(
          height: 80,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outline),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChapterCard(BuildContext context, ChapterModel chapter) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final horizontalPadding = screenWidth * (isTablet ? 0.08 : 0.05);
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        final chapterCubit = context.read<ChapterCubit>();
        final chapterId = chapter.id?.isNotEmpty == true ? chapter.id! : 'temp';
        context.pushNamed(
          'chapter-detail',
          pathParameters: {'chapterId': chapterId},
          extra: {
            'chapter': chapter,
            'folderColor': color,
            'chapterCubit': chapterCubit,
          },
        );
      },
      onLongPress: () {
        ShowChapterOptionsBottomSheet(chapter: chapter).show(context);
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(
          horizontalPadding,
          0,
          horizontalPadding,
          12,
        ),
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and status
            Row(
              children: [
                Expanded(
                  child: Text(
                    chapter.title ?? 'Untitled Chapter',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildStatusChip(
                  chapter.quizStatus ?? 'Not Taken',
                  colorScheme,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Description
            Text(
              chapter.description ?? 'No description available',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 12),
            // Info and action buttons
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Chapter • Created ${_formatDate(chapter.createdAt)}',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                chapter.summaryId != null
                    ? _buildActionButton('Summary', Icons.summarize)
                    : const SizedBox.shrink(),
                const SizedBox(width: 8),
                _buildActionButton('Quiz', Icons.quiz),
                const SizedBox(width: 8),
                _buildActionButton('Chat', Icons.chat_bubble_outline),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, ColorScheme colorScheme) {
    Color chipColor;
    switch (status) {
      case 'Passed':
        chipColor = colorScheme.tertiary;
        break;
      case 'Failed':
        chipColor = colorScheme.error;
        break;
      default:
        chipColor = colorScheme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: chipColor),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: chipColor,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: colorScheme.onSurface, size: 12),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return 'Unknown';
    }
  }

  Widget _buildWebChapterCard(BuildContext context, ChapterModel chapter) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        final chapterCubit = context.read<ChapterCubit>();
        final chapterId = chapter.id?.isNotEmpty == true ? chapter.id! : 'temp';
        context.pushNamed(
          'chapter-detail',
          pathParameters: {'chapterId': chapterId},
          extra: {
            'chapter': chapter,
            'folderColor': color,
            'chapterCubit': chapterCubit,
          },
        );
      },
      onLongPress: () {
        ShowChapterOptionsBottomSheet(chapter: chapter).show(context);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top section with title and status
            Row(
              children: [
                Expanded(
                  child: Text(
                    chapter.title ?? 'Untitled Chapter',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                _buildStatusChip(
                  chapter.quizStatus ?? 'Not Taken',
                  colorScheme,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Description
            Expanded(
              child: Text(
                chapter.description ?? 'No description available',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
            // Bottom section with date and action buttons
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Created ${_formatDate(chapter.createdAt)}',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                chapter.summaryId != null
                    ? _buildWebActionButton('Summary', Icons.summarize)
                    : const SizedBox.shrink(),
                const SizedBox(width: 8),
                _buildWebActionButton('Quiz', Icons.quiz),
                const SizedBox(width: 8),
                _buildWebActionButton('Chat', Icons.chat_bubble_outline),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebActionButton(String label, IconData icon) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: colorScheme.onSurface, size: 14),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ShowChapterOptionsBottomSheet {
  final ChapterModel chapter;

  ShowChapterOptionsBottomSheet({required this.chapter});

  void show(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              chapter.title ?? 'Untitled Chapter',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildActionButton(
                  chapter: chapter,
                  context: context,
                  color: colorScheme.primary,
                  icon: Icons.edit,
                  label: 'Edit',
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _showEditChapterDialog(chapter, context);
                  },
                ),
                buildActionButton(
                  chapter: chapter,
                  context: context,
                  color: colorScheme.error,
                  icon: Icons.delete,
                  label: 'Delete',
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _showDeleteChapterDialog(chapter, context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showEditChapterDialog(ChapterModel chapter, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: colorScheme.scrim.withValues(alpha: 153),
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<ChapterCubit>()),
          BlocProvider.value(value: context.read<AuthCubit>()),
        ],
        child: EditChapterDialog(
          titleController: TextEditingController(text: chapter.title),
          descriptionController: TextEditingController(
            text: chapter.description,
          ),
          chapter: chapter,
          defaultcolors: Static.defaultColors,
          icons: Static.defaultIcons,
        ),
      ),
    );
  }

  void _showDeleteChapterDialog(ChapterModel chapter, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Container(child: Text('Delete Chapter')),
    );
  }

  Widget buildActionButton({
    required ChapterModel chapter,
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
