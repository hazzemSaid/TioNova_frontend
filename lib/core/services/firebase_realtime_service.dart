import 'package:firebase_database/firebase_database.dart';

/// Service for Firebase Realtime Database operations
/// Handles chapter creation progress updates from backend
class FirebaseRealtimeService {
  final FirebaseDatabase _database;

  FirebaseRealtimeService(this._database);

  /// Subscribe to chapter creation progress updates
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

    final ref = _database.ref('chapter-creation/$userId');

    return ref.onValue.map((event) {
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
}
