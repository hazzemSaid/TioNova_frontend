import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:tionova/core/models/pdf_cache_model.dart';

// Conditional imports for platform-specific functionality
import 'download_service_stub.dart'
    if (dart.library.io) 'download_service_io.dart'
    as platform;

class DownloadService {
  // Get the PDF cache box
  static Box<PdfCacheModel> get _pdfCacheBox =>
      Hive.box<PdfCacheModel>('pdfCache');

  /// Initialize the download service and clean up corrupted cache
  static Future<void> initialize() async {
    try {
      await clearCorruptedCache();
      print('DownloadService initialized successfully');
    } catch (e) {
      print('Error initializing DownloadService: $e');
      // If there's a major issue, clear all cache and start fresh
      try {
        await _pdfCacheBox.clear();
        print('Cleared all cache due to initialization error');
      } catch (clearError) {
        print('Error clearing cache: $clearError');
      }
    }
  }

  /// Force reset cache (useful for debugging or after major app updates)
  static Future<void> resetCache() async {
    try {
      await _pdfCacheBox.clear();
      await _pdfCacheBox.close();
      await Hive.deleteBoxFromDisk('pdfCache');
      await Hive.openBox<PdfCacheModel>('pdfCache');
      print('Cache reset successfully');
    } catch (e) {
      print('Error resetting cache: $e');
    }
  }

  /// Check if PDF is already cached
  static bool isPDFCached(String chapterId) {
    try {
      final cached = _pdfCacheBox.get(chapterId);
      if (cached == null) return false;

      // Check if cache is expired (optional: remove expired entries)
      if (cached.isExpired()) {
        _pdfCacheBox.delete(chapterId);
        return false;
      }

      return true;
    } catch (e) {
      // Handle type errors or corrupted cache data
      print('Error checking cache for $chapterId: $e');
      // Clear corrupted entry
      _pdfCacheBox.delete(chapterId);
      return false;
    }
  }

  /// Get cached PDF bytes
  static Uint8List? getCachedPDF(String chapterId) {
    try {
      final cached = _pdfCacheBox.get(chapterId);
      if (cached == null) return null;

      // Check if cache is expired
      if (cached.isExpired()) {
        _pdfCacheBox.delete(chapterId);
        return null;
      }

      return cached.pdfData;
    } catch (e) {
      // Handle type errors or corrupted cache data
      print('Error getting cached PDF for $chapterId: $e');
      // Clear corrupted entry
      _pdfCacheBox.delete(chapterId);
      return null;
    }
  }

  /// Cache PDF bytes with metadata
  static Future<void> cachePDF(
    String chapterId,
    Uint8List pdfBytes, {
    String? fileName,
    String? chapterTitle,
  }) async {
    try {
      final cacheModel = PdfCacheModel.create(
        chapterId: chapterId,
        pdfData: pdfBytes,
        fileName: fileName ?? 'chapter_$chapterId.pdf',
        chapterTitle: chapterTitle,
      );

      await _pdfCacheBox.put(chapterId, cacheModel);
      print('PDF cached successfully for $chapterId');
    } catch (e) {
      print('Error caching PDF for $chapterId: $e');
      // If caching fails, we can still continue without cache
    }
  }

  /// Clear specific PDF from cache
  static Future<void> clearCachedPDF(String chapterId) async {
    try {
      await _pdfCacheBox.delete(chapterId);
    } catch (e) {
      print('Error clearing cache for $chapterId: $e');
    }
  }

  /// Clear all cached PDFs
  static Future<void> clearAllCache() async {
    try {
      await _pdfCacheBox.clear();
      print('All PDF cache cleared');
    } catch (e) {
      print('Error clearing all cache: $e');
    }
  }

  /// Clear corrupted cache entries (useful after app updates)
  static Future<void> clearCorruptedCache() async {
    try {
      final keysToDelete = <String>[];

      for (final key in _pdfCacheBox.keys) {
        try {
          final cached = _pdfCacheBox.get(key);
          if (cached == null) {
            keysToDelete.add(key.toString());
          }
        } catch (e) {
          // Mark corrupted entries for deletion
          keysToDelete.add(key.toString());
        }
      }

      for (final key in keysToDelete) {
        await _pdfCacheBox.delete(key);
      }

      if (keysToDelete.isNotEmpty) {
        print('Cleared ${keysToDelete.length} corrupted cache entries');
      }
    } catch (e) {
      print('Error clearing corrupted cache: $e');
    }
  }

  /// Get cache size in bytes
  static int getCacheSize() {
    int totalSize = 0;
    try {
      for (final cacheModel in _pdfCacheBox.values) {
        totalSize += cacheModel.fileSize;
      }
    } catch (e) {
      print('Error calculating cache size: $e');
    }
    return totalSize;
  }

  /// Get number of cached PDFs
  static int getCachedCount() {
    try {
      return _pdfCacheBox.length;
    } catch (e) {
      print('Error getting cache count: $e');
      return 0;
    }
  }

  /// Get cache information
  static Map<String, dynamic> getCacheInfo() {
    try {
      final count = getCachedCount();
      final size = getCacheSize();
      final sizeFormatted = _formatFileSize(size);

      final items = <Map<String, dynamic>>[];

      for (final model in _pdfCacheBox.values) {
        try {
          items.add({
            'chapterId': model.chapterId,
            'fileName': model.fileName,
            'fileSize': model.fileSizeFormatted,
            'cachedAt': model.cachedAt,
            'chapterTitle': model.chapterTitle,
          });
        } catch (e) {
          print('Error processing cache item: $e');
          // Skip corrupted items
        }
      }

      return {
        'count': count,
        'size': size,
        'sizeFormatted': sizeFormatted,
        'items': items,
      };
    } catch (e) {
      print('Error getting cache info: $e');
      return {
        'count': 0,
        'size': 0,
        'sizeFormatted': '0 B',
        'items': <Map<String, dynamic>>[],
      };
    }
  }

  /// Format file size to human readable format
  static String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Get download path - delegates to platform-specific implementation
  static Future<String?> getDownloadPath() async {
    if (kIsWeb) {
      // On web, we don't have a download path - downloads are handled by browser
      return null;
    }
    return platform.getDownloadPath();
  }

  /// Download PDF - delegates to platform-specific implementation
  static Future<bool> downloadPDF({
    required Uint8List pdfBytes,
    required String fileName,
    required BuildContext context,
  }) async {
    return platform.downloadPDF(
      pdfBytes: pdfBytes,
      fileName: fileName,
      context: context,
    );
  }

  /// Sanitize filename to remove invalid characters
  static String sanitizeFileName(String fileName) {
    // Remove or replace invalid characters for file names
    return fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
  }

  /// Get file size in human readable format
  static String getFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
