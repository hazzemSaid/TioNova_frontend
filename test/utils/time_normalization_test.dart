import 'package:flutter_test/flutter_test.dart';

/// Tests for time normalization and duration parsing utilities
/// These functions are currently private in LiveQuestionScreen but are
/// critical for correct timer behavior.

void main() {
  group('Time Normalization (simulated _normalizeServerTimeRemaining)', () {
    // Simulate the function since it's private
    int normalizeServerTimeRemaining(dynamic value, int questionDuration) {
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

      // If raw >= 1000 and <= questionDuration*1000 => milliseconds
      if (raw >= 1000 && raw <= questionDuration * 1000) {
        final sec = ((raw + 999) ~/ 1000); // ceil
        return sec.clamp(0, questionDuration);
      }

      // If raw >= questionDuration*1000 => milliseconds
      if (raw >= questionDuration * 1000) {
        final sec = ((raw + 999) ~/ 1000);
        return sec.clamp(0, questionDuration);
      }

      // raw is likely seconds
      if (raw > questionDuration) {
        return questionDuration;
      }

      return raw.clamp(0, questionDuration);
    }

    test('returns -1 for null input', () {
      expect(normalizeServerTimeRemaining(null, 30), -1);
    });

    test('returns -1 for negative values', () {
      expect(normalizeServerTimeRemaining(-5, 30), -1);
      expect(normalizeServerTimeRemaining(-1000, 30), -1);
    });

    test('returns -1 for zero', () {
      expect(normalizeServerTimeRemaining(0, 30), -1);
    });

    test('handles string input', () {
      expect(normalizeServerTimeRemaining('15', 30), 15);
      expect(normalizeServerTimeRemaining('5000', 30), 5); // milliseconds
      expect(normalizeServerTimeRemaining('invalid', 30), -1);
    });

    test('handles double input', () {
      expect(normalizeServerTimeRemaining(15.7, 30), 15);
      expect(normalizeServerTimeRemaining(5000.5, 30), 5);
    });

    test('treats values >= 1000 as milliseconds', () {
      // 5000ms = 5s
      expect(normalizeServerTimeRemaining(5000, 30), 5);
      // 4622ms = ~5s (ceil)
      expect(normalizeServerTimeRemaining(4622, 30), 5);
      // 1000ms = 1s
      expect(normalizeServerTimeRemaining(1000, 30), 1);
      // 30000ms = 30s
      expect(normalizeServerTimeRemaining(30000, 30), 30);
    });

    test('treats values < 1000 as seconds', () {
      expect(normalizeServerTimeRemaining(5, 30), 5);
      expect(normalizeServerTimeRemaining(15, 30), 15);
      expect(normalizeServerTimeRemaining(30, 30), 30);
    });

    test('clamps seconds to questionDuration', () {
      expect(normalizeServerTimeRemaining(50, 30), 30);
      expect(normalizeServerTimeRemaining(100, 30), 30);
    });

    test('clamps milliseconds to questionDuration', () {
      // 50000ms = 50s, should clamp to 30s
      expect(normalizeServerTimeRemaining(50000, 30), 30);
      // 100000ms = 100s, should clamp to 30s
      expect(normalizeServerTimeRemaining(100000, 30), 30);
    });

    test('handles edge case at exactly questionDuration', () {
      expect(normalizeServerTimeRemaining(30, 30), 30);
      expect(normalizeServerTimeRemaining(30000, 30), 30);
    });

    test('handles values just above 1000 threshold', () {
      expect(normalizeServerTimeRemaining(999, 30), 30); // Clamped as seconds
      expect(normalizeServerTimeRemaining(1001, 30), 2); // Treated as ms, ceil
    });

    test('works with different question durations', () {
      // 60 second question
      expect(normalizeServerTimeRemaining(45, 60), 45);
      expect(normalizeServerTimeRemaining(45000, 60), 45);
      expect(normalizeServerTimeRemaining(100, 60), 60); // Clamp
      expect(normalizeServerTimeRemaining(100000, 60), 60); // Clamp

      // 15 second question
      expect(normalizeServerTimeRemaining(10, 15), 10);
      expect(normalizeServerTimeRemaining(10000, 15), 10);
      expect(normalizeServerTimeRemaining(20, 15), 15); // Clamp
      expect(normalizeServerTimeRemaining(20000, 15), 15); // Clamp
    });
  });

  group('Duration Parsing (simulated _getQuestionDurationSeconds)', () {
    int getQuestionDurationSeconds(Map<String, dynamic>? question) {
      const int defaultDuration = 30;
      if (question == null) return defaultDuration;

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
        // Return default on error
      }

      return defaultDuration;
    }

    test('returns 30 for null question', () {
      expect(getQuestionDurationSeconds(null), 30);
    });

    test('returns 30 for empty question', () {
      expect(getQuestionDurationSeconds({}), 30);
    });

    test('parses durationSeconds as int', () {
      expect(getQuestionDurationSeconds({'durationSeconds': 45}), 45);
      expect(getQuestionDurationSeconds({'durationSeconds': 60}), 60);
      expect(getQuestionDurationSeconds({'durationSeconds': 15}), 15);
    });

    test('parses durationSeconds as string', () {
      expect(getQuestionDurationSeconds({'durationSeconds': '45'}), 45);
      expect(getQuestionDurationSeconds({'durationSeconds': '60'}), 60);
    });

    test('ignores invalid durationSeconds string', () {
      expect(getQuestionDurationSeconds({'durationSeconds': 'invalid'}), 30);
    });

    test('ignores zero or negative durationSeconds', () {
      expect(getQuestionDurationSeconds({'durationSeconds': 0}), 30);
      expect(getQuestionDurationSeconds({'durationSeconds': -5}), 30);
    });

    test('parses duration as int (fallback)', () {
      expect(getQuestionDurationSeconds({'duration': 45}), 45);
      expect(getQuestionDurationSeconds({'duration': 20}), 20);
    });

    test('parses duration as string', () {
      expect(getQuestionDurationSeconds({'duration': '45'}), 45);
    });

    test('prefers durationSeconds over duration', () {
      expect(
        getQuestionDurationSeconds({'durationSeconds': 60, 'duration': 30}),
        60,
      );
    });

    test('parses durationMs as int and converts to seconds', () {
      expect(getQuestionDurationSeconds({'durationMs': 45000}), 45);
      expect(getQuestionDurationSeconds({'durationMs': 30000}), 30);
      expect(getQuestionDurationSeconds({'durationMs': 15000}), 15);
    });

    test('parses durationMs as string and converts', () {
      expect(getQuestionDurationSeconds({'durationMs': '45000'}), 45);
      expect(getQuestionDurationSeconds({'durationMs': '30000'}), 30);
    });

    test('ceils durationMs conversion (rounds up)', () {
      // 45500ms = 45.5s => ceil to 46s
      expect(getQuestionDurationSeconds({'durationMs': 45500}), 46);
      // 1ms = 0.001s => ceil to 1s
      expect(getQuestionDurationSeconds({'durationMs': 1}), 1);
      // 1999ms = 1.999s => ceil to 2s
      expect(getQuestionDurationSeconds({'durationMs': 1999}), 2);
    });

    test('clamps durationMs to 1-600 seconds range', () {
      expect(getQuestionDurationSeconds({'durationMs': 0}), 1); // Min 1s
      expect(getQuestionDurationSeconds({'durationMs': 500}), 1); // Min 1s
      expect(
        getQuestionDurationSeconds({'durationMs': 700000}),
        600,
      ); // Max 600s
      expect(
        getQuestionDurationSeconds({'durationMs': 1000000}),
        600,
      ); // Max 600s
    });

    test('ignores invalid durationMs string', () {
      expect(getQuestionDurationSeconds({'durationMs': 'invalid'}), 30);
    });

    test('handles multiple duration fields with priority', () {
      expect(
        getQuestionDurationSeconds({
          'durationSeconds': 60,
          'duration': 45,
          'durationMs': 30000,
        }),
        60, // durationSeconds wins
      );

      expect(
        getQuestionDurationSeconds({'duration': 45, 'durationMs': 30000}),
        45, // duration wins
      );

      expect(
        getQuestionDurationSeconds({'durationMs': 30000}),
        30, // Only durationMs
      );
    });

    test('returns default for malformed data', () {
      expect(getQuestionDurationSeconds({'durationSeconds': []}), 30);
      expect(getQuestionDurationSeconds({'duration': {}}), 30);
      expect(getQuestionDurationSeconds({'durationMs': true}), 30);
    });
  });

  group('Integration scenarios', () {
    test('realistic server response: timeRemaining in milliseconds', () {
      // Server sends timeRemaining: 4622 (ms)
      int normalized = (dynamic value, int duration) {
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
        if (raw >= 1000 && raw <= duration * 1000) {
          final sec = ((raw + 999) ~/ 1000);
          return sec.clamp(0, duration);
        }
        if (raw >= duration * 1000) {
          final sec = ((raw + 999) ~/ 1000);
          return sec.clamp(0, duration);
        }
        if (raw > duration) return duration;
        return raw.clamp(0, duration);
      }(4622, 30);

      expect(normalized, 5); // 4622ms => ceil to 5s
    });

    test('realistic question with durationMs', () {
      final question = {
        'text': 'What is 2+2?',
        'options': ['3', '4', '5'],
        'correctIndex': 1,
        'durationMs': 45000,
      };

      int getQuestionDurationSeconds(Map<String, dynamic>? q) {
        const int defaultDuration = 30;
        if (q == null) return defaultDuration;
        try {
          if (q.containsKey('durationSeconds')) {
            final v = q['durationSeconds'];
            if (v is int && v > 0) return v;
            if (v is String) return int.tryParse(v) ?? defaultDuration;
          }
          if (q.containsKey('duration')) {
            final v = q['duration'];
            if (v is int && v > 0) return v;
            if (v is String) return int.tryParse(v) ?? defaultDuration;
          }
          if (q.containsKey('durationMs')) {
            final v = q['durationMs'];
            if (v is int) return ((v + 999) ~/ 1000).clamp(1, 600).toInt();
            if (v is String) {
              final parsed = int.tryParse(v);
              if (parsed != null) {
                return ((parsed + 999) ~/ 1000).clamp(1, 600).toInt();
              }
            }
          }
        } catch (e) {}
        return defaultDuration;
      }

      expect(getQuestionDurationSeconds(question), 45);
    });
  });
}
