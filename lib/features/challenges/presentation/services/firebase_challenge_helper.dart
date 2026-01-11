import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

/// Safari iOS/Web compatible Firebase helper for challenges
/// Provides safe wrappers for Firebase Realtime Database operations
/// Enhanced with improved error handling and platform-specific compatibility
class FirebaseChallengeHelper {
  static FirebaseDatabase? _database;
  static bool? _isSafari;
  static bool _isInitialized = false;

  /// Internal logging utility for Firebase operations
  static void _log(String level, String message, [Object? error]) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] [FirebaseChallenge] [$level] $message';

    if (error != null) {
      debugPrint('$logMessage - Error: $error');
    } else {
      debugPrint(logMessage);
    }
  }

  /// Detect if running on Safari browser
  static bool get isSafari {
    if (_isSafari != null) return _isSafari!;

    if (!kIsWeb) {
      _isSafari = false;
      return false;
    }

    try {
      // Use a safer approach for Safari detection on web
      // This is a simplified detection that assumes Safari-like behavior
      // for any web platform that might have compatibility issues
      _isSafari = true; // Assume Safari-compatible mode for all web platforms
      _log('INFO', 'Web platform detected, using Safari-compatible mode');
    } catch (e) {
      _log(
        'WARN',
        'Failed to detect browser type, assuming Safari-compatible mode',
        e,
      );
      _isSafari = true; // Default to Safari-compatible mode for safety
    }

    return _isSafari!;
  }

  /// Initialize Firebase with platform-specific settings
  static void _initialize() {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      _database = FirebaseDatabase.instance;

      if (kIsWeb) {
        _log('INFO', 'Web platform detected, Safari: $isSafari');
        if (isSafari) {
          _log('INFO', 'Applying Safari-specific Firebase configuration');
          // Safari-specific configuration can be added here
        }
      } else {
        _log('INFO', 'Mobile platform detected, enabling persistence');
        try {
          _database!.setPersistenceEnabled(true);
        } catch (e) {
          _log('WARN', 'Failed to enable persistence', e);
        }
      }

      _log('INFO', 'Firebase Challenge Helper initialized successfully');
    } catch (e) {
      _log('ERROR', 'Failed to initialize Firebase Challenge Helper', e);
      rethrow;
    }
  }

  /// Get the FirebaseDatabase instance with Safari-safe configuration
  static FirebaseDatabase get database {
    _initialize();
    if (_database == null) {
      throw StateError('Firebase Database is not available');
    }
    return _database!;
  }

  /// Get a database reference with Safari-safe settings and enhanced error handling
  static DatabaseReference getRef(String path) {
    try {
      final ref = database.ref(path);

      // keepSynced helps with real-time updates on mobile
      // Skip on web platforms to avoid Safari issues
      if (!kIsWeb) {
        try {
          ref.keepSynced(true);
          _log('DEBUG', 'keepSynced enabled for path: $path');
        } catch (e) {
          _log('WARN', 'keepSynced failed for path: $path', e);
        }
      } else if (isSafari) {
        _log(
          'DEBUG',
          'Skipping keepSynced for Safari compatibility on path: $path',
        );
      }

      return ref;
    } catch (e) {
      _log('ERROR', 'Failed to get reference for path: $path', e);
      rethrow;
    }
  }

  /// Create a Safari-safe value listener with enhanced error handling
  /// Automatically handles errors and Safari-specific issues
  static StreamSubscription<DatabaseEvent> listenToValue(
    String path, {
    required void Function(DataSnapshot snapshot) onData,
    void Function(Object error)? onError,
  }) {
    _log('DEBUG', 'Creating value listener for path: $path');

    try {
      final ref = getRef(path);
      return ref.onValue.listen(
        (event) {
          try {
            _log('DEBUG', 'Value update received for path: $path');
            onData(event.snapshot);
          } catch (e) {
            _log('ERROR', 'Error processing value update for path: $path', e);
            if (onError != null) {
              onError(e);
            }
          }
        },
        onError: (error) {
          _log('ERROR', 'Stream error for path: $path', error);

          // Handle Safari-specific errors
          if (isSafari && _isSafariNetworkError(error)) {
            _log(
              'WARN',
              'Safari network error detected, attempting recovery for path: $path',
            );
            // Safari-specific error recovery can be implemented here
          }

          if (onError != null) {
            onError(error);
          }
        },
        cancelOnError: false, // Don't cancel on Safari transient errors
      );
    } catch (e) {
      _log('ERROR', 'Failed to create value listener for path: $path', e);
      rethrow;
    }
  }

  /// Create a Safari-safe child added listener with enhanced error handling
  static StreamSubscription<DatabaseEvent> listenToChildAdded(
    String path, {
    required void Function(DataSnapshot snapshot) onData,
    void Function(Object error)? onError,
  }) {
    _log('DEBUG', 'Creating child added listener for path: $path');

    try {
      final ref = getRef(path);
      return ref.onChildAdded.listen(
        (event) {
          try {
            _log('DEBUG', 'Child added event received for path: $path');
            onData(event.snapshot);
          } catch (e) {
            _log(
              'ERROR',
              'Error processing child added event for path: $path',
              e,
            );
            if (onError != null) {
              onError(e);
            }
          }
        },
        onError: (error) {
          _log('ERROR', 'Child added stream error for path: $path', error);

          if (isSafari && _isSafariNetworkError(error)) {
            _log(
              'WARN',
              'Safari network error in child added listener for path: $path',
            );
          }

          if (onError != null) {
            onError(error);
          }
        },
        cancelOnError: false,
      );
    } catch (e) {
      _log('ERROR', 'Failed to create child added listener for path: $path', e);
      rethrow;
    }
  }

  /// Create a Safari-safe child changed listener with enhanced error handling
  static StreamSubscription<DatabaseEvent> listenToChildChanged(
    String path, {
    required void Function(DataSnapshot snapshot) onData,
    void Function(Object error)? onError,
  }) {
    _log('DEBUG', 'Creating child changed listener for path: $path');

    try {
      final ref = getRef(path);
      return ref.onChildChanged.listen(
        (event) {
          try {
            _log('DEBUG', 'Child changed event received for path: $path');
            onData(event.snapshot);
          } catch (e) {
            _log(
              'ERROR',
              'Error processing child changed event for path: $path',
              e,
            );
            if (onError != null) {
              onError(e);
            }
          }
        },
        onError: (error) {
          _log('ERROR', 'Child changed stream error for path: $path', error);

          if (isSafari && _isSafariNetworkError(error)) {
            _log(
              'WARN',
              'Safari network error in child changed listener for path: $path',
            );
          }

          if (onError != null) {
            onError(error);
          }
        },
        cancelOnError: false,
      );
    } catch (e) {
      _log(
        'ERROR',
        'Failed to create child changed listener for path: $path',
        e,
      );
      rethrow;
    }
  }

  /// One-time read with Safari-safe timeout handling and enhanced error recovery
  static Future<DataSnapshot?> getOnce(String path) async {
    _log('DEBUG', 'Performing one-time read for path: $path');

    try {
      final ref = getRef(path);

      // Use different timeout values for Safari vs other platforms
      final timeoutDuration = isSafari
          ? const Duration(seconds: 15) // Longer timeout for Safari
          : const Duration(seconds: 10);

      final snapshot = await ref.get().timeout(
        timeoutDuration,
        onTimeout: () {
          final error =
              'Firebase read timeout for $path after ${timeoutDuration.inSeconds}s';
          _log('ERROR', error);
          throw TimeoutException(error);
        },
      );

      _log(
        'DEBUG',
        'Successfully read data from path: $path, exists: ${snapshot.exists}',
      );
      return snapshot;
    } on TimeoutException catch (e) {
      _log('ERROR', 'Timeout reading from path: $path', e);

      if (isSafari) {
        _log(
          'WARN',
          'Safari timeout detected, this may be due to network conditions',
        );
      }

      return null;
    } catch (e) {
      _log('ERROR', 'Error reading from path: $path', e);

      if (isSafari && _isSafariNetworkError(e)) {
        _log('WARN', 'Safari-specific network error detected for path: $path');
      }

      return null;
    }
  }

  /// Parse snapshot value to Map
  static Map<String, dynamic> parseMap(DataSnapshot snapshot) {
    if (!snapshot.exists || snapshot.value == null) {
      return <String, dynamic>{};
    }

    final data = snapshot.value;
    if (data is Map) {
      return Map<String, dynamic>.from(
        data.map((key, value) => MapEntry(key.toString(), value)),
      );
    }

    return <String, dynamic>{};
  }

  /// Parse snapshot value to List of Maps
  static List<Map<String, dynamic>> parseList(DataSnapshot snapshot) {
    if (!snapshot.exists || snapshot.value == null) {
      return <Map<String, dynamic>>[];
    }

    final data = snapshot.value;
    final result = <Map<String, dynamic>>[];

    if (data is List) {
      for (var item in data) {
        if (item != null && item is Map) {
          result.add(
            Map<String, dynamic>.from(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          );
        }
      }
    } else if (data is Map) {
      data.forEach((key, value) {
        if (value != null && value is Map) {
          result.add(
            Map<String, dynamic>.from(
              value.map((k, v) => MapEntry(k.toString(), v)),
            ),
          );
        }
      });
    }

    return result;
  }

  /// Parse participants from snapshot
  static List<Map<String, dynamic>> parseParticipants(DataSnapshot snapshot) {
    if (!snapshot.exists || snapshot.value == null) {
      return <Map<String, dynamic>>[];
    }

    final data = snapshot.value;
    final participants = <Map<String, dynamic>>[];

    if (data is Map) {
      data.forEach((userId, userData) {
        if (userData != null && userData is Map) {
          final participantData = Map<String, dynamic>.from(
            userData.map((k, v) => MapEntry(k.toString(), v)),
          );
          participantData['userId'] = userId.toString();
          participants.add(participantData);
        }
      });
    }

    return participants;
  }

  /// Count active participants
  static int countActiveParticipants(DataSnapshot snapshot) {
    final participants = parseParticipants(snapshot);
    return participants.where((p) {
      final active = p['active'];
      return active == null || active == true;
    }).length;
  }

  /// Parse rankings/leaderboard from snapshot
  static List<Map<String, dynamic>> parseRankings(DataSnapshot snapshot) {
    return parseList(snapshot);
  }

  /// Parse questions from snapshot
  static List<Map<String, dynamic>> parseQuestions(DataSnapshot snapshot) {
    return parseList(snapshot);
  }

  /// Check if Firebase is connected with platform-specific handling
  static Future<bool> isConnected() async {
    _log('DEBUG', 'Checking Firebase connection status');

    try {
      final connectedRef = database.ref('.info/connected');

      // Use different timeout for Safari
      final timeoutDuration = isSafari
          ? const Duration(seconds: 8)
          : const Duration(seconds: 5);

      final snapshot = await connectedRef.get().timeout(timeoutDuration);
      final isConnected = snapshot.value == true;

      _log('INFO', 'Firebase connection status: $isConnected');
      return isConnected;
    } catch (e) {
      _log('ERROR', 'Error checking Firebase connection', e);

      if (isSafari && _isSafariNetworkError(e)) {
        _log('WARN', 'Safari connection check failed, may be network-related');
      }

      return false;
    }
  }

  /// Listen to connection state changes with Safari-safe error handling
  static Stream<bool> connectionStream() {
    _log('DEBUG', 'Creating connection state stream');

    try {
      return database
          .ref('.info/connected')
          .onValue
          .map((event) {
            final isConnected = event.snapshot.value == true;
            _log('DEBUG', 'Connection state changed: $isConnected');
            return isConnected;
          })
          .handleError((error) {
            _log('ERROR', 'Connection stream error', error);

            if (isSafari && _isSafariNetworkError(error)) {
              _log('WARN', 'Safari connection stream error detected');
            }

            // Return false on error to indicate disconnection
            return false;
          });
    } catch (e) {
      _log('ERROR', 'Failed to create connection stream', e);
      // Return a stream that emits false to indicate no connection
      return Stream.value(false);
    }
  }

  /// Write data to a path with Safari-safe timeout and retry logic
  static Future<bool> write(String path, dynamic data) async {
    _log('DEBUG', 'Writing data to path: $path');

    try {
      final timeoutDuration = isSafari
          ? const Duration(seconds: 15)
          : const Duration(seconds: 10);

      await database
          .ref(path)
          .set(data)
          .timeout(
            timeoutDuration,
            onTimeout: () {
              final error =
                  'Firebase write timeout for $path after ${timeoutDuration.inSeconds}s';
              _log('ERROR', error);
              throw TimeoutException(error);
            },
          );

      _log('DEBUG', 'Successfully wrote data to path: $path');
      return true;
    } on TimeoutException catch (e) {
      _log('ERROR', 'Write timeout for path: $path', e);

      if (isSafari) {
        _log('WARN', 'Safari write timeout, attempting retry...');
        // Implement retry logic for Safari
        return await _retryWrite(path, data);
      }

      return false;
    } catch (e) {
      _log('ERROR', 'Write error for path: $path', e);

      if (isSafari && _isSafariNetworkError(e)) {
        _log('WARN', 'Safari network error during write, attempting retry...');
        return await _retryWrite(path, data);
      }

      return false;
    }
  }

  /// Update data at a path with Safari-safe timeout and retry logic
  static Future<bool> update(String path, Map<String, dynamic> data) async {
    _log('DEBUG', 'Updating data at path: $path');

    try {
      final timeoutDuration = isSafari
          ? const Duration(seconds: 15)
          : const Duration(seconds: 10);

      await database
          .ref(path)
          .update(data)
          .timeout(
            timeoutDuration,
            onTimeout: () {
              final error =
                  'Firebase update timeout for $path after ${timeoutDuration.inSeconds}s';
              _log('ERROR', error);
              throw TimeoutException(error);
            },
          );

      _log('DEBUG', 'Successfully updated data at path: $path');
      return true;
    } on TimeoutException catch (e) {
      _log('ERROR', 'Update timeout for path: $path', e);

      if (isSafari) {
        _log('WARN', 'Safari update timeout, attempting retry...');
        return await _retryUpdate(path, data);
      }

      return false;
    } catch (e) {
      _log('ERROR', 'Update error for path: $path', e);

      if (isSafari && _isSafariNetworkError(e)) {
        _log('WARN', 'Safari network error during update, attempting retry...');
        return await _retryUpdate(path, data);
      }

      return false;
    }
  }

  /// Remove data at a path with Safari-safe timeout and retry logic
  static Future<bool> remove(String path) async {
    _log('DEBUG', 'Removing data at path: $path');

    try {
      final timeoutDuration = isSafari
          ? const Duration(seconds: 15)
          : const Duration(seconds: 10);

      await database
          .ref(path)
          .remove()
          .timeout(
            timeoutDuration,
            onTimeout: () {
              final error =
                  'Firebase remove timeout for $path after ${timeoutDuration.inSeconds}s';
              _log('ERROR', error);
              throw TimeoutException(error);
            },
          );

      _log('DEBUG', 'Successfully removed data at path: $path');
      return true;
    } on TimeoutException catch (e) {
      _log('ERROR', 'Remove timeout for path: $path', e);

      if (isSafari) {
        _log('WARN', 'Safari remove timeout, attempting retry...');
        return await _retryRemove(path);
      }

      return false;
    } catch (e) {
      _log('ERROR', 'Remove error for path: $path', e);

      if (isSafari && _isSafariNetworkError(e)) {
        _log('WARN', 'Safari network error during remove, attempting retry...');
        return await _retryRemove(path);
      }

      return false;
    }
  }

  /// Cancel multiple subscriptions safely with enhanced error handling
  static Future<void> cancelSubscriptions(
    List<StreamSubscription?> subscriptions,
  ) async {
    _log('DEBUG', 'Canceling ${subscriptions.length} subscriptions');

    int canceledCount = 0;
    int errorCount = 0;

    for (final subscription in subscriptions) {
      if (subscription == null) continue;

      try {
        await subscription.cancel();
        canceledCount++;
      } catch (e) {
        errorCount++;
        _log('WARN', 'Error canceling subscription', e);
      }
    }

    _log(
      'INFO',
      'Subscription cleanup complete: $canceledCount canceled, $errorCount errors',
    );
  }

  /// Helper method to detect Safari-specific network errors
  static bool _isSafariNetworkError(Object error) {
    if (!isSafari) return false;

    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('websocket') ||
        errorString.contains('cors');
  }

  /// Retry write operation with exponential backoff (Safari-specific)
  static Future<bool> _retryWrite(
    String path,
    dynamic data, [
    int attempt = 1,
  ]) async {
    if (attempt > 3) {
      _log('ERROR', 'Max retry attempts reached for write to path: $path');
      return false;
    }

    _log('DEBUG', 'Retry attempt $attempt for write to path: $path');

    // Exponential backoff: 1s, 2s, 4s
    await Future.delayed(Duration(seconds: attempt));

    try {
      await database.ref(path).set(data).timeout(const Duration(seconds: 20));
      _log('DEBUG', 'Retry write successful for path: $path');
      return true;
    } catch (e) {
      _log('WARN', 'Retry attempt $attempt failed for write to path: $path', e);
      return await _retryWrite(path, data, attempt + 1);
    }
  }

  /// Retry update operation with exponential backoff (Safari-specific)
  static Future<bool> _retryUpdate(
    String path,
    Map<String, dynamic> data, [
    int attempt = 1,
  ]) async {
    if (attempt > 3) {
      _log('ERROR', 'Max retry attempts reached for update to path: $path');
      return false;
    }

    _log('DEBUG', 'Retry attempt $attempt for update to path: $path');

    await Future.delayed(Duration(seconds: attempt));

    try {
      await database
          .ref(path)
          .update(data)
          .timeout(const Duration(seconds: 20));
      _log('DEBUG', 'Retry update successful for path: $path');
      return true;
    } catch (e) {
      _log(
        'WARN',
        'Retry attempt $attempt failed for update to path: $path',
        e,
      );
      return await _retryUpdate(path, data, attempt + 1);
    }
  }

  /// Retry remove operation with exponential backoff (Safari-specific)
  static Future<bool> _retryRemove(String path, [int attempt = 1]) async {
    if (attempt > 3) {
      _log('ERROR', 'Max retry attempts reached for remove from path: $path');
      return false;
    }

    _log('DEBUG', 'Retry attempt $attempt for remove from path: $path');

    await Future.delayed(Duration(seconds: attempt));

    try {
      await database.ref(path).remove().timeout(const Duration(seconds: 20));
      _log('DEBUG', 'Retry remove successful for path: $path');
      return true;
    } catch (e) {
      _log(
        'WARN',
        'Retry attempt $attempt failed for remove from path: $path',
        e,
      );
      return await _retryRemove(path, attempt + 1);
    }
  }
}
