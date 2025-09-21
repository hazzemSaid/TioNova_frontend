import 'package:hive/hive.dart';
import 'package:tionova/core/models/summary_cache_model.dart';
import 'package:tionova/features/folder/data/models/SummaryModel.dart';

class SummaryCacheService {
  // Get the summary cache box
  static Box<SummaryCacheModel> get _summaryCacheBox =>
      Hive.box<SummaryCacheModel>('summaryCache');

  /// Initialize the summary cache service and clean up expired cache
  static Future<void> initialize() async {
    try {
      await clearExpiredCache();
      print('SummaryCacheService initialized successfully');
    } catch (e) {
      print('Error initializing SummaryCacheService: $e');
      // If there's a major issue, clear all cache and start fresh
      try {
        await _summaryCacheBox.clear();
        print('Cleared all summary cache due to initialization error');
      } catch (clearError) {
        print('Error clearing summary cache: $clearError');
      }
    }
  }

  /// Clear expired cache entries
  static Future<void> clearExpiredCache() async {
    try {
      final keys = _summaryCacheBox.keys.toList();
      for (final key in keys) {
        final cached = _summaryCacheBox.get(key);
        if (cached != null && cached.isExpired()) {
          await _summaryCacheBox.delete(key);
          print('Removed expired summary cache for: $key');
        }
      }
    } catch (e) {
      print('Error clearing expired summary cache: $e');
    }
  }

  /// Force reset cache (useful for debugging or after major app updates)
  static Future<void> resetCache() async {
    try {
      await _summaryCacheBox.clear();
      await _summaryCacheBox.close();
      await Hive.deleteBoxFromDisk('summaryCache');
      await Hive.openBox<SummaryCacheModel>('summaryCache');
      print('Summary cache reset successfully');
    } catch (e) {
      print('Error resetting summary cache: $e');
    }
  }

  /// Check if summary is already cached and not expired
  static bool isSummaryCached(String chapterId) {
    try {
      final cached = _summaryCacheBox.get(chapterId);
      if (cached == null) return false;

      // Check if cache is expired (remove expired entries)
      if (cached.isExpired()) {
        _summaryCacheBox.delete(chapterId);
        return false;
      }

      return true;
    } catch (e) {
      // Handle type errors or corrupted cache data
      print('Error checking summary cache for $chapterId: $e');
      // Clear corrupted entry
      _summaryCacheBox.delete(chapterId);
      return false;
    }
  }

  /// Get cached summary data
  static SummaryModel? getCachedSummary(String chapterId) {
    try {
      final cached = _summaryCacheBox.get(chapterId);
      if (cached == null) return null;

      // Check if cache is expired
      if (cached.isExpired()) {
        _summaryCacheBox.delete(chapterId);
        return null;
      }

      return cached.summaryData;
    } catch (e) {
      // Handle type errors or corrupted cache data
      print('Error getting cached summary for $chapterId: $e');
      // Clear corrupted entry
      _summaryCacheBox.delete(chapterId);
      return null;
    }
  }

  /// Get cached summary with metadata
  static SummaryCacheModel? getCachedSummaryWithMetadata(String chapterId) {
    try {
      final cached = _summaryCacheBox.get(chapterId);
      if (cached == null) return null;

      // Check if cache is expired
      if (cached.isExpired()) {
        _summaryCacheBox.delete(chapterId);
        return null;
      }

      return cached;
    } catch (e) {
      // Handle type errors or corrupted cache data
      print('Error getting cached summary metadata for $chapterId: $e');
      // Clear corrupted entry
      _summaryCacheBox.delete(chapterId);
      return null;
    }
  }

  /// Cache summary data with metadata
  static Future<void> cacheSummary(
    String chapterId,
    SummaryModel summaryData, {
    String? chapterTitle,
  }) async {
    try {
      final cacheModel = SummaryCacheModel.create(
        chapterId: chapterId,
        summaryData: summaryData,
        chapterTitle: chapterTitle,
      );

      await _summaryCacheBox.put(chapterId, cacheModel);
      print('Summary cached successfully for $chapterId');
    } catch (e) {
      print('Error caching summary for $chapterId: $e');
    }
  }

  /// Remove cached summary for specific chapter
  static Future<void> removeCachedSummary(String chapterId) async {
    try {
      await _summaryCacheBox.delete(chapterId);
      print('Removed cached summary for $chapterId');
    } catch (e) {
      print('Error removing cached summary for $chapterId: $e');
    }
  }

  /// Get all cached summaries
  static List<SummaryCacheModel> getAllCachedSummaries() {
    try {
      return _summaryCacheBox.values
          .where((cache) => !cache.isExpired())
          .toList();
    } catch (e) {
      print('Error getting all cached summaries: $e');
      return [];
    }
  }

  /// Get cache statistics
  static Map<String, dynamic> getCacheStats() {
    try {
      final allCaches = _summaryCacheBox.values.toList();
      final validCaches = allCaches
          .where((cache) => !cache.isExpired())
          .toList();
      final expiredCaches = allCaches
          .where((cache) => cache.isExpired())
          .toList();

      return {
        'total_entries': allCaches.length,
        'valid_entries': validCaches.length,
        'expired_entries': expiredCaches.length,
        'oldest_entry': validCaches.isNotEmpty
            ? validCaches
                  .map((c) => c.cachedAt)
                  .reduce((a, b) => a.isBefore(b) ? a : b)
            : null,
        'newest_entry': validCaches.isNotEmpty
            ? validCaches
                  .map((c) => c.cachedAt)
                  .reduce((a, b) => a.isAfter(b) ? a : b)
            : null,
      };
    } catch (e) {
      print('Error getting cache stats: $e');
      return {'error': e.toString()};
    }
  }
}
