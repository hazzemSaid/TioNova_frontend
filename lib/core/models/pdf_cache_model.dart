import 'dart:typed_data';

import 'package:hive/hive.dart';

part 'pdf_cache_model.g.dart';

@HiveType(typeId: 0)
class PdfCacheModel extends HiveObject {
  @HiveField(0)
  final String chapterId;

  @HiveField(1)
  final Uint8List pdfData;

  @HiveField(2)
  final String fileName;

  @HiveField(3)
  final int fileSize;

  @HiveField(4)
  final DateTime cachedAt;

  @HiveField(5)
  final String? chapterTitle;

  PdfCacheModel({
    required this.chapterId,
    required this.pdfData,
    required this.fileName,
    required this.fileSize,
    required this.cachedAt,
    this.chapterTitle,
  });

  factory PdfCacheModel.create({
    required String chapterId,
    required Uint8List pdfData,
    required String fileName,
    String? chapterTitle,
  }) {
    return PdfCacheModel(
      chapterId: chapterId,
      pdfData: pdfData,
      fileName: fileName,
      fileSize: pdfData.length,
      cachedAt: DateTime.now(),
      chapterTitle: chapterTitle,
    );
  }

  // Helper method to check if cache is older than specified duration
  bool isExpired({Duration maxAge = const Duration(days: 7)}) {
    return DateTime.now().difference(cachedAt) > maxAge;
  }

  // Convert file size to human readable format
  String get fileSizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024)
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  String toString() {
    return 'PdfCacheModel(chapterId: $chapterId, fileName: $fileName, fileSize: $fileSizeFormatted, cachedAt: $cachedAt)';
  }
}
