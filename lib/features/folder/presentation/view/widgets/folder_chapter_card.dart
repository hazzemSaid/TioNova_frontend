import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tionova/features/folder/data/models/ChapterModel.dart';
import 'package:tionova/features/folder/presentation/bloc/chapter/chapter_cubit.dart';
import 'package:tionova/features/folder/presentation/view/screens/folder_detail_screen.dart';
import 'package:tionova/features/folder/presentation/view/widgets/chapter_action_button.dart';
import 'package:tionova/features/folder/presentation/view/widgets/chapter_status_chip.dart';

/// Mobile/Tablet Chapter Card Widget
class FolderChapterCard extends StatelessWidget {
  final ChapterModel chapter;
  final Color folderColor;
  final String? folderOwnerId;

  const FolderChapterCard({
    super.key,
    required this.chapter,
    required this.folderColor,
    this.folderOwnerId,
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isLarge = screenWidth > 900;
    final horizontalPadding = screenWidth * (isTablet ? 0.08 : 0.05);
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        final chapterCubit = context.read<ChapterCubit>();
        final chapterId = chapter.id.isNotEmpty ? chapter.id : 'temp';
        context.pushNamed(
          'chapter-detail',
          pathParameters: {'chapterId': chapterId},
          extra: {
            'chapter': chapter,
            'folderColor': folderColor,
            'chapterCubit': chapterCubit,
            'folderOwnerId': folderOwnerId,
          },
        );
      },
      onLongPress: () {
        ShowChapterOptionsBottomSheet(
          chapter: chapter,
          folderId: chapter.folderId ?? '',
          folderOwnerId: folderOwnerId ?? '',
        ).show(context);
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(
          horizontalPadding,
          0,
          horizontalPadding,
          isTablet ? 14 : 12,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.06),
              blurRadius: isTablet ? 12 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(isLarge ? 18 : (isTablet ? 16 : 14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon, title and status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chapter icon
                  Container(
                    width: isTablet ? 44 : 40,
                    height: isTablet ? 44 : 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          folderColor.withOpacity(0.2),
                          folderColor.withOpacity(0.08),
                        ],
                      ),
                      border: Border.all(
                        color: folderColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.article_outlined,
                      color: folderColor,
                      size: isTablet ? 22 : 20,
                    ),
                  ),
                  SizedBox(width: isTablet ? 12 : 10),
                  // Title and metadata
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chapter.title ?? 'Untitled Chapter',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: isLarge ? 17 : (isTablet ? 16 : 15.5),
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_outlined,
                              size: isTablet ? 13 : 12,
                              color: colorScheme.onSurfaceVariant.withOpacity(
                                0.7,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(chapter.createdAt),
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant.withOpacity(
                                  0.8,
                                ),
                                fontSize: isTablet ? 12 : 11.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status chip
                  ChapterStatusChip(status: chapter.quizStatus ?? 'Not Taken'),
                ],
              ),

              // Description
              if (chapter.description != null &&
                  chapter.description!.isNotEmpty) ...[
                SizedBox(height: isTablet ? 12 : 10),
                Text(
                  chapter.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.9),
                    fontSize: isTablet ? 13.5 : 13,
                    height: 1.4,
                  ),
                ),
              ],

              // Action buttons
              SizedBox(height: isTablet ? 14 : 12),
              Wrap(
                spacing: isTablet ? 10 : 8,
                runSpacing: 8,
                children: [
                  if (chapter.summaryId != null)
                    ChapterActionButton(
                      label: 'Summary',
                      icon: Icons.summarize_outlined,
                      isTablet: isTablet,
                    ),
                  ChapterActionButton(
                    label: 'Quiz',
                    icon: Icons.quiz_outlined,
                    isTablet: isTablet,
                  ),
                  ChapterActionButton(
                    label: 'Chat',
                    icon: Icons.chat_bubble_outline,
                    isTablet: isTablet,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
