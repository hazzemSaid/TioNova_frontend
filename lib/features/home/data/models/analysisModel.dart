/*{
    "success": true,
    "data": {
        "userId": "690d6b48a31e93b7cb81bfde",
        "recentChapters": [],
        "recentFolders": [
            {
                "_id": "690d7137a31e93b7cb81c009",
                "ownerId": "690d6b48a31e93b7cb81bfde",
                "sharedWith": [
                    {
                        "_id": "690bad9fb2434cecf5e750da",
                        "username": "hazem said",
                        "email": "haazemsaidd@gmail.com"
                    }
                ],
                "icon": "9",
                "color": "#34c759",
                "title": "mobile communications system",
                "category": "General",
                "description": "university",
                "status": "public",
                "createdAt": "2025-11-07T04:10:31.104Z",
                "updatedAt": "2025-11-07T04:10:31.104Z",
                "chapterCount": 0,
                "attemptedCount": 0,
                "passedCount": 0
            }
        ],
        "lastMindmaps": [],
        "lastSummary": null,
        "lastRank": 0,
        "totalChapters": 0,
        "avgScore": 0
    },
    "cached": false
}*/
import 'package:equatable/equatable.dart';
import 'package:tionova/features/folder/data/models/ChapterModel.dart';
import 'package:tionova/features/folder/data/models/SummaryModel.dart';
import 'package:tionova/features/folder/data/models/foldermodel.dart';
import 'package:tionova/features/folder/data/models/mindmapModel.dart';

class Analysismodel extends Equatable {
  final String userId;
  final List<ChapterModel>? recentChapters;
  final List<Foldermodel>? recentFolders;
  final List<Mindmapmodel>? lastMindmaps;
  final int? totalChapters;
  final SummaryModel? lastSummary;
  final double? avgScore;
  final int? lastRank;
  const Analysismodel({
    required this.userId,
    this.recentChapters,
    this.recentFolders,
    this.lastMindmaps,
    this.totalChapters,
    this.lastSummary,
    this.avgScore,
    this.lastRank,
  });
  //from json
  factory Analysismodel.fromJson(Map<String, dynamic> json) {
    return Analysismodel(
      userId: json['userId'],
      recentChapters: json['recentChapters'] != null
          ? (json['recentChapters'] as List)
                .map((e) => ChapterModel.fromJson(e))
                .toList()
          : null,
      recentFolders: json['recentFolders'] != null
          ? (json['recentFolders'] as List)
                .map((e) => Foldermodel.fromJson(e))
                .toList()
          : null,
      lastMindmaps: json['lastMindmaps'] != null
          ? (json['lastMindmaps'] as List)
                .map((e) => Mindmapmodel.fromJson(e))
                .toList()
          : null,
      totalChapters: json['totalChapters'] ?? 0,
      lastSummary: json['lastSummary'] != null
          ? SummaryModel.fromJson(json['lastSummary']['summary'])
          : null,
      avgScore: json['avgScore'] != null
          ? (json['avgScore'] as num).toDouble()
          : 0,
      lastRank: json['lastRank'] ?? 0,
    );
  }
  @override
  // TODO: implement props
  List<Object?> get props => [
    userId,
    recentChapters,
    recentFolders,
    lastMindmaps,
    totalChapters,
    lastSummary,
    avgScore,
    lastRank,
  ];
}
