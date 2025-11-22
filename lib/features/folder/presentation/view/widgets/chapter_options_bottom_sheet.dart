import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/folder/data/models/ChapterModel.dart';
import 'package:tionova/features/folder/presentation/bloc/chapter/chapter_cubit.dart';
import 'package:tionova/features/folder/presentation/view/screens/EditChapterDialog.dart';
import 'package:tionova/utils/static.dart';

/// Bottom sheet for chapter options (Edit, Delete, etc.)
class ChapterOptionsBottomSheet {
  final ChapterModel chapter;

  ChapterOptionsBottomSheet({required this.chapter});

  /// Show the bottom sheet with chapter options
  void show(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle indicator
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Chapter title
            Text(
              chapter.title ?? 'Untitled Chapter',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  context: context,
                  color: colorScheme.primary,
                  icon: Icons.edit,
                  label: 'Edit',
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _showEditChapterDialog(chapter, context);
                  },
                ),
                _buildActionButton(
                  context: context,
                  color: colorScheme.error,
                  icon: Icons.delete,
                  label: 'Delete',
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _showDeleteChapterDialog(chapter, context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Show edit chapter dialog
  void _showEditChapterDialog(ChapterModel chapter, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: colorScheme.scrim.withValues(alpha: 153),
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<ChapterCubit>()),
          BlocProvider.value(value: context.read<AuthCubit>()),
        ],
        child: EditChapterDialog(
          titleController: TextEditingController(text: chapter.title),
          descriptionController: TextEditingController(
            text: chapter.description,
          ),
          chapter: chapter,
          defaultcolors: Static.defaultColors,
          icons: Static.defaultIcons,
        ),
      ),
    );
  }

  /// Show delete chapter confirmation dialog
  void _showDeleteChapterDialog(ChapterModel chapter, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(
          'Delete Chapter',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        content: Text(
          'Are you sure you want to delete "${chapter.title ?? 'this chapter'}"? This action cannot be undone.',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: TextStyle(color: colorScheme.primary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Delete the chapter
              if (chapter.id != null) {
                // context.read<ChapterCubit>().deleteChapter(
                //   chapterId: chapter.id!,
                // );
              }
            },
            child: Text('Delete', style: TextStyle(color: colorScheme.error)),
          ),
        ],
      ),
    );
  }

  /// Build action button for bottom sheet
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

/// Legacy class name for backward compatibility
@Deprecated('Use ChapterOptionsBottomSheet instead')
class ShowChapterOptionsBottomSheet extends ChapterOptionsBottomSheet {
  ShowChapterOptionsBottomSheet({required super.chapter});
}
