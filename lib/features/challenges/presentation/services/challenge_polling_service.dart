import 'dart:async';

import 'package:flutter/foundation.dart';

/// Service to handle periodic polling for live challenge updates
/// Polls the backend every 5 seconds to check if challenge should advance
class ChallengePollingService {
  Timer? _pollingTimer;
  bool _isPolling = false;
  final Duration pollingInterval;

  /// Callback to execute on each poll
  final Future<void> Function() onPoll;

  /// Callback for errors during polling
  final void Function(dynamic error)? onError;

  ChallengePollingService({
    required this.onPoll,
    this.onError,
    this.pollingInterval = const Duration(seconds: 5),
  });

  /// Start polling
  void startPolling() {
    if (_isPolling) {
      debugPrint('ChallengePollingService - Already polling');
      return;
    }

    debugPrint(
      'ChallengePollingService - Starting polling every $pollingInterval',
    );
    _isPolling = true;

    // Execute immediately
    _executePoll();

    // Then schedule periodic execution
    _pollingTimer = Timer.periodic(pollingInterval, (_) {
      _executePoll();
    });
  }

  /// Execute a single poll
  Future<void> _executePoll() async {
    if (!_isPolling) return;

    try {
      debugPrint('ChallengePollingService - Executing poll...');
      await onPoll();
    } catch (e) {
      debugPrint('ChallengePollingService - Poll error: $e');
      onError?.call(e);
    }
  }

  /// Stop polling
  void stopPolling() {
    if (!_isPolling) return;

    debugPrint('ChallengePollingService - Stopping polling');
    _isPolling = false;
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Check if currently polling
  bool get isPolling => _isPolling;

  /// Dispose and cleanup
  void dispose() {
    stopPolling();
  }
}
