import 'package:flutter/material.dart';
import 'package:tionova/features/folder/data/models/FolderModel.dart';
import 'package:tionova/features/folder/domain/repo/IFolderRepository.dart';
import 'package:tionova/features/folder/presentation/view/widgets/folder_card.dart';
import 'package:tionova/utils/static.dart';

class FolderGridItem extends StatelessWidget {
  final Foldermodel folder;
  final Color color;
  final IconData icon;
  final VoidCallback onLongPress;
  final VoidCallback onTap;
  static const defaultColors = Static.defaultColors;
  static const defaultIcons = Static.defaultIcons;
  const FolderGridItem({
    required this.folder,
    required this.color,
    required this.icon,
    required this.onLongPress,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FolderCard(
      onTap: onTap,
      onLongPress: onLongPress,
      title: folder.title,
      description: folder.description ?? 'No description',
      category: folder.category ?? 'Uncategorized',
      privacy: folder.status == Status.private
          ? 'Private'
          : (folder.status == Status.share ? 'Shared' : 'Public'),
      chapters: folder.chapterCount ?? 0,
      lastAccessed:
          '${DateTime.now().difference(folder.createdAt).inDays} days ago',
      color: color,
      sharedWith: folder.sharedWith,
      icon: folder.icon != null ? defaultIcons[int.parse(folder.icon!)] : null,
    );
  }
}

class LongPressHint extends StatelessWidget {
  const LongPressHint({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.blue.withOpacity(0.7),
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            'Long press on any folder to edit or delete',
            style: TextStyle(color: Colors.blue.withOpacity(0.8), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
