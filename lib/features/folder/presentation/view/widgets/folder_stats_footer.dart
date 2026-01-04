import 'package:flutter/material.dart';
import 'package:tionova/features/folder/data/models/foldermodel.dart';
import 'package:tionova/features/folder/presentation/view/widgets/study_stats.dart';

class FolderStatsFooter extends StatelessWidget {
  final List<Foldermodel> folders;
  final double verticalSpacing;
  final bool isTablet;

  const FolderStatsFooter({
    super.key,
    required this.folders,
    required this.verticalSpacing,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          SizedBox(height: verticalSpacing * 1.5),
          StudyStats(
            myFoldersCount: folders.length,
            totalChaptersCount: folders.fold(
              0,
              (sum, folder) => sum + (folder.chapterCount ?? 0),
            ),
          ),
          SizedBox(height: isTablet ? 24 : 16),
        ],
      ),
    );
  }
}
