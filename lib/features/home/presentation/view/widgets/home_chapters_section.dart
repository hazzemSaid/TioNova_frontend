import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/core/utils/date_formatter.dart';
import 'package:tionova/features/folder/data/models/ChapterModel.dart';
import 'package:tionova/features/home/presentation/view/widgets/SectionHeader.dart';
import 'package:tionova/features/home/presentation/view/widgets/enhanced_chapter_card.dart';

class HomeChaptersSection extends StatelessWidget {
  final List<ChapterModel> chapters;
  final double horizontalPadding;
  final double verticalSpacing;
  final double screenHeight;
  final ColorScheme colorScheme;

  const HomeChaptersSection({
    super.key,
    required this.chapters,
    required this.horizontalPadding,
    required this.verticalSpacing,
    required this.screenHeight,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    if (chapters.isEmpty)
      return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              SectionHeader(
                title: "Recent Chapters",
                actionText: "View All",
                actionIcon: Icons.arrow_forward_ios,
              ),
              SizedBox(height: verticalSpacing),
            ]),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final chapterModel = chapters[index];
              return Padding(
                padding: EdgeInsets.only(bottom: screenHeight * 0.015),
                child: EnhancedChapterCard(
                  timeAgo: formatTimeAgo(chapterModel.createdAt),
                  onTap: () {
                    context.push(
                      '/chapter/${chapterModel.id}',
                      extra: {
                        'chapter': chapterModel,
                        'folderColor': colorScheme.primary,
                      },
                    );
                  },
                  title: '${chapterModel.title}',
                ),
              );
            }, childCount: chapters.length),
          ),
        ),
      ],
    );
  }
}
