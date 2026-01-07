import 'package:flutter/foundation.dart';
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
    const maxWidth = 1600.0;
    final horizontalPadding = (screenWidth - maxWidth) / 2;
    final effectivePadding = horizontalPadding > 0 ? horizontalPadding : 24.0;
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
              child: Column(
                children: [
                  Row(
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
                      const SizedBox(width: 16),
                      Expanded(
                        child: FolderStatCard(
                          title: 'Attempted',
                          value: attempted.toString(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildAddChapterButton(context, colorScheme),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          _buildChaptersGrid(effectivePadding, colorScheme),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildAddChapterButton(BuildContext context, ColorScheme colorScheme) {
    if (!kIsWeb) {
      debugPrint('Web Debug: kIsWeb=false, skipping web add chapter button');
      return const SizedBox.shrink();
    }

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        debugPrint('Web Debug: AuthState type: ${authState.runtimeType}');

        final currentUserId = authState is AuthSuccess
            ? authState.user.id
            : null;
        final isCurrentUserIdValid =
            currentUserId != null && currentUserId.isNotEmpty;
        final isOwnerIdValid = ownerId.isNotEmpty;
        final isOwner =
            isCurrentUserIdValid && isOwnerIdValid && currentUserId == ownerId;

        debugPrint('Web Debug: currentUserId="$currentUserId"');
        debugPrint('Web Debug: ownerId="$ownerId"');
        debugPrint('Web Debug: isCurrentUserIdValid=$isCurrentUserIdValid');
        debugPrint('Web Debug: isOwnerIdValid=$isOwnerIdValid');
        debugPrint('Web Debug: isOwner=$isOwner');

        if (!isOwner) {
          debugPrint('Web Debug: User is not owner, hiding add chapter button');
          return const SizedBox.shrink();
        }

        debugPrint('Web Debug: User is owner, showing add chapter button');

        return SizedBox(
          width: double.infinity,
          child: InkWell(
            onTap: () async {
              print('Debug: Add chapter button tapped');
              final chapterCubit = context.read<ChapterCubit>();
              try {
                final result = await context.pushNamed(
                  'create-chapter',
                  pathParameters: {'folderId': folderId},
                  extra: {'folderTitle': title, 'chapterCubit': chapterCubit},
                );
                print('Debug: Create chapter result=$result');

                if (result == true) {
                  print(
                    'Debug: Chapter created successfully, refreshing chapters list',
                  );
                  // Force refresh the chapters list
                  chapterCubit.getChapters(folderId: folderId);
                } else {
                  print('Debug: Chapter creation cancelled or failed');
                }
              } catch (e) {
                print('Debug: Error creating chapter: $e');
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color.withOpacity(0.4),
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline, color: color, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Add New Chapter',
                      style: TextStyle(
                        color: color,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
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
        final screenWidth = MediaQuery.of(context).size.width;

        // Responsive column count based on screen width
        int crossAxisCount;
        double childAspectRatio;
        print('Web Debug: screenWidth=$screenWidth');
        if (screenWidth >= 1400) {
          crossAxisCount = 2;
          childAspectRatio = 2.7;
        } else if (screenWidth >= 1200) {
          crossAxisCount = 2;
          childAspectRatio = 2;
        } else if (screenWidth >= 1100) {
          crossAxisCount = 2;
          childAspectRatio = 1.6;
        } else {
          crossAxisCount = 2;
          childAspectRatio = 2.2;
        }

        if (isLoading && chapters == null) {
          return SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: effectivePadding),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                childAspectRatio: childAspectRatio,
              ),
              delegate: SliverChildBuilderDelegate(
                (ctx, idx) => const FolderChapterWebShimmer(),
                childCount: 6,
              ),
            ),
          );
        } else if (chapters != null && chapters.isNotEmpty) {
          return SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: effectivePadding),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 90,
                crossAxisSpacing: 90,
                childAspectRatio: childAspectRatio,
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
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: effectivePadding),
                child: Text(
                  'Failed to load chapters: ${state.message}',
                  style: TextStyle(color: colorScheme.error, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        } else {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: effectivePadding),
                child: Text(
                  'No chapters found',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
