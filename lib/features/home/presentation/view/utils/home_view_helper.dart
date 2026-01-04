import 'package:flutter/material.dart';
import 'package:tionova/core/utils/date_formatter.dart';
import 'package:tionova/features/home/data/models/analysisModel.dart';

class HomeViewHelper {
  static List<Map<String, dynamic>> buildStatsList(Analysismodel analysisData) {
    return [
      {
        'value': '${analysisData.profile?.streak ?? 0}',
        'label': 'Day Streak',
        'icon': Icons.local_fire_department,
      },
      {
        'value': '${analysisData.profile?.totalQuizzesTaken ?? 0}',
        'label': 'Quizzes',
        'icon': Icons.quiz,
      },
      {
        'value': analysisData.profile?.averageQuizScore != null
            ? '${analysisData.profile!.averageQuizScore.toStringAsFixed(1)}%'
            : '0%',
        'label': 'Avg Score',
        'icon': Icons.insights,
      },
      {
        'value': analysisData.lastRank != null
            ? '#${analysisData.lastRank}'
            : '-',
        'label': 'Rank',
        'icon': Icons.emoji_events,
      },
    ];
  }

  static List<Map<String, dynamic>> buildChaptersList(
    Analysismodel analysisData,
  ) {
    return (analysisData.recentChapters ?? [])
        .map(
          (chapter) => {
            'id': chapter.id,
            'title': chapter.title,
            'subject': chapter.category ?? 'General',
            'progress': 0.0, // TODO: Calculate based on actual progress
            'pages': '${chapter.description?.length ?? 0} content',
            'timeAgo': formatTimeAgo(chapter.createdAt),
            'chapterModel': chapter,
          },
        )
        .toList();
  }

  static List<Map<String, dynamic>> buildFoldersList(
    Analysismodel analysisData,
    ColorScheme colorScheme,
  ) {
    return (analysisData.recentFolders ?? []).asMap().entries.map((entry) {
      final index = entry.key;
      final folder = entry.value;
      // Rotate through theme colors
      final colors = [
        colorScheme.primary,
        colorScheme.tertiary,
        colorScheme.secondary,
        colorScheme.primaryContainer,
      ];
      return {
        'id': folder.id,
        'title': folder.title,
        'chapters': folder.chapterCount ?? 0,
        'timeAgo': formatTimeAgo(folder.createdAt),
        'color': colors[index % colors.length],
        'folderModel': folder,
      };
    }).toList();
  }

  static Map<String, dynamic>? buildLastSummaryData(
    Analysismodel analysisData,
  ) {
    if (analysisData.lastSummary == null) return null;

    final summaryData = analysisData.lastSummary!;
    // The summary field contains an array of summaries, get the first one
    final firstSummary = summaryData.summary;

    return {
      'title': firstSummary.chapterTitle,
      'chapterId': summaryData.chapterId,
      'timeAgo': formatTimeAgo(summaryData.createdAt),
      'keyPoints': firstSummary.keyPoints.length,
      'readTime': 8, // TODO: Calculate read time
      'badge': 'AI Generated',
      'summaryModel': firstSummary, // Pass the full model for navigation
    };
  }

  static List<Map<String, dynamic>> buildMindMapsList(
    Analysismodel analysisData,
  ) {
    return (analysisData.lastMindmaps ?? [])
        .map(
          (mindmap) => {
            'title': mindmap.title ?? 'Mind Map',
            'subject': 'Chapter', // TODO: Get chapter name
            'chapterId': mindmap.chapterId,
            'nodes': mindmap.nodes?.length ?? 0,
            'timeAgo': formatTimeAgo(mindmap.createdAt),
            'mindmapModel': mindmap, // Pass the full model for navigation
          },
        )
        .toList();
  }
}
