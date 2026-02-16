import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChapterDetailQuizSelector extends StatefulWidget {
  final String? chapterId;
  final String? chapterTitle;
  final String folderId;
  final VoidCallback onBack;

  const ChapterDetailQuizSelector({
    super.key,
    this.chapterId,
    this.chapterTitle,
    required this.folderId,
    required this.onBack,
  });

  @override
  State<ChapterDetailQuizSelector> createState() => _ChapterDetailQuizSelectorState();
}

class _ChapterDetailQuizSelectorState extends State<ChapterDetailQuizSelector> {
  bool _isHoveredNew = false;
  bool _isHoveredPractice = false;
  bool _isHoveredHistory = false;

  String _getQuizRoute(String subPath) {
    final hasFolder = widget.folderId.isNotEmpty;
    if (hasFolder) {
      return '/folders/${widget.folderId}/chapters/${widget.chapterId}$subPath';
    }
    return '/chapters/${widget.chapterId}$subPath';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back_rounded, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surfaceVariant.withOpacity(0.5),
                  padding: const EdgeInsets.all(8),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Test Your Knowledge',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildOption(
            context,
            colorScheme,
            'New Quiz',
            'Generate a new timed quiz based on this chapter',
            Icons.quiz_rounded,
            _isHoveredNew,
            (hover) => setState(() => _isHoveredNew = hover),
            () => context.push(
              _getQuizRoute('/quiz'),
              extra: {'folderId': widget.folderId},
            ),
          ),
          const SizedBox(height: 12),
          _buildOption(
            context,
            colorScheme,
            'Practice Mode',
            'Learn at your own pace with detailed explanations',
            Icons.model_training_rounded,
            _isHoveredPractice,
            (hover) => setState(() => _isHoveredPractice = hover),
            () => context.push(
              _getQuizRoute('/practice'),
              extra: {'chapterTitle': widget.chapterTitle},
            ),
          ),
          const SizedBox(height: 12),
          _buildOption(
            context,
            colorScheme,
            'View History',
            'Track your progress and review past performance',
            Icons.history_rounded,
            _isHoveredHistory,
            (hover) => setState(() => _isHoveredHistory = hover),
            () => context.push(
              _getQuizRoute('/quiz/history'),
              extra: {
                'quizTitle': widget.chapterTitle,
                'folderId': widget.folderId,
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context,
    ColorScheme colorScheme,
    String title,
    String subtitle,
    IconData icon,
    bool isHovered,
    Function(bool) onHover,
    VoidCallback onTap,
  ) {
    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isHovered 
              ? colorScheme.primaryContainer.withOpacity(0.4)
              : colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHovered ? colorScheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isHovered ? colorScheme.primary : colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isHovered ? colorScheme.onPrimary : colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isHovered ? colorScheme.primary : colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
