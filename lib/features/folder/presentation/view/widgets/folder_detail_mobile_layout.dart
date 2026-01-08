import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/chapter/presentation/bloc/chapter/chapter_cubit.dart';
import 'package:tionova/features/folder/presentation/view/widgets/DashedBorderPainter.dart';
import 'package:tionova/features/folder/presentation/view/widgets/folder_chapter_card.dart';
import 'package:tionova/features/folder/presentation/view/widgets/folder_chapter_shimmer.dart';
import 'package:tionova/features/folder/presentation/view/widgets/folder_detail_header.dart';
import 'package:tionova/features/folder/presentation/view/widgets/folder_stat_card.dart';
import 'package:tionova/utils/no_glow_scroll_behavior.dart';

class FolderDetailMobileLayout extends StatelessWidget {
  final String folderId;
  final String title;
  final String subtitle;
  final int chaptersCount;
  final int passed;
  final int attempted;
  final Color color;
  final String ownerId;
  final double horizontalPadding;
  final String? currentUserIdParam;

  const FolderDetailMobileLayout({
    super.key,
    required this.folderId,
    required this.title,
    required this.subtitle,
    required this.chaptersCount,
    required this.passed,
    required this.attempted,
    required this.color,
    required this.ownerId,
    required this.horizontalPadding,
    this.currentUserIdParam,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ScrollConfiguration(
      behavior: NoGlowScrollBehavior(),
      child: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: FolderDetailHeader(
              title: title,
              subtitle: subtitle,
              horizontalPadding: horizontalPadding,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Row(
                children: [
                  Expanded(
                    child: FolderStatCard(
                      title: 'Chapters',
                      value: chaptersCount.toString(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FolderStatCard(
                      title: 'Passed',
                      value: passed.toString(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FolderStatCard(
                      title: 'Attempted',
                      value: attempted.toString(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildAddChapterButton(context, colorScheme),
          _buildChaptersList(colorScheme),
        ],
      ),
    );
  }

  Widget _buildAddChapterButton(BuildContext context, ColorScheme colorScheme) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        // Priority: AuthState user ID > Local storage > Parameter > Empty
        String? currentUserId;

        if (authState is AuthSuccess && authState.user.id.isNotEmpty) {
          // Primary source: Current auth state
          currentUserId = authState.user.id;
          debugPrint('✅ [Mobile] UserId from AuthState: $currentUserId');
        } else if (currentUserIdParam != null &&
            currentUserIdParam!.isNotEmpty) {
          // Fallback: Parameter passed from parent
          currentUserId = currentUserIdParam;
          debugPrint('⚠️ [Mobile] UserId from param: $currentUserId');
        }

        // Validate both IDs
        final isOwner =
            currentUserId != null &&
            currentUserId.isNotEmpty &&
            currentUserId.trim() == ownerId.trim();

        debugPrint(
          '📱 [Mobile] Current: "$currentUserId" | Owner: "$ownerId" | IsOwner: $isOwner',
        );

        if (!isOwner) {
          return SliverToBoxAdapter(child: SizedBox(height: horizontalPadding));
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
                  extra: {'folderTitle': title, 'chapterCubit': chapterCubit},
                );
                if (result == true) {
                  chapterCubit.getChapters(folderId: folderId);
                }
              },
              child: CustomPaint(
                size: const Size(double.infinity, 44),
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
    );
  }

  Widget _buildChaptersList(ColorScheme colorScheme) {
    return BlocBuilder<ChapterCubit, ChapterState>(
      builder: (context, state) {
        final chapters = state.chapters;
        final isLoading = state is ChapterLoading;

        if (isLoading && chapters == null) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, idx) => const FolderChapterShimmer(),
              childCount: 3,
            ),
          );
        } else if (chapters != null && chapters.isNotEmpty) {
          return SliverList(
            delegate: SliverChildBuilderDelegate((ctx, idx) {
              final chapter = chapters[idx];
              return FolderChapterCard(
                chapter: chapter,
                folderColor: color,
                folderOwnerId: ownerId,
              );
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
    );
  }
}
