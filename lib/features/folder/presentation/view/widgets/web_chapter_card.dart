import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/features/folder/data/models/ChapterModel.dart';
import 'package:tionova/features/folder/presentation/bloc/chapter/chapter_cubit.dart';
import 'package:tionova/features/folder/presentation/view/utils/folder_detail_view_helper.dart';
import 'package:tionova/features/folder/presentation/view/widgets/chapter_options_bottom_sheet.dart';

class WebChapterCard extends StatelessWidget {
  final ChapterModel chapter;
  final Color folderColor;
  final String folderId;
  final String ownerId;

  const WebChapterCard({
    super.key,
    required this.chapter,
    required this.folderColor,
    required this.folderId,
    required this.ownerId,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        final chapterCubit = context.read<ChapterCubit>();
        final chapterId = chapter.id.isNotEmpty ? chapter.id : 'temp';
        // Use go() on web to ensure URL updates in browser
        context.goNamed(
          'chapter-detail',
          pathParameters: {'chapterId': chapterId},
          extra: {
            'chapter': chapter,
            'folderColor': folderColor,
            'folderOwnerId': ownerId,
            'folderId': folderId, // Optional for quiz routes
          },
        );
      },
      onLongPress: () {
        ChapterOptionsBottomSheet(
          chapter: chapter,
          folderId: folderId,
          folderOwnerId: ownerId,
        ).show(context);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    chapter.title ?? 'Untitled Chapter',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                _buildStatusChip(
                  chapter.quizStatus ?? 'Not Taken',
                  colorScheme,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Text(
                chapter.description ?? 'No description available',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Created ${FolderDetailViewHelper.formatDate(chapter.createdAt)}',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                if (chapter.summaryId != null)
                  _buildWebActionButton(context, 'Summary', Icons.summarize),
                const SizedBox(width: 8),
                _buildWebActionButton(context, 'Quiz', Icons.quiz),
                const SizedBox(width: 8),
                _buildWebActionButton(
                  context,
                  'Chat',
                  Icons.chat_bubble_outline,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, ColorScheme colorScheme) {
    final color = FolderDetailViewHelper.getStatusColor(status, colorScheme);
    final icon = FolderDetailViewHelper.getStatusIcon(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebActionButton(
    BuildContext context,
    String label,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: colorScheme.onSurface, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
