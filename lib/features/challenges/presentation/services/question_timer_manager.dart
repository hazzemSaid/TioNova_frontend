import 'dart:async';

import 'package:flutter/foundation.dart';

/// Manages countdown timer for quiz questions
/// Features:
/// - 30-second countdown per question
/// - Auto-reset when new question starts
/// - Visual updates every second
/// - Callbacks for timer events
class QuestionTimerManager {
  Timer? _timer;
  int _remainingSeconds = 30;
  bool _isRunning = false;

  /// Default duration for each question (30 seconds)
  final int defaultDuration;

  /// Callback fired every second with remaining time
  final void Function(int remainingSeconds)? onTick;

  /// Callback fired when timer reaches zero
  final void Function()? onTimeout;

  /// Callback fired when timer is started
  final void Function()? onStart;

  /// Callback fired when timer is paused
  final void Function()? onPause;

  QuestionTimerManager({
    this.defaultDuration = 30,
    this.onTick,
    this.onTimeout,
    this.onStart,
    this.onPause,
  }) : _remainingSeconds = defaultDuration;

  /// Get current remaining seconds
  int get remainingSeconds => _remainingSeconds;

  /// Get remaining time as progress (0.0 to 1.0)
  double get progress => _remainingSeconds / defaultDuration;

  /// Check if timer is currently running
  bool get isRunning => _isRunning;

  /// Check if timer has expired
  bool get hasExpired => _remainingSeconds <= 0;

  /// Start the timer from a specific time
  /// [startTime] - Unix timestamp in milliseconds when question started
  void start({int? startTime}) {
    if (_isRunning) {
      debugPrint('QuestionTimerManager - Timer already running');
      return;
    }

    // Calculate elapsed time if start time provided
    if (startTime != null) {
      final elapsed =
          (DateTime.now().millisecondsSinceEpoch - startTime) ~/ 1000;
      _remainingSeconds = defaultDuration - elapsed;
      debugPrint(
        'QuestionTimerManager - Starting with $elapsed seconds elapsed, $_remainingSeconds remaining',
      );
    } else {
      _remainingSeconds = defaultDuration;
      debugPrint(
        'QuestionTimerManager - Starting fresh with $defaultDuration seconds',
      );
    }

    // If time already expired, trigger timeout immediately
    if (_remainingSeconds <= 0) {
      _remainingSeconds = 0;
      onTick?.call(_remainingSeconds);
      onTimeout?.call();
      return;
    }

    _isRunning = true;
    onStart?.call();
    onTick?.call(_remainingSeconds);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingSeconds--;
      onTick?.call(_remainingSeconds);

      debugPrint(
        'QuestionTimerManager - Tick: $_remainingSeconds seconds remaining',
      );

      if (_remainingSeconds <= 0) {
        debugPrint('QuestionTimerManager - Timer expired!');
        stop();
        onTimeout?.call();
      }
    });
  }

  /// Pause the timer
  void pause() {
    if (!_isRunning) return;

    debugPrint('QuestionTimerManager - Pausing at $_remainingSeconds seconds');
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
    onPause?.call();
  }

  /// Resume the timer
  void resume() {
    if (_isRunning) return;

    debugPrint(
      'QuestionTimerManager - Resuming from $_remainingSeconds seconds',
    );
    start();
  }

  /// Stop and reset the timer
  void stop() {
    if (_timer != null) {
      debugPrint('QuestionTimerManager - Stopping timer');
      _timer!.cancel();
      _timer = null;
    }
    _isRunning = false;
  }

  /// Reset timer to default duration
  void reset() {
    debugPrint('QuestionTimerManager - Resetting timer');
    stop();
    _remainingSeconds = defaultDuration;
    onTick?.call(_remainingSeconds);
  }

  /// Dispose and cleanup
  void dispose() {
    debugPrint('QuestionTimerManager - Disposing');
    stop();
  }
}
