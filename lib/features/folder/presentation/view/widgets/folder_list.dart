import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/features/folder/data/models/foldermodel.dart';
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
    final filteredFolders = folders.where((folder) {
      if (selectedCategory == 'All') return true;
      return folder.category == selectedCategory;
    }).toList();

    final screenWidth = MediaQuery.of(context).size.width;

    // Better breakpoints for different device sizes
    final isLargeScreen = screenWidth > 900;
    final isTablet = screenWidth > 600;
    final isSmallTablet = screenWidth > 600 && screenWidth < 750;
    final isSmallPhone = screenWidth < 360;

    // Dynamic cross axis count based on screen width
    int crossAxisCount;
    double horizontalPadding;
    double crossAxisSpacing;
    double mainAxisSpacing;
    double childAspectRatio;

    if (isLargeScreen || isTablet) {
      // Tablets (2 columns)
      crossAxisCount = 2;
      horizontalPadding = screenWidth * 0.06;
      crossAxisSpacing = 16;
      mainAxisSpacing = 16;
      childAspectRatio = 2;
    } else if (isSmallPhone) {
      // Small phones (1 column)
      crossAxisCount = 1;
      horizontalPadding = screenWidth * 0.04;
      crossAxisSpacing = 0;
      mainAxisSpacing = 12;
      childAspectRatio = 2.4;
    } else {
      // Regular phones (1 column)
      crossAxisCount = 1;
      horizontalPadding = screenWidth * 0.05;
      crossAxisSpacing = 0;
      mainAxisSpacing = 14;
      childAspectRatio = 2.5;
    }

    if (filteredFolders.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(
            'No folders found',
            style: TextStyle(color: Color(0xFF8E8E93), fontSize: 16),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isTablet ? 15 : 12,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          childAspectRatio: childAspectRatio,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final folder = filteredFolders[index];
          final color = getColorFromHex(folder.color);
          final icon = getIconFromIndex(folder.icon);

          return FolderGridItem(
            folder: folder,
            color: color,
            icon: icon,
            onLongPress: () => onFolderLongPress(context, folder, color),
            onTap: () => context.push(
              '/folder/${folder.id}',
              extra: {
                'title': folder.title,
                'subtitle': folder.description ?? 'No description',
                'chapters': folder.chapterCount ?? 0,
                'passed': folder.passedCount ?? 0,
                'attempted': folder.attemptedCount ?? 0,
                'color': color,
                'ownerId': folder.ownerId,
              },
            ),
          );
        }, childCount: filteredFolders.length),
      ),
    );
  }
}
