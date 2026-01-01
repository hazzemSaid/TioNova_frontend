import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

// Conditional imports for platform-specific functionality
import 'download_service_stub.dart'
    if (dart.library.io) 'download_service_io.dart'
    as platform;

class DownloadService {
  /// Initialize the download service
  static Future<void> initialize() async {
    print('DownloadService initialized successfully');
  }

  /// Check if PDF is already cached (always false on web)
  static bool isPDFCached(String chapterId) {
    if (kIsWeb) return false;
    // No caching on any platform for now
    return false;
  }

  /// Get cached PDF bytes (always null on web)
  static Uint8List? getCachedPDF(String chapterId) {
    if (kIsWeb) return null;
    // No caching on any platform for now
    return null;
  }

  /// Cache PDF bytes (no-op on web)
  static Future<void> cachePDF(
    String chapterId,
    Uint8List pdfBytes, {
    String? fileName,
    String? chapterTitle,
  }) async {
    if (kIsWeb) return;
    // No caching on any platform for now
  }

  /// Clear specific PDF from cache (no-op on web)
  static Future<void> clearCachedPDF(String chapterId) async {
    if (kIsWeb) return;
    // No caching on any platform for now
  }

  /// Clear all cached PDFs (no-op on web)
  static Future<void> clearAllCache() async {
    if (kIsWeb) return;
    // No caching on any platform for now
  }

  /// Get download path - delegates to platform-specific implementation
  static Future<String?> getDownloadPath() async {
    if (kIsWeb) {
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
