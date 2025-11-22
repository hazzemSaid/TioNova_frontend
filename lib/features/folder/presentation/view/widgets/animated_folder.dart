/*import 'package:flutter/material.dart';
import 'package:tionova/features/folder/data/models/foldermodel.dart';
import 'package:tionova/features/folder/domain/repo/IFolderRepository.dart';
import 'package:tionova/features/folder/presentation/view/widgets/folder_card.dart';

class AnimatedFolder extends StatefulWidget {
  final Foldermodel folder;
  final Color folderColor;
  final VoidCallback onTapFolder;
  final VoidCallback onDeleteFolder;
  final VoidCallback onEditFolder;

  const AnimatedFolder({
    Key? key,
    required this.folder,
    required this.folderColor,
    required this.onTapFolder,
    required this.onDeleteFolder,
    required this.onEditFolder,
  }) : super(key: key);

  @override
  State<AnimatedFolder> createState() => _AnimatedFolderState();
}

class _AnimatedFolderState extends State<AnimatedFolder>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      value: 1.0, // Start fully visible
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Function to start the exit animation
  Future<void> runExitAnimation() async {
    await _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: FolderCard(
            title: widget.folder.title,
            description: widget.folder.description ?? 'No description',
            category: widget.folder.category ?? 'Uncategorized',
            chapters: widget.folder.chapterCount ?? 0,
            privacy: widget.folder.status == Status.private
                ? 'Private'
                : 'Public',
            lastAccessed: widget.folder.createdAt.toString().substring(0, 10),
            color: widget.folderColor,
            onTap: widget.onTapFolder,
          ),
        ),
      ),
    );
  }
}
*/
