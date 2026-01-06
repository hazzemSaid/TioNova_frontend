import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Safari iOS/Web compatible Firebase helper for challenges
/// Provides safe wrappers for Firebase Realtime Database operations
class FirebaseChallengeHelper {
  static FirebaseDatabase? _database;

  /// Get the FirebaseDatabase instance with Safari-safe configuration
  static FirebaseDatabase get database {
    _database ??= FirebaseDatabase.instance;
    return _database!;
  }

  /// Get a database reference with Safari-safe settings
  static DatabaseReference getRef(String path) {
    final ref = database.ref(path);
    // keepSynced helps with real-time updates on mobile
    // No-op on web but safe to call
    if (!kIsWeb) {
      try {
        ref.keepSynced(true);
      } catch (e) {
        print('⚠️ [FirebaseChallenge] keepSynced failed: $e');
      }
    }
    return ref;
  }

  /// Create a Safari-safe value listener
  /// Automatically handles errors and Safari-specific issues
  static StreamSubscription<DatabaseEvent> listenToValue(
    String path, {
    required void Function(DataSnapshot snapshot) onData,
    void Function(Object error)? onError,
  }) {
    final ref = getRef(path);
    return ref.onValue.listen(
      (event) {
        onData(event.snapshot);
      },
      onError: (error) {
        print('❌ [FirebaseChallenge] Error listening to $path: $error');
        if (onError != null) {
          onError(error);
        }
      },
      cancelOnError: false, // Don't cancel on Safari transient errors
    );
  }

  /// Create a Safari-safe child added listener
  static StreamSubscription<DatabaseEvent> listenToChildAdded(
    String path, {
    required void Function(DataSnapshot snapshot) onData,
    void Function(Object error)? onError,
  }) {
    final ref = getRef(path);
    return ref.onChildAdded.listen(
      (event) {
        onData(event.snapshot);
      },
      onError: (error) {
        print('❌ [FirebaseChallenge] Error on child added $path: $error');
        if (onError != null) {
          onError(error);
        }
      },
      cancelOnError: false,
    );
  }

  /// Create a Safari-safe child changed listener
  static StreamSubscription<DatabaseEvent> listenToChildChanged(
    String path, {
    required void Function(DataSnapshot snapshot) onData,
    void Function(Object error)? onError,
  }) {
    final ref = getRef(path);
    return ref.onChildChanged.listen(
      (event) {
        onData(event.snapshot);
      },
      onError: (error) {
        print('❌ [FirebaseChallenge] Error on child changed $path: $error');
        if (onError != null) {
          onError(error);
        }
      },
      cancelOnError: false,
    );
  }

  /// One-time read with Safari-safe timeout handling
  static Future<DataSnapshot?> getOnce(String path) async {
    try {
      final ref = getRef(path);
      final snapshot = await ref.get().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Firebase read timeout for $path');
        },
      );
      return snapshot;
    } catch (e) {
      print('❌ [FirebaseChallenge] Error reading $path: $e');
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
          result.add(Map<String, dynamic>.from(
            item.map((key, value) => MapEntry(key.toString(), value)),
          ));
        }
      }
    } else if (data is Map) {
      data.forEach((key, value) {
        if (value != null && value is Map) {
          result.add(Map<String, dynamic>.from(
            value.map((k, v) => MapEntry(k.toString(), v)),
          ));
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

  /// Check if Firebase is connected
  static Future<bool> isConnected() async {
    try {
      final connectedRef = database.ref('.info/connected');
      final snapshot = await connectedRef.get();
      return snapshot.value == true;
    } catch (e) {
      print('❌ [FirebaseChallenge] Connection check error: $e');
      return false;
    }
  }

  /// Listen to connection state changes
  static Stream<bool> connectionStream() {
    return database.ref('.info/connected').onValue.map((event) {
      return event.snapshot.value == true;
    });
  }

  /// Write data to a path (Safari-safe)
  static Future<bool> write(String path, dynamic data) async {
    try {
      await database.ref(path).set(data).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Firebase write timeout for $path');
        },
      );
      return true;
    } catch (e) {
      print('❌ [FirebaseChallenge] Write error for $path: $e');
      return false;
    }
  }

  /// Update data at a path (Safari-safe)
  static Future<bool> update(String path, Map<String, dynamic> data) async {
    try {
      await database.ref(path).update(data).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Firebase update timeout for $path');
        },
      );
      return true;
    } catch (e) {
      print('❌ [FirebaseChallenge] Update error for $path: $e');
      return false;
    }
  }

  /// Remove data at a path (Safari-safe)
  static Future<bool> remove(String path) async {
    try {
      await database.ref(path).remove().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Firebase remove timeout for $path');
        },
      );
      return true;
    } catch (e) {
      print('❌ [FirebaseChallenge] Remove error for $path: $e');
      return false;
    }
  }

  /// Cancel multiple subscriptions safely
  static Future<void> cancelSubscriptions(
    List<StreamSubscription?> subscriptions,
  ) async {
    for (final subscription in subscriptions) {
      try {
        await subscription?.cancel();
      } catch (e) {
        print('⚠️ [FirebaseChallenge] Error canceling subscription: $e');
      }
    }
  }
}
