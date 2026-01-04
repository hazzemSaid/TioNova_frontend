import 'package:flutter/material.dart';

class LiveQuestionHelper {
  /// Normalize timeRemaining values coming from the server.
  static int normalizeServerTimeRemaining(dynamic value, int questionDuration) {
    if (value == null) return -1;

    int raw;
    if (value is int) {
      raw = value;
    } else if (value is double) {
      raw = value.toInt();
    } else if (value is String) {
      raw = int.tryParse(value) ?? -1;
    } else {
      return -1;
    }

    if (raw <= 0) return -1;

    // Heuristic:
    // - If raw >= 1000 and <= questionDuration*1000 => it's likely milliseconds
    // - If raw >= questionDuration*1000 => milliseconds
    // - Otherwise treat as seconds

    if (raw >= 1000 && raw <= questionDuration * 1000) {
      final sec = ((raw + 999) ~/ 1000); // ceil
      return sec.clamp(0, questionDuration);
    }

    if (raw >= questionDuration * 1000) {
      final sec = ((raw + 999) ~/ 1000);
      return sec.clamp(0, questionDuration);
    }

    // raw is likely seconds; clamp to duration to avoid huge UI values
    if (raw > questionDuration) {
      debugPrint(
        'LiveQuestionScreen - server timeRemaining ($raw) > questionDuration; clamping to $questionDuration',
      );
      return questionDuration;
    }

    return raw.clamp(0, questionDuration);
  }

  /// Get the current question duration in seconds.
  static int getQuestionDurationSeconds(Map<String, dynamic>? question) {
    const int defaultDuration = 30;
    if (question == null) return defaultDuration;

    // Prefer explicit seconds fields
    try {
      if (question.containsKey('durationSeconds')) {
        final v = question['durationSeconds'];
        if (v is int && v > 0) return v;
        if (v is String) return int.tryParse(v) ?? defaultDuration;
      }

      if (question.containsKey('duration')) {
        final v = question['duration'];
        if (v is int && v > 0) return v;
        if (v is String) return int.tryParse(v) ?? defaultDuration;
      }

      // If duration is provided in milliseconds
      if (question.containsKey('durationMs')) {
        final v = question['durationMs'];
        if (v is int) return ((v + 999) ~/ 1000).clamp(1, 600).toInt();
        if (v is String) {
          final parsed = int.tryParse(v);
          if (parsed != null) {
            return ((parsed + 999) ~/ 1000).clamp(1, 600).toInt();
          }
        }
      }
    } catch (e) {
      debugPrint('LiveQuestionHelper - error parsing question duration: $e');
    }

    return defaultDuration;
  }
}
