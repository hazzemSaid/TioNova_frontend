import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/features/folder/data/models/ChapterModel.dart';

class ChapterDetailSidebar extends StatelessWidget {
  final ChapterModel chapter;
  final double width;
  final VoidCallback onDownloadPDF;

  const ChapterDetailSidebar({
    super.key,
    required this.chapter,
    required this.width,
    required this.onDownloadPDF,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline, width: 1),
      ),
      child: Column(
        children: [
          // Document Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: colorScheme.outline, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Document',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'PDF',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // PDF Preview Area
          GestureDetector(
            onTap: () {
              final folderId = chapter.folderId;
              final hasFolder = folderId != null && folderId.isNotEmpty;
              final path = hasFolder
                  ? '/folders/$folderId/chapters/${chapter.id}/pdf'
                  : '/chapters/${chapter.id}/pdf';
              context.push(
                path,
                extra: {'chapterTitle': chapter.title ?? 'Chapter'},
              );
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                height: 340,
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outline, width: 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 80,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'PDF Preview',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Click to view full document',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Actions Section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: [
                const SizedBox(height: 8),
                _buildButton(
                  onPressed: onDownloadPDF,
                  icon: Icons.download_rounded,
                  label: 'Download PDF',
                  colorScheme: colorScheme,
                  isPrimary: true,
                ),
                const SizedBox(height: 12),
                _buildButton(
                  onPressed: () {}, // Share functionality
                  icon: Icons.share_rounded,
                  label: 'Share Chapter',
                  colorScheme: colorScheme,
                  isPrimary: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required ColorScheme colorScheme,
    required bool isPrimary,
  }) {
    final style = isPrimary
        ? ElevatedButton.styleFrom(
            backgroundColor: colorScheme.surfaceVariant,
            foregroundColor: colorScheme.onSurface,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: colorScheme.outline, width: 1),
            ),
          )
        : OutlinedButton.styleFrom(
            foregroundColor: colorScheme.onSurface,
            side: BorderSide(color: colorScheme.outline, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          );

    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );

    return SizedBox(
      width: double.infinity,
      height: 44,
      child: isPrimary
          ? ElevatedButton(onPressed: onPressed, style: style, child: child)
          : OutlinedButton(onPressed: onPressed, style: style, child: child),
    );
  }
}
