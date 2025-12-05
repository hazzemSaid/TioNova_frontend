// features/folder/presentation/view/screens/folder_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tionova/core/get_it/services_locator.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/folder/data/models/ChapterModel.dart';
import 'package:tionova/features/folder/presentation/bloc/chapter/chapter_cubit.dart';
import 'package:tionova/features/folder/presentation/bloc/folder/folder_cubit.dart';
import 'package:tionova/features/folder/presentation/view/screens/EditChapterDialog.dart';
import 'package:tionova/features/folder/presentation/view/widgets/DashedBorderPainter.dart';
import 'package:tionova/features/folder/presentation/view/widgets/delete_chapter_confirmation_dialog.dart';
import 'package:tionova/utils/no_glow_scroll_behavior.dart';

class FolderDetailScreen extends StatelessWidget {
  final String folderId;
  final String title;
  final String subtitle;
  final int chapters;
  final int passed;
  final int attempted;
  final Color color;
  final String ownerId;

  const FolderDetailScreen({
    super.key,
    required this.folderId,
    required this.title,
    required this.subtitle,
    required this.chapters,
    required this.passed,
    required this.attempted,
    required this.color,
    required this.ownerId,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 900;
    final isTablet = screenWidth > 600;
    final horizontalPadding = screenWidth * (isTablet ? 0.08 : 0.05);
    final colorScheme = Theme.of(context).colorScheme;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<ChapterCubit>()..getChapters(folderId: folderId),
        ),
        BlocProvider(create: (_) => getIt<FolderCubit>()),
      ],
      child: Builder(
        builder: (context) {
          return BlocListener<ChapterCubit, ChapterState>(
            listener: (context, state) {
              if (state is DeleteChapterSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chapter deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is DeleteChapterError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Failed to delete chapter: ${state.message.errMessage}',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Scaffold(
              backgroundColor: colorScheme.surface,
              body: isWeb
                  ? _buildWebLayout(context, colorScheme)
                  : _buildMobileLayout(context, horizontalPadding, colorScheme),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
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

          // Add Chapter button - Only for owners
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              final currentUserId = authState is AuthSuccess
                  ? authState.user.id
                  : null;
              final isOwner = currentUserId != null && currentUserId == ownerId;

              if (!isOwner) {
                return SliverToBoxAdapter(child: SizedBox.shrink());
              }

              return SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(horizontalPadding),
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
                      if (result == true) {
                        chapterCubit.getChapters(folderId: folderId);
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
              );
            },
          ),

          // Dynamic chapter list from cubit
          BlocBuilder<ChapterCubit, ChapterState>(
            builder: (context, state) {
              // Extract chapters from any state that has them
              final chapters = state.chapters;
              final isLoading = state is ChapterLoading;

              // Show chapters if available, regardless of creation state
              if (isLoading && chapters == null) {
                // Show shimmer loading cards only if no chapters yet
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, idx) => _buildShimmerChapterCard(context),
                    childCount: 3, // Show 3 shimmer cards
                  ),
                );
              } else if (chapters != null && chapters.isNotEmpty) {
                // Show chapters even during creation states
                return SliverList(
                  delegate: SliverChildBuilderDelegate((ctx, idx) {
                    final chapter = chapters[idx];
                    return _buildChapterCard(context, chapter);
                  }, childCount: chapters.length),
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

  Widget _buildWebLayout(BuildContext context, ColorScheme colorScheme) {
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
                  // Add Chapter button - Only for owners
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, authState) {
                      final currentUserId = authState is AuthSuccess
                          ? authState.user.id
                          : null;
                      final isOwner =
                          currentUserId != null && currentUserId == ownerId;

                      if (!isOwner) {
                        return SizedBox.shrink();
                      }

                      return Expanded(
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
                            if (result == true) {
                              chapterCubit.getChapters(folderId: folderId);
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
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),

          // Dynamic chapter list in grid for web
          BlocBuilder<ChapterCubit, ChapterState>(
            builder: (context, state) {
              // Extract chapters from any state that has them
              final chapters = state.chapters;
              final isLoading = state is ChapterLoading;

              // Show chapters if available, regardless of creation state
              if (isLoading && chapters == null) {
                // Show shimmer loading cards in grid for web only if no chapters yet
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
                      (ctx, idx) => _buildWebShimmerChapterCard(context),
                      childCount: 4, // Show 4 shimmer cards for web
                    ),
                  ),
                );
              } else if (chapters != null && chapters.isNotEmpty) {
                // Show chapters even during creation states
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
                      final chapter = chapters[idx];
                      return _buildWebChapterCard(context, chapter);
                    }, childCount: chapters.length),
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

  Widget _buildShimmerChapterCard(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final horizontalPadding = screenWidth * (isTablet ? 0.08 : 0.05);
    final colorScheme = Theme.of(context).colorScheme;

    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
      highlightColor: colorScheme.surfaceContainerHighest.withOpacity(0.2),
      child: Container(
        margin: EdgeInsets.fromLTRB(
          horizontalPadding,
          0,
          horizontalPadding,
          isTablet ? 14 : 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 16 : 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: isTablet ? 44 : 40,
                    height: isTablet ? 44 : 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
                    ),
                  ),
                  SizedBox(width: isTablet ? 12 : 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Container(width: 100, height: 12, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: isTablet ? 12 : 10),
              Container(
                width: double.infinity,
                height: 14,
                color: Colors.white,
              ),
              SizedBox(height: isTablet ? 14 : 12),
              Row(
                children: [
                  Container(width: 60, height: 24, color: Colors.white),
                  const SizedBox(width: 8),
                  Container(width: 60, height: 24, color: Colors.white),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebShimmerChapterCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
      highlightColor: colorScheme.surfaceContainerHighest.withOpacity(0.2),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Expanded(child: Container(height: 20, color: Colors.white)),
                const SizedBox(width: 12),
                Container(width: 60, height: 20, color: Colors.white),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(width: 200, height: 14, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Container(height: 12, color: Colors.white)),
                const SizedBox(width: 8),
                Container(width: 60, height: 24, color: Colors.white),
                const SizedBox(width: 8),
                Container(width: 60, height: 24, color: Colors.white),
              ],
            ),
          ],
        ),
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
    final isLarge = screenWidth > 900;
    final horizontalPadding = screenWidth * (isTablet ? 0.08 : 0.05);
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        final chapterCubit = context.read<ChapterCubit>();
        final chapterId = chapter.id.isNotEmpty ? chapter.id : 'temp';
        context.pushNamed(
          'chapter-detail',
          pathParameters: {'chapterId': chapterId},
          extra: {
            'chapter': chapter,
            'folderColor': color,
            'chapterCubit': chapterCubit,
            'folderOwnerId': ownerId,
          },
        );
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        ShowChapterOptionsBottomSheet(
          chapter: chapter,
          folderId: folderId,
          folderOwnerId: ownerId,
        ).show(context);
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(
          horizontalPadding,
          0,
          horizontalPadding,
          isTablet ? 14 : 12,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.06),
              blurRadius: isTablet ? 12 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(isLarge ? 18 : (isTablet ? 16 : 14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon, title and status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chapter icon
                  Container(
                    width: isTablet ? 44 : 40,
                    height: isTablet ? 44 : 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color.withOpacity(0.2),
                          color.withOpacity(0.08),
                        ],
                      ),
                      border: Border.all(
                        color: color.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.article_outlined,
                      color: color,
                      size: isTablet ? 22 : 20,
                    ),
                  ),
                  SizedBox(width: isTablet ? 12 : 10),
                  // Title and metadata
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chapter.title ?? 'Untitled Chapter',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: isLarge ? 17 : (isTablet ? 16 : 15.5),
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_outlined,
                              size: isTablet ? 13 : 12,
                              color: colorScheme.onSurfaceVariant.withOpacity(
                                0.7,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(chapter.createdAt),
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant.withOpacity(
                                  0.8,
                                ),
                                fontSize: isTablet ? 12 : 11.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status chip
                  _buildStatusChip(
                    chapter.quizStatus ?? 'Not Taken',
                    colorScheme,
                  ),
                ],
              ),

              // Description
              if (chapter.description != null &&
                  chapter.description!.isNotEmpty) ...[
                SizedBox(height: isTablet ? 12 : 10),
                Text(
                  chapter.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.9),
                    fontSize: isTablet ? 13.5 : 13,
                    height: 1.4,
                  ),
                ),
              ],

              // Action buttons
              SizedBox(height: isTablet ? 14 : 12),
              Wrap(
                spacing: isTablet ? 10 : 8,
                runSpacing: 8,
                children: [
                  if (chapter.summaryId != null)
                    _buildActionButton('Summary', Icons.summarize_outlined),
                  _buildActionButton('Quiz', Icons.quiz_outlined),
                  _buildActionButton('Chat', Icons.chat_bubble_outline),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, ColorScheme colorScheme) {
    Color chipColor;
    IconData chipIcon;

    switch (status.toLowerCase()) {
      case 'passed':
        chipColor = Colors.green;
        chipIcon = Icons.check_circle_outline;
        break;
      case 'failed':
        chipColor = colorScheme.error;
        chipIcon = Icons.cancel_outlined;
        break;
      case 'in progress':
        chipColor = Colors.orange;
        chipIcon = Icons.pending_outlined;
        break;
      default:
        chipColor = colorScheme.onSurfaceVariant;
        chipIcon = Icons.circle_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: chipColor.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(chipIcon, size: 12, color: chipColor),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: chipColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon) {
    return Builder(
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isTablet = screenWidth > 600;
        final colorScheme = Theme.of(context).colorScheme;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 12 : 10,
            vertical: isTablet ? 8 : 7,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorScheme.outlineVariant.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: colorScheme.onSurface.withOpacity(0.8),
                size: isTablet ? 15 : 14,
              ),
              SizedBox(width: isTablet ? 6 : 5),
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.9),
                  fontSize: isTablet ? 12 : 11.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
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
        final chapterId = chapter.id.isNotEmpty ? chapter.id : 'temp';
        context.pushNamed(
          'chapter-detail',
          pathParameters: {'chapterId': chapterId},
          extra: {
            'chapter': chapter,
            'folderColor': color,
            'chapterCubit': chapterCubit,
            'folderOwnerId': ownerId,
          },
        );
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        ShowChapterOptionsBottomSheet(
          chapter: chapter,
          folderId: folderId,
          folderOwnerId: ownerId,
        ).show(context);
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
  final String folderId;
  final String folderOwnerId;

  ShowChapterOptionsBottomSheet({
    required this.chapter,
    required this.folderId,
    required this.folderOwnerId,
  });

  void show(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    // Get current user ID and check ownership
    final authState = context.read<AuthCubit>().state;
    final currentUserId = authState is AuthSuccess ? authState.user.id : null;
    final isOwner = currentUserId != null && currentUserId == folderOwnerId;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) => Container(
        padding: EdgeInsets.all(isTablet ? 28 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header with icon, title, and status
            Row(
              children: [
                // Document icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.article_outlined,
                    size: isTablet ? 28 : 24,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 16),

                // Title and status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chapter.title ?? 'Untitled Chapter',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Status badge
                      _buildStatusBadge(
                        chapter.quizStatus ?? 'Not Taken',
                        colorScheme,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: isTablet ? 32 : 28),

            // Action buttons - Only show for owners
            if (isOwner) ...[
              _buildActionListItem(
                context: context,
                icon: Icons.edit_outlined,
                label: 'Edit Chapter',
                colorScheme: colorScheme,
                isTablet: isTablet,
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _showEditChapterDialog(chapter, context);
                },
              ),

              SizedBox(height: isTablet ? 14 : 12),

              _buildActionListItem(
                context: context,
                icon: Icons.delete_outline,
                label: 'Delete Chapter',
                colorScheme: colorScheme,
                isTablet: isTablet,
                isDestructive: true,
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _showDeleteChapterDialog(chapter, context);
                },
              ),

              SizedBox(height: isTablet ? 24 : 20),
            ],

            // Show message for non-owners
            if (!isOwner) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: colorScheme.onPrimaryContainer,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You can only view this chapter. Only the folder owner can edit or delete.',
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isTablet ? 24 : 20),
            ],

            // Cancel button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(bottomSheetContext),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 14),
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: isTablet ? 16 : 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, ColorScheme colorScheme) {
    Color badgeColor;

    switch (status.toLowerCase()) {
      case 'passed':
        badgeColor = Colors.green;
        break;
      case 'failed':
        badgeColor = colorScheme.error;
        break;
      case 'in progress':
        badgeColor = Colors.orange;
        break;
      default:
        badgeColor = colorScheme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badgeColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 12, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: badgeColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionListItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required ColorScheme colorScheme,
    required bool isTablet,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? colorScheme.error : colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 20 : 16,
          vertical: isTablet ? 16 : 14,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: isTablet ? 24 : 22, color: color),
            SizedBox(width: isTablet ? 16 : 14),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: isTablet ? 16 : 15,
                fontWeight: FontWeight.w600,
              ),
            ),
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
          BlocProvider.value(value: context.read<FolderCubit>()),
        ],
        child: EditChapterDialog(chapter: chapter, currentFolderId: folderId),
      ),
    );
  }

  void _showDeleteChapterDialog(ChapterModel chapter, BuildContext context) {
    showDeleteChapterConfirmationDialog(
      context,
      chapter,
      context.read<ChapterCubit>(),
    );
  }
}
