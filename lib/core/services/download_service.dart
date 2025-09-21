import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tionova/core/models/pdf_cache_model.dart';

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

  static Future<String?> getDownloadPath() async {
    try {
      if (Platform.isAndroid) {
        // Try to get the Downloads directory

        // First try to get external storage directory
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          // Navigate to Downloads folder
          final downloadPath = Directory('/storage/emulated/0/Download');
          if (await downloadPath.exists()) {
            return downloadPath.path;
          }

          // Fallback to creating Downloads in external storage
          final fallbackPath = Directory('${externalDir.path}/Downloads');
          if (!await fallbackPath.exists()) {
            await fallbackPath.create(recursive: true);
          }
          return fallbackPath.path;
        }

        // Last resort: use app documents directory
        final appDocDir = await getApplicationDocumentsDirectory();
        final downloadDir = Directory('${appDocDir.path}/Downloads');
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }
        return downloadDir.path;
      } else if (Platform.isIOS) {
        final appDocDir = await getApplicationDocumentsDirectory();
        return appDocDir.path;
      }
    } catch (e) {
      print('Error getting download path: $e');
    }
    return null;
  }

  static Future<bool> downloadPDF({
    required Uint8List pdfBytes,
    required String fileName,
    required BuildContext context,
  }) async {
    try {
      // Get download path
      final downloadPath = await getDownloadPath();
      if (downloadPath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to access download directory'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }

      // Ensure fileName has .pdf extension
      String finalFileName = fileName;
      if (!fileName.toLowerCase().endsWith('.pdf')) {
        finalFileName = '$fileName.pdf';
      }

      // Create unique filename if file already exists
      String fullPath = '$downloadPath/$finalFileName';
      int counter = 1;
      while (await File(fullPath).exists()) {
        final nameWithoutExt = finalFileName.replaceAll('.pdf', '');
        finalFileName = '${nameWithoutExt}_$counter.pdf';
        fullPath = '$downloadPath/$finalFileName';
        counter++;
      }

      // Write file
      final file = File(fullPath);
      await file.writeAsBytes(pdfBytes);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF downloaded: $finalFileName'),
          backgroundColor: Colors.green,
        ),
      );

      return true;
    } catch (e) {
      print('Error downloading PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
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
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
