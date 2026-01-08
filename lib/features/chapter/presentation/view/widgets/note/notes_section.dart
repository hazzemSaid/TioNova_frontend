import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/features/chapter/presentation/bloc/chapter/chapter_cubit.dart';

class NotesSection extends StatefulWidget {
  final String chapterId;
  final String chapterTitle;
  final String folderId;
  final Color? accentColor;
  final String? folderOwnerId;

  const NotesSection({
    super.key,
    required this.chapterId,
    required this.chapterTitle,
    required this.folderId,
    this.accentColor,
    this.folderOwnerId,
  });

  @override
  State<NotesSection> createState() => _NotesSectionState();
}

class _NotesSectionState extends State<NotesSection> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) {
        if (mounted) {
          setState(() => _isHovered = true);
        }
      },
      onExit: (_) {
        if (mounted) {
          setState(() => _isHovered = false);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered
                ? colorScheme.primary.withOpacity(0.5)
                : colorScheme.outline,
            width: 1.5,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.15),
                    blurRadius: 16,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        colors: [colorScheme.primary, colorScheme.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(
                      Icons.description_outlined,
                      color: colorScheme.onPrimary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notes',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Add text, voice, or image notes',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              BlocBuilder<ChapterCubit, ChapterState>(
                builder: (context, state) {
                  // Show loading indicator when adding a note
                  final isLoading = state is AddNoteLoading;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () {
                              final chapterCubit = context.read<ChapterCubit>();
                              final chapterId = widget.chapterId.isNotEmpty
                                  ? widget.chapterId
                                  : 'temp';
                              final hasFolder = widget.folderId.isNotEmpty;
                              if (hasFolder) {
                                context.pushNamed(
                                  'folder-chapter-notes',
                                  pathParameters: {
                                    'folderId': widget.folderId,
                                    'chapterId': chapterId,
                                  },
                                  extra: {
                                    'chapterTitle': widget.chapterTitle,
                                    'accentColor':
                                        widget.accentColor ??
                                        colorScheme.primary,
                                    'chapterCubit': chapterCubit,
                                    'folderOwnerId': widget.folderOwnerId,
                                  },
                                );
                              } else {
                                context.pushNamed(
                                  'chapter-notes-quick',
                                  pathParameters: {'chapterId': chapterId},
                                  extra: {
                                    'chapterTitle': widget.chapterTitle,
                                    'accentColor':
                                        widget.accentColor ??
                                        colorScheme.primary,
                                    'chapterCubit': chapterCubit,
                                    'folderOwnerId': widget.folderOwnerId,
                                  },
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        backgroundColor: colorScheme.surfaceVariant,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                          side: BorderSide(
                            color: colorScheme.outline,
                            width: 1,
                          ),
                        ),
                        disabledBackgroundColor: colorScheme.surfaceVariant
                            .withOpacity(0.5),
                      ),
                      icon: isLoading
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  colorScheme.onSurface.withOpacity(0.5),
                                ),
                              ),
                            )
                          : Icon(
                              Icons.description_outlined,
                              color: colorScheme.onSurface,
                              size: 22,
                            ),
                      label: Text(
                        isLoading ? 'Processing...' : 'Open',
                        style: TextStyle(
                          color: isLoading
                              ? colorScheme.onSurface.withOpacity(0.5)
                              : colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
