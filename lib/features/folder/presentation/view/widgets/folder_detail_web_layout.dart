import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/folder/presentation/bloc/chapter/chapter_cubit.dart';
import 'package:tionova/features/folder/presentation/view/widgets/folder_chapter_shimmer.dart';
import 'package:tionova/features/folder/presentation/view/widgets/folder_detail_header.dart';
import 'package:tionova/features/folder/presentation/view/widgets/folder_stat_card.dart';
import 'package:tionova/features/folder/presentation/view/widgets/web_chapter_card.dart';
import 'package:tionova/utils/no_glow_scroll_behavior.dart';

class FolderDetailWebLayout extends StatelessWidget {
  final String folderId;
  final String title;
  final String subtitle;
  final int chaptersCount;
  final int passed;
  final int attempted;
  final Color color;
  final String ownerId;

  const FolderDetailWebLayout({
    super.key,
    required this.folderId,
    required this.title,
    required this.subtitle,
    required this.chaptersCount,
    required this.passed,
    required this.attempted,
    required this.color,
    required this.ownerId,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const maxWidth = 1400.0;
    final horizontalPadding = (screenWidth - maxWidth) / 2;
    final effectivePadding = horizontalPadding > 0 ? horizontalPadding : 40.0;
    final colorScheme = Theme.of(context).colorScheme;

    return ScrollConfiguration(
      behavior: NoGlowScrollBehavior(),
      child: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: FolderDetailWebHeader(
              title: title,
              subtitle: subtitle,
              effectivePadding: effectivePadding,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: effectivePadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Expanded(
                          child: FolderStatCard(
                            title: 'Chapters',
                            value: chaptersCount.toString(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FolderStatCard(
                            title: 'Passed',
                            value: passed.toString(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FolderStatCard(
                            title: 'Attempted',
                            value: attempted.toString(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  _buildAddChapterButton(context, colorScheme),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
          _buildChaptersGrid(effectivePadding, colorScheme),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildAddChapterButton(BuildContext context, ColorScheme colorScheme) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final currentUserId = authState is AuthSuccess
            ? authState.user.id
            : null;
        final isOwner = currentUserId != null && currentUserId == ownerId;

        if (!isOwner) {
          return const SizedBox.shrink();
        }

        return Expanded(
          flex: 1,
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
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.3), width: 2),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline, color: color, size: 20),
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
    );
  }

  Widget _buildChaptersGrid(double effectivePadding, ColorScheme colorScheme) {
    return BlocBuilder<ChapterCubit, ChapterState>(
      builder: (context, state) {
        final chapters = state.chapters;
        final isLoading = state is ChapterLoading;

        if (isLoading && chapters == null) {
          return SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: effectivePadding),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 2.5,
              ),
              delegate: SliverChildBuilderDelegate(
                (ctx, idx) => const FolderChapterWebShimmer(),
                childCount: 4,
              ),
            ),
          );
        } else if (chapters != null && chapters.isNotEmpty) {
          return SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: effectivePadding),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 2.5,
              ),
              delegate: SliverChildBuilderDelegate((ctx, idx) {
                final chapter = chapters[idx];
                return WebChapterCard(
                  chapter: chapter,
                  folderColor: color,
                  folderId: folderId,
                  ownerId: ownerId,
                );
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
    );
  }
}
