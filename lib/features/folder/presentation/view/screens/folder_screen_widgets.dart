import 'package:flutter/material.dart';
import 'package:tionova/features/folder/data/models/FolderModel.dart';
import 'package:tionova/features/folder/domain/repo/IFolderRepository.dart';

import '../widgets/folder_card.dart';

class FolderGridItem extends StatelessWidget {
  final Foldermodel folder;
  final Color color;
  final IconData icon;
  final VoidCallback onLongPress;
  final VoidCallback onTap;

  const FolderGridItem({
    required this.folder,
    required this.color,
    required this.icon,
    required this.onLongPress,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0E0E10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1C1C1E), width: 1),
        ),
        child: FolderCard(
          title: folder.title,
          description: folder.description ?? 'No description',
          category: folder.category ?? 'Uncategorized',
          privacy: folder.status == Status.private ? 'Private' : 'Public',
          chapters: folder.chapterCount ?? 0,
          lastAccessed:
              '${DateTime.now().difference(folder.createdAt).inDays} days ago',
          color: color,
          icon: icon,
          onTap: onTap,
        ),
      ),
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
