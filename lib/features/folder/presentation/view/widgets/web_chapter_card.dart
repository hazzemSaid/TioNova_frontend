import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/features/chapter/data/models/ChapterModel.dart';
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;

        // Responsive sizing based on available width
        final isCompact = cardWidth < 350;
        final padding = isCompact ? 16.0 : 24.0;
        final titleSize = isCompact ? 16.0 : 20.0;
        final descriptionSize = isCompact ? 13.0 : 15.0;
        final statusPaddingH = isCompact ? 8.0 : 12.0;
        final statusPaddingV = isCompact ? 4.0 : 6.0;
        final buttonPaddingH = isCompact ? 8.0 : 12.0;
        final buttonPaddingV = isCompact ? 6.0 : 9.0;
        final iconSize = isCompact ? 12.0 : 16.0;

        return GestureDetector(
          onTap: () {
            final chapterId = chapter.id.isNotEmpty ? chapter.id : 'temp';
            final effectiveFolderId = folderId.isNotEmpty
                ? folderId
                : 'unknown';
            print(
              'Debug: folderId=$folderId, chapterId=$chapterId, effectiveFolderId=$effectiveFolderId',
            );
            // Use go() to ensure URL updates properly in web browser
            context.goNamed(
              'folder-chapter-detail',
              pathParameters: {
                'folderId': effectiveFolderId,
                'chapterId': chapterId,
              },
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
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        chapter.title ?? 'Untitled Chapter',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: titleSize,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildStatusChip(
                      chapter.quizStatus ?? 'Not Taken',
                      colorScheme,
                      statusPaddingH,
                      statusPaddingV,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Text(
                    chapter.description ?? 'No description available',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: descriptionSize,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            FolderDetailViewHelper.formatDate(
                              chapter.createdAt,
                            ),
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (chapter.summaryId != null)
                      _buildWebActionButton(
                        context,
                        'Summary',
                        Icons.summarize,
                        buttonPaddingH,
                        buttonPaddingV,
                        iconSize,
                      ),
                    _buildWebActionButton(
                      context,
                      'Quiz',
                      Icons.quiz,
                      buttonPaddingH,
                      buttonPaddingV,
                      iconSize,
                    ),
                    _buildWebActionButton(
                      context,
                      'Chat',
                      Icons.chat_bubble_outline,
                      buttonPaddingH,
                      buttonPaddingV,
                      iconSize,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(
    String status,
    ColorScheme colorScheme,
    double paddingH,
    double paddingV,
  ) {
    final color = FolderDetailViewHelper.getStatusColor(status, colorScheme);
    final icon = FolderDetailViewHelper.getStatusIcon(status);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
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
    double paddingH,
    double paddingV,
    double iconSize,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () {
        // Handle action button tap
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: colorScheme.onSurface, size: iconSize),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
