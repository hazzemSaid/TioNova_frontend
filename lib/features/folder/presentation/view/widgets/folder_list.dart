import 'package:flutter/material.dart';
import 'package:tionova/features/folder/data/models/FolderModel.dart';
import 'package:tionova/features/folder/presentation/bloc/folder/folder_cubit.dart';
import 'package:tionova/features/folder/presentation/view/screens/folder_detail_screen.dart';
import 'package:tionova/features/folder/presentation/view/screens/folder_screen_widgets.dart';
import 'package:tionova/utils/no_glow_scroll_behavior.dart';

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

    final isTablet = MediaQuery.of(context).size.width > 600;
    final horizontalPadding = MediaQuery.of(context).size.width * (isTablet ? 0.08 : 0.05);
    final crossAxisCount = isTablet ? 2 : 1;

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
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: isTablet ? 16 : 12),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: isTablet ? 16 : 0,
          mainAxisSpacing: 16,
          childAspectRatio: isTablet ? 2.5 : 2.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final folder = filteredFolders[index];
            final color = getColorFromHex(folder.color);
            final icon = getIconFromIndex(folder.icon);
            return FolderGridItem(
              folder: folder,
              color: color,
              icon: icon,
              onLongPress: () => onFolderLongPress(context, folder, color),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => FolderDetailScreen(
                  folderId: folder.id,
                  title: folder.title,
                  subtitle: folder.description ?? 'No description',
                  chapters: folder.chapterCount ?? 0,
                  passed: 0,
                  attempted: 0,
                  color: color,
                ),
              )),
            );
          },
          childCount: filteredFolders.length,
        ),
      ),
    );
  }
}