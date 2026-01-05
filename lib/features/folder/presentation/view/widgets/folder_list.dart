import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/features/folder/data/models/foldermodel.dart';
import 'package:tionova/features/folder/domain/repo/IFolderRepository.dart';
import 'package:tionova/features/folder/presentation/bloc/folder/folder_cubit.dart';
import 'package:tionova/features/folder/presentation/view/screens/folder_screen_widgets.dart';

class FolderList extends StatelessWidget {
  final FolderState state;
  final String selectedCategory;
  final IconData Function(String?) getIconFromIndex;
  final Color Function(String?) getColorFromHex;
  final void Function(BuildContext, Foldermodel, Color) onFolderLongPress;

  const FolderList({
    super.key,
    required this.state,
    required this.selectedCategory,
    required this.getIconFromIndex,
    required this.getColorFromHex,
    required this.onFolderLongPress,
  });

  List<Foldermodel> _getFoldersFromState() {
    if (state is FolderLoaded) {
      return (state as FolderLoaded).folders;
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final folders = _getFoldersFromState();

    final screenWidth = MediaQuery.of(context).size.width;

    // Better breakpoints for different device sizes
    final isLargeScreen = screenWidth > 900;
    final isTablet = screenWidth > 600;
    final isSmallPhone = screenWidth < 360;

    // Dynamic cross axis count based on screen width
    int crossAxisCount;
    double horizontalPadding;
    double crossAxisSpacing;
    double mainAxisSpacing;
    double baseChildAspectRatio;
    double sharedChildAspectRatio;

    if (isLargeScreen || isTablet) {
      // Tablets (2 columns)
      crossAxisCount = 2;
      horizontalPadding = screenWidth * 0.06;
      crossAxisSpacing = 16;
      mainAxisSpacing = 16;
      // Dynamic aspect ratio: scales between 2.0 and 2.4 based on screen width
      final normalizedWidth =
          ((screenWidth.clamp(600.0, 1200.0) - 600.0) / (1200.0 - 600.0));
      baseChildAspectRatio = 1.6 + (normalizedWidth * 0.4);
      sharedChildAspectRatio =
          1.3 + (normalizedWidth * .7); // More height for shared folders
    } else if (isSmallPhone) {
      // Small phones (1 column)
      crossAxisCount = 1;
      horizontalPadding = screenWidth * 0.04;
      crossAxisSpacing = 0;
      mainAxisSpacing = 12;
      // Dynamic aspect ratio: scales between 1.8 and 2.2 based on screen width
      final normalizedWidth =
          ((screenWidth.clamp(320.0, 360.0) - 320.0) / (360.0 - 320.0));
      baseChildAspectRatio = 1.8 + (normalizedWidth * 0.4);
      sharedChildAspectRatio =
          2.0 +
          (normalizedWidth * .1); // Mor; // More height for shared folders
    } else {
      // Regular phones (1 column)
      crossAxisCount = 1;
      horizontalPadding = screenWidth * 0.05;
      crossAxisSpacing = 0;
      mainAxisSpacing = 14;
      // Dynamic aspect ratio: scales between 2.0 and 2.5 based on screen width
      final normalizedWidth =
          ((screenWidth.clamp(360.0, 600.0) - 360.0) / (600.0 - 360.0));
      baseChildAspectRatio = 2.0 + (normalizedWidth * 0.5);
      sharedChildAspectRatio =
          2 + (normalizedWidth * .7); // More height for shared folders
    }

    // Calculate card width
    final availableWidth = screenWidth - (horizontalPadding * 2);
    final cardWidth =
        (availableWidth - (crossAxisSpacing * (crossAxisCount - 1))) /
        crossAxisCount;

    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isTablet ? 15 : 12,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          // Create rows for grid layout
          final rowIndex = index ~/ crossAxisCount;
          final colIndex = index % crossAxisCount;
          final isLastRow = (rowIndex + 1) * crossAxisCount >= folders.length;

          // Get folders for this row
          final rowStart = rowIndex * crossAxisCount;
          final rowEnd = (rowStart + crossAxisCount < folders.length)
              ? rowStart + crossAxisCount
              : folders.length;
          final rowFolders = folders.sublist(rowStart, rowEnd);

          // Only build the first item of each row
          if (colIndex == 0) {
            return Padding(
              padding: EdgeInsets.only(bottom: isLastRow ? 0 : mainAxisSpacing),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: rowFolders.asMap().entries.map((entry) {
                  final folder = entry.value;
                  final color = getColorFromHex(folder.color);
                  final icon = getIconFromIndex(folder.icon);

                  // Check if THIS specific folder is shared
                  final isShared =
                      folder.status == Status.share &&
                      folder.sharedWith != null &&
                      folder.sharedWith!.isNotEmpty;

                  // Use different aspect ratio based on whether this folder is shared
                  final aspectRatio = isShared
                      ? sharedChildAspectRatio
                      : baseChildAspectRatio;
                  final cardHeight = cardWidth / aspectRatio;

                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: entry.key < rowFolders.length - 1
                            ? crossAxisSpacing
                            : 0,
                      ),
                      child: SizedBox(
                        height: cardHeight,
                        child: FolderGridItem(
                          folder: folder,
                          color: color,
                          icon: icon,
                          onLongPress: () =>
                              onFolderLongPress(context, folder, color),
                          onTap: () => context.push(
                            '/folders/${folder.id}',
                            extra: {
                              'title': folder.title,
                              'subtitle':
                                  folder.description ?? 'No description',
                              'chapters': folder.chapterCount ?? 0,
                              'passed': folder.passedCount ?? 0,
                              'attempted': folder.attemptedCount ?? 0,
                              'color': color,
                              'ownerId': folder.ownerId,
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }
          return const SizedBox.shrink();
        }, childCount: (folders.length / crossAxisCount).ceil() * crossAxisCount),
      ),
    );
  }
}
