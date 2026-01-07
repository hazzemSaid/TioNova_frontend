import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Service for Firebase Realtime Database operations
/// Handles chapter creation progress updates from backend
/// Safari iOS/Web compatible implementation
class FirebaseRealtimeService {
  final FirebaseDatabase _database;
  bool _isInitialized = false;
  static bool _isSafariWeb = false;

  FirebaseRealtimeService(this._database) {
    _initialize();
  }

  /// Initialize Firebase with Safari-specific settings
  void _initialize() {
    if (_isInitialized) return;
    _isInitialized = true;

    // Detect Safari on iOS/Web
    _isSafariWeb = _detectSafari();

    if (kIsWeb) {
      print('🔥 [Firebase] Web platform detected, Safari: $_isSafariWeb');
      // For Safari, use long polling instead of WebSocket
      // This is handled automatically by Firebase SDK, but we log it
      if (_isSafariWeb) {
        print('🔥 [Firebase] Safari detected - using compatible connection');
      }
    }

    // Enable disk persistence for mobile, disable for web (Safari issues)
    if (!kIsWeb) {
      _database.setPersistenceEnabled(true);
    }

    print('✅ [Firebase] Realtime service initialized');
  }

  /// Detect if running on Safari browser
  static bool _detectSafari() {
    if (!kIsWeb) return false;
    // Safari detection is handled by checking user agent in web
    // For now, assume all web browsers need Safari-compatible mode
    return true;
  }

  /// Get a database reference with Safari-safe settings
  DatabaseReference getRef(String path) {
    final ref = _database.ref(path);
    // Keep synced for better real-time performance on Safari
    // Note: keepSynced is no-op on web but helps on mobile
    if (!kIsWeb) {
      ref.keepSynced(true);
    }
    return ref;
  }

  /// Subscribe to chapter creation progress updates (Safari-safe)
  /// Backend writes to: /chapter-creation/{userId}
  ///
  /// Data structure:
  /// {
  ///   "progress": 0-100,
  ///   "message": "Status message",
  ///   "chapterId": "optional-id",
  ///   "chapter": { ChapterModel },
  ///   "timestamp": 1234567890
  /// }
  Stream<Map<String, dynamic>> listenToChapterCreation(String userId) {
    print('🔥 [Firebase] Creating listener for /chapter-creation/$userId');

    final ref = getRef('chapter-creation/$userId');

    return ref.onValue
        .map((event) {
          if (event.snapshot.value == null) {
            print('🔥 [Firebase] No data at path');
            return <String, dynamic>{};
          }

          print('🔥 [Firebase] Data received: ${event.snapshot.value}');

          // Firebase returns Map<Object?, Object?>, need to convert
          final data = event.snapshot.value;
          if (data is Map) {
            return Map<String, dynamic>.from(
              data.map((key, value) => MapEntry(key.toString(), value)),
            );
          }

          return <String, dynamic>{};
        })
        .handleError((error) {
          print('❌ [Firebase] Stream error: $error');
          // Return empty map on error to prevent stream from breaking
          return <String, dynamic>{};
        });
  }

  /// Subscribe to a path with Safari-safe settings
  /// Returns a stream that handles Safari-specific issues
  Stream<DatabaseEvent> listenToPath(String path) {
    print('🔥 [Firebase] Creating listener for /$path');
    final ref = getRef(path);
    return ref.onValue.handleError((error) {
      print('❌ [Firebase] Stream error for $path: $error');
    });
  }

  /// Subscribe to child events (Safari-safe)
  Stream<DatabaseEvent> listenToChildAdded(String path) {
    final ref = getRef(path);
    return ref.onChildAdded.handleError((error) {
      print('❌ [Firebase] Child added error for $path: $error');
    });
  }

  /// Subscribe to child changes (Safari-safe)
  Stream<DatabaseEvent> listenToChildChanged(String path) {
    final ref = getRef(path);
    return ref.onChildChanged.handleError((error) {
      print('❌ [Firebase] Child changed error for $path: $error');
    });
  }

  /// Clear chapter creation progress data
  /// Call this after successful completion to clean up
  Future<void> clearChapterCreation(String userId) async {
    print('🔥 [Firebase] Clearing /chapter-creation/$userId');
    try {
      await _database.ref('chapter-creation/$userId').remove();
      print('✅ [Firebase] Cleared successfully');
    } catch (e) {
      print('❌ [Firebase] Error clearing: $e');
    }
  }

  /// One-time read of chapter creation status
  /// Useful for checking if there's a pending creation
  Future<Map<String, dynamic>?> getChapterCreationStatus(String userId) async {
    print('🔥 [Firebase] Reading /chapter-creation/$userId');
    try {
      final snapshot = await _database.ref('chapter-creation/$userId').get();
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value;
        if (data is Map) {
          return Map<String, dynamic>.from(
            data.map((key, value) => MapEntry(key.toString(), value)),
          );
        }
      }
      return null;
    } catch (e) {
      print('❌ [Firebase] Error reading: $e');
      return null;
    }
  }

  /// One-time read of any path (Safari-safe with timeout)
  Future<DataSnapshot?> getOnce(String path) async {
    print('🔥 [Firebase] One-time read: /$path');
    try {
      final snapshot = await _database
          .ref(path)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Firebase read timeout for $path');
            },
          );
      return snapshot;
    } catch (e) {
      print('❌ [Firebase] Error reading $path: $e');
      return null;
    }
  }

  /// Write data to a path
  Future<bool> write(String path, dynamic data) async {
    print('🔥 [Firebase] Writing to /$path');
    try {
      await _database.ref(path).set(data);
      print('✅ [Firebase] Write successful');
      return true;
    } catch (e) {
      print('❌ [Firebase] Write error: $e');
      return false;
    }
  }

  /// Update data at a path
  Future<bool> update(String path, Map<String, dynamic> data) async {
    print('🔥 [Firebase] Updating /$path');
    try {
      await _database.ref(path).update(data);
      print('✅ [Firebase] Update successful');
      return true;
    } catch (e) {
      print('❌ [Firebase] Update error: $e');
      return false;
    }
  }

  /// Remove data at a path
  Future<bool> remove(String path) async {
    print('🔥 [Firebase] Removing /$path');
    try {
      await _database.ref(path).remove();
      print('✅ [Firebase] Remove successful');
      return true;
    } catch (e) {
      print('❌ [Firebase] Remove error: $e');
      return false;
    }
  }

  /// Parse Firebase snapshot data to Map
  static Map<String, dynamic> parseSnapshot(DataSnapshot snapshot) {
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

  /// Parse Firebase list data
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

  /// Check if Firebase is available and connected
  Future<bool> isConnected() async {
    try {
      final connectedRef = _database.ref('.info/connected');
      final snapshot = await connectedRef.get();
      return snapshot.value == true;
    } catch (e) {
      print('❌ [Firebase] Connection check error: $e');
      return false;
    }
  }

  /// Listen to connection state changes
  Stream<bool> connectionStream() {
    return _database.ref('.info/connected').onValue.map((event) {
      return event.snapshot.value == true;
    });
  }
}
