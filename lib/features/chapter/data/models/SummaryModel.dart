import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

// Helper function to sanitize UTF-8 strings
String _sanitizeUtf8(String input) {
  try {
    final bytes = utf8.encode(input);
    return utf8.decode(bytes, allowMalformed: true);
  } catch (e) {
    return input.replaceAll(RegExp(r'[^\x00-\x7F]+'), '');
  }
}

// Main Response Model for Summary API
class SummaryResponse extends Equatable {
  final bool success;
  final String message;
  final List<SummaryModel> summaries; // Changed to list to match API
  final bool cached;

  const SummaryResponse({
    required this.success,
    required this.message,
    required this.summaries,
    this.cached = false,
  });

  // Convenience getter for the first summary (most common use case)
  SummaryModel get summary => summaries.isNotEmpty
      ? summaries.first
      : const SummaryModel(
          chapterTitle: '',
          chapterOverview: ChapterOverview(title: '', summary: ''),
          keyTakeaways: [],
          keyPoints: [],
          definitions: [],
          flashcards: [],
        );

  factory SummaryResponse.fromJson(Map<String, dynamic> json) {
    List<SummaryModel> parsedSummaries = [];

    final summaryField = json['summary'];
    if (summaryField != null) {
      // Check if this is a database document wrapper (has _id, chapterId, etc.)
      // and the actual summary is nested inside
      if (summaryField is Map<String, dynamic> &&
          summaryField.containsKey('summary')) {
        // This is the database document wrapper - extract the nested summary
        final nestedSummary = summaryField['summary'];

        if (nestedSummary is List) {
          // Nested summary is an array
          parsedSummaries = nestedSummary
              .where((item) => item != null && item is Map<String, dynamic>)
              .map(
                (item) => SummaryModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        } else if (nestedSummary is Map<String, dynamic>) {
          // Nested summary is a single object
          parsedSummaries = [SummaryModel.fromJson(nestedSummary)];
        }
      } else if (summaryField is List) {
        // Direct array of summaries (no wrapper)
        parsedSummaries = summaryField
            .where((item) => item != null && item is Map<String, dynamic>)
            .map((item) => SummaryModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (summaryField is Map<String, dynamic>) {
        // Direct single summary object (check if it has summary structure)
        // If it has 'chapter_title' key, it's the actual summary content
        if (summaryField.containsKey('chapter_title')) {
          parsedSummaries = [SummaryModel.fromJson(summaryField)];
        } else {
          debugPrint(
            '⚠️ [SummaryResponse.fromJson] Unrecognized map structure in summary field',
          );
        }
      } else {
        debugPrint(
          '⚠️ [SummaryResponse.fromJson] Unexpected type for summary field: ${summaryField.runtimeType}',
        );
      }
    }

    return SummaryResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      summaries: parsedSummaries,
      cached: json['cached'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'summary': summaries.map((s) => s.toJson()).toList(),
      'cached': cached,
    };
  }

  @override
  List<Object> get props => [success, message, summaries, cached];
}

// Summary Model Data (Database model)
class SummaryModelData extends Equatable {
  final String chapterId;
  final List<SummaryModel> summaries; // Changed from single summary to list
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  const SummaryModelData({
    required this.chapterId,
    required this.summaries,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  // Convenience getter for the first summary (most common use case)
  SummaryModel get summary => summaries.isNotEmpty
      ? summaries.first
      : const SummaryModel(
          chapterTitle: '',
          chapterOverview: ChapterOverview(title: '', summary: ''),
          keyTakeaways: [],
          keyPoints: [],
          definitions: [],
          flashcards: [],
        );

  factory SummaryModelData.fromJson(Map<String, dynamic> json) {
    List<SummaryModel> parsedSummaries = [];

    final summaryField = json['summary'];
    if (summaryField != null) {
      // Check if this is a nested structure (summary inside summary)
      // This happens when the backend returns the full database document
      if (summaryField is Map<String, dynamic>) {
        // Check if it has 'chapter_title' - meaning it's the actual summary content
        if (summaryField.containsKey('chapter_title')) {
          // Direct summary content
          parsedSummaries = [SummaryModel.fromJson(summaryField)];
        } else {
          // This might be a wrapper, content could be in a nested 'summary' field
          // But for SummaryModelData from DB, the structure is typically flat
          debugPrint(
            '⚠️ [SummaryModelData.fromJson] Map without chapter_title - unusual structure',
          );
        }
      } else if (summaryField is List) {
        // Handle array of summaries
        parsedSummaries = summaryField
            .where((item) => item != null && item is Map<String, dynamic>)
            .map((item) => SummaryModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        debugPrint(
          '⚠️ [SummaryModelData.fromJson] Unexpected type for summary field: ${summaryField.runtimeType}',
        );
      }
    }

    return SummaryModelData(
      chapterId: json['chapterId'] as String? ?? '',
      summaries: parsedSummaries,
      id: json['_id'] as String? ?? '',
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      version: json['__v'] as int? ?? 0,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'chapterId': chapterId,
      'summary': summaries.map((s) => s.toJson()).toList(),
      '_id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
    };
  }

  @override
  List<Object> get props => [
    chapterId,
    summaries,
    id,
    createdAt,
    updatedAt,
    version,
  ];
}

// Main Summary Model
class SummaryModel extends Equatable {
  final String chapterTitle;
  final ChapterOverview chapterOverview;
  final List<String> keyTakeaways;
  final List<KeyPoint> keyPoints;
  final List<Definition> definitions;
  final List<Flashcard> flashcards;

  const SummaryModel({
    required this.chapterTitle,
    required this.chapterOverview,
    required this.keyTakeaways,
    required this.keyPoints,
    required this.definitions,
    required this.flashcards,
  });

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      chapterTitle: _sanitizeUtf8(json['chapter_title'] as String? ?? ''),
      chapterOverview: json['chapter_overview'] != null
          ? ChapterOverview.fromJson(
              json['chapter_overview'] as Map<String, dynamic>,
            )
          : const ChapterOverview(title: '', summary: ''),
      keyTakeaways: _parseStringList(json['key_takeaways']),
      keyPoints: _parseKeyPoints(json['key_points']),
      definitions: _parseDefinitions(json['definitions']),
      flashcards: _parseFlashcards(json['flashcards']),
    );
  }

  static List<String> _parseStringList(dynamic data) {
    if (data == null || data is! List) return [];
    return data
        .where((item) => item != null)
        .map((item) => _sanitizeUtf8(item.toString()))
        .toList();
  }

  static List<KeyPoint> _parseKeyPoints(dynamic data) {
    if (data == null || data is! List) return [];
    return data
        .where((item) => item != null && item is Map<String, dynamic>)
        .map((item) => KeyPoint.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static List<Definition> _parseDefinitions(dynamic data) {
    if (data == null || data is! List) return [];
    return data
        .where((item) => item != null && item is Map<String, dynamic>)
        .map((item) => Definition.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static List<Flashcard> _parseFlashcards(dynamic data) {
    if (data == null || data is! List) return [];
    return data
        .where((item) => item != null && item is Map<String, dynamic>)
        .map((item) => Flashcard.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'chapter_title': chapterTitle,
      'chapter_overview': chapterOverview.toJson(),
      'key_takeaways': keyTakeaways,
      'key_points': keyPoints.map((kp) => kp.toJson()).toList(),
      'definitions': definitions.map((d) => d.toJson()).toList(),
      'flashcards': flashcards.map((fc) => fc.toJson()).toList(),
    };
  }

  @override
  List<Object> get props => [
    chapterTitle,
    chapterOverview,
    keyTakeaways,
    keyPoints,
    definitions,
    flashcards,
  ];
}

// Chapter Overview Model
class ChapterOverview extends Equatable {
  final String title;
  final String summary;

  const ChapterOverview({required this.title, required this.summary});

  factory ChapterOverview.fromJson(Map<String, dynamic> json) {
    return ChapterOverview(
      title: _sanitizeUtf8(json['title'] as String? ?? ''),
      summary: _sanitizeUtf8(json['summary'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'summary': summary};
  }

  @override
  List<Object> get props => [title, summary];
}

// Key Point Model
class KeyPoint extends Equatable {
  final String title;
  final String type;
  final String content;

  const KeyPoint({
    required this.title,
    required this.type,
    required this.content,
  });

  factory KeyPoint.fromJson(Map<String, dynamic> json) {
    return KeyPoint(
      title: _sanitizeUtf8(json['title'] as String? ?? ''),
      type: _sanitizeUtf8(json['type'] as String? ?? 'concept'),
      content: _sanitizeUtf8(json['content'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'type': type, 'content': content};
  }

  @override
  List<Object> get props => [title, type, content];
}

// Definition Model
class Definition extends Equatable {
  final String term;
  final String definition;

  const Definition({required this.term, required this.definition});

  factory Definition.fromJson(Map<String, dynamic> json) {
    return Definition(
      term: _sanitizeUtf8(json['term'] as String? ?? ''),
      definition: _sanitizeUtf8(json['definition'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {'term': term, 'definition': definition};
  }

  @override
  List<Object> get props => [term, definition];
}

// Flashcard Model
class Flashcard extends Equatable {
  final String question;
  final String answer;

  const Flashcard({required this.question, required this.answer});

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      question: _sanitizeUtf8(json['question'] as String? ?? ''),
      answer: _sanitizeUtf8(json['answer'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {'question': question, 'answer': answer};
  }

  @override
  List<Object> get props => [question, answer];
}
