import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:tionova/features/folder/data/models/SummaryModel.dart';

part 'summary_cache_model.g.dart';

@HiveType(typeId: 2)
class SummaryCacheModel extends HiveObject {
  @HiveField(0)
  final String chapterId;

  @HiveField(1)
  final String summaryDataJson;

  @HiveField(2)
  final DateTime cachedAt;

  @HiveField(3)
  final String? chapterTitle;

  SummaryCacheModel({
    required this.chapterId,
    required this.summaryDataJson,
    required this.cachedAt,
    this.chapterTitle,
  });

  factory SummaryCacheModel.create({
    required String chapterId,
    required SummaryModel summaryData,
    String? chapterTitle,
  }) {
    return SummaryCacheModel(
      chapterId: chapterId,
      summaryDataJson: jsonEncode(summaryData.toJson()),
      cachedAt: DateTime.now(),
      chapterTitle: chapterTitle,
    );
  }

  // Convert back to SummaryModel
  SummaryModel get summaryData {
    final jsonData = jsonDecode(summaryDataJson) as Map<String, dynamic>;
    return SummaryModel.fromJson(jsonData);
  }

  // Helper method to check if cache is older than specified duration
  bool isExpired({Duration maxAge = const Duration(days: 7)}) {
    return DateTime.now().difference(cachedAt) > maxAge;
  }

  // Get formatted age of cache
  String get cacheAge {
    final age = DateTime.now().difference(cachedAt);
    if (age.inDays > 0) {
      return '${age.inDays} day${age.inDays == 1 ? '' : 's'} ago';
    } else if (age.inHours > 0) {
      return '${age.inHours} hour${age.inHours == 1 ? '' : 's'} ago';
    } else if (age.inMinutes > 0) {
      return '${age.inMinutes} minute${age.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  String toString() {
    return 'SummaryCacheModel(chapterId: $chapterId, chapterTitle: $chapterTitle, cachedAt: $cachedAt)';
  }
}
