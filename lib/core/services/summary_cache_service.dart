import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:tionova/features/folder/data/models/SummaryModel.dart';

/// Wrapper class to hold cached summary with metadata
class CachedSummaryData {
  final SummaryModel summaryData;
  final DateTime cachedAt;
  final String? chapterTitle;

  CachedSummaryData({
    required this.summaryData,
    required this.cachedAt,
    this.chapterTitle,
  });

  /// Get how old the cache is
  String get cacheAge {
    final duration = DateTime.now().difference(cachedAt);
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes} minutes ago';
    } else if (duration.inHours < 24) {
      return '${duration.inHours} hours ago';
    } else {
      return '${duration.inDays} days ago';
    }
  }
}

/// Summary cache service - no caching on web
class SummaryCacheService {
  /// Initialize the summary cache service
  static Future<void> initialize() async {
    print('SummaryCacheService initialized (no caching on web)');
  }

  /// Clear expired cache entries (no-op on web)
  static Future<void> clearExpiredCache() async {
    if (kIsWeb) return;
  }

  /// Force reset cache (no-op on web)
  static Future<void> resetCache() async {
    if (kIsWeb) return;
  }

  /// Check if summary is already cached (always false on web)
  static bool isSummaryCached(String chapterId) {
    if (kIsWeb) return false;
    return false;
  }

  /// Get cached summary data (always null on web)
  static SummaryModel? getCachedSummary(String chapterId) {
    if (kIsWeb) return null;
    return null;
  }

  /// Get cached summary with metadata (always null on web)
  static CachedSummaryData? getCachedSummaryWithMetadata(String chapterId) {
    if (kIsWeb) return null;
    return null;
  }

  /// Cache summary data (no-op on web)
  static Future<void> cacheSummary(
    String chapterId,
    SummaryModel summaryData, {
    String? chapterTitle,
  }) async {
    if (kIsWeb) return;
  }

  /// Remove cached summary for specific chapter (no-op on web)
  static Future<void> removeCachedSummary(String chapterId) async {
    if (kIsWeb) return;
  }

  /// Get cache statistics
  static Map<String, dynamic> getCacheStats() {
    return {'total_entries': 0, 'valid_entries': 0, 'expired_entries': 0};
  }
}
