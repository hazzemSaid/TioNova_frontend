import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tionova/features/folder/data/models/ChapterModel.dart';
import 'package:tionova/features/folder/presentation/bloc/chapter/chapter_cubit.dart';
import 'package:tionova/features/folder/presentation/view/screens/folder_detail_screen.dart';
import 'package:tionova/features/folder/presentation/view/widgets/chapter_status_chip.dart';

/// Web Chapter Card Widget for larger screens
class WebChapterCard extends StatelessWidget {
  final ChapterModel chapter;
  final Color folderColor;

  const WebChapterCard({
    super.key,
    required this.chapter,
    required this.folderColor,
  });

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return 'Unknown';
    }
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        final chapterCubit = context.read<ChapterCubit>();
        final chapterId = chapter.id?.isNotEmpty == true ? chapter.id! : 'temp';
        context.pushNamed(
          'chapter-detail',
          pathParameters: {'chapterId': chapterId},
          extra: {
            'chapter': chapter,
            'folderColor': folderColor,
            'chapterCubit': chapterCubit,
          },
        );
      },
      onLongPress: () {
        ShowChapterOptionsBottomSheet(
          chapter: chapter,
          folderId: chapter.folderId ?? '',
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
            // Top section with title and status
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
                ChapterStatusChip(status: chapter.quizStatus ?? 'Not Taken'),
              ],
            ),
            const SizedBox(height: 12),
            // Description
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
            // Bottom section with date and action buttons
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Created ${_formatDate(chapter.createdAt)}',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                if (chapter.summaryId != null)
                  _buildWebActionButton(context, 'Summary', Icons.summarize),
                if (chapter.summaryId != null) const SizedBox(width: 8),
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
}
