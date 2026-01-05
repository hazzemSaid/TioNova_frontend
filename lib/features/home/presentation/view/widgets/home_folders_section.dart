import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/features/home/presentation/view/widgets/SectionHeader.dart';
import 'package:tionova/features/home/presentation/view/widgets/enhanced_folder_card.dart';

class HomeFoldersSection extends StatelessWidget {
  final List<Map<String, dynamic>> folders;
  final double horizontalPadding;
  final double verticalSpacing;
  final double screenWidth;
  final double screenHeight;
  final bool isTablet;

  const HomeFoldersSection({
    super.key,
    required this.folders,
    required this.horizontalPadding,
    required this.verticalSpacing,
    required this.screenWidth,
    required this.screenHeight,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    if (folders.isEmpty)
      return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(height: verticalSpacing * 2),
              SectionHeader(
                title: "Recent Folders",
                actionText: "View All",
                actionIcon: Icons.arrow_forward_ios,
              ),
              SizedBox(height: verticalSpacing),
            ]),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isTablet ? 3 : 2,
              crossAxisSpacing: screenWidth * (isTablet ? 0.03 : 0.04),
              mainAxisSpacing: screenHeight * 0.02,
              childAspectRatio: isTablet ? 1.2 : 1.0,
              mainAxisExtent: isTablet ? 180 : 160,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final folder = folders[index];
              return EnhancedFolderCard(
                title: folder['title'] as String,
                chapters: folder['chapters'] as int,
                timeAgo: folder['timeAgo'] as String,
                color: folder['color'] as Color,
                onTap: () {
                  final folderId = folder['id'] as String;
                  context.push(
                    '/folders/$folderId',
                    extra: {
                      'title': folder['title'],
                      'subtitle': folder['subject'] ?? '',
                      'chapters': folder['chapters'],
                      'passed': 0,
                      'attempted': 0,
                      'color': folder['color'],
                      'ownerId': folder['ownerId'] ?? '',
                    },
                  );
                },
              );
            }, childCount: folders.length),
          ),
        ),
      ],
    );
  }
}
