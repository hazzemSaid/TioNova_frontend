import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/chapter/data/models/ChapterModel.dart';
import 'package:tionova/features/chapter/presentation/bloc/chapter/chapter_cubit.dart';
import 'package:tionova/features/folder/presentation/bloc/folder/folder_cubit.dart';
import 'package:tionova/features/chapter/presentation/view/screens/EditChapterDialog.dart';
import 'package:tionova/features/chapter/presentation/view/widgets/delete_chapter_confirmation_dialog.dart';

class ChapterOptionsBottomSheet {
  final ChapterModel chapter;
  final String folderId;
  final String folderOwnerId;

  ChapterOptionsBottomSheet({
    required this.chapter,
    required this.folderId,
    required this.folderOwnerId,
  });

  void show(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    // Get current user ID and check ownership
    final authState = context.read<AuthCubit>().state;
    final currentUserId = authState is AuthSuccess ? authState.user.id : null;
    final isOwner = currentUserId != null && currentUserId == folderOwnerId;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (bottomSheetContext) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              isTablet ? 28 : 24,
              isTablet ? 28 : 24,
              isTablet ? 28 : 24,
              MediaQuery.of(bottomSheetContext).viewInsets.bottom +
                  MediaQuery.of(bottomSheetContext).padding.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.article_outlined,
                        size: isTablet ? 28 : 24,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chapter.title ?? 'Untitled Chapter',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: isTablet ? 18 : 16,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          _buildStatusBadge(
                            chapter.quizStatus ?? 'Not Taken',
                            colorScheme,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 32 : 28),
                if (isOwner) ...[
                  _buildActionListItem(
                    context: context,
                    icon: Icons.edit_outlined,
                    label: 'Edit Chapter',
                    colorScheme: colorScheme,
                    isTablet: isTablet,
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      _showEditChapterDialog(chapter, context);
                    },
                  ),
                  SizedBox(height: isTablet ? 14 : 12),
                  _buildActionListItem(
                    context: context,
                    icon: Icons.delete_outline,
                    label: 'Delete Chapter',
                    colorScheme: colorScheme,
                    isTablet: isTablet,
                    isDestructive: true,
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      _showDeleteChapterDialog(chapter, context);
                    },
                  ),
                  SizedBox(height: isTablet ? 24 : 20),
                ],
                if (!isOwner) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: colorScheme.onPrimaryContainer,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'You can only view this chapter. Only the folder owner can edit or delete.',
                            style: TextStyle(
                              color: colorScheme.onPrimaryContainer,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isTablet ? 24 : 20),
                ],
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(bottomSheetContext),
                    style: TextButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: isTablet ? 16 : 14),
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: isTablet ? 16 : 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, ColorScheme colorScheme) {
    Color badgeColor;

    switch (status.toLowerCase()) {
      case 'passed':
        badgeColor = Colors.green;
        break;
      case 'failed':
        badgeColor = colorScheme.error;
        break;
      case 'in progress':
        badgeColor = Colors.orange;
        break;
      default:
        badgeColor = colorScheme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badgeColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 12, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: badgeColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionListItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required ColorScheme colorScheme,
    required bool isTablet,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? colorScheme.error : colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 20 : 16,
          vertical: isTablet ? 16 : 14,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: isTablet ? 24 : 22, color: color),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: isTablet ? 16 : 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditChapterDialog(ChapterModel chapter, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: colorScheme.scrim.withValues(alpha: 153),
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<ChapterCubit>()),
          BlocProvider.value(value: context.read<FolderCubit>()),
        ],
        child: EditChapterDialog(chapter: chapter, currentFolderId: folderId),
      ),
    );
  }

  void _showDeleteChapterDialog(ChapterModel chapter, BuildContext context) {
    showDeleteChapterConfirmationDialog(
      context,
      chapter,
      context.read<ChapterCubit>(),
    );
  }
}

class ShowChapterOptionsBottomSheet extends ChapterOptionsBottomSheet {
  ShowChapterOptionsBottomSheet({
    required super.chapter,
    required super.folderId,
    required super.folderOwnerId,
  });
}
