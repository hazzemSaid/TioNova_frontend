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

class ProfileModel extends Equatable {
  final int streak;
  final String? lastActiveDate;
  final int totalQuizzesTaken;
  final int totalMindmapsCreated;
  final int totalSummariesCreated;
  final double averageQuizScore;

  const ProfileModel({
    required this.streak,
    this.lastActiveDate,
    required this.totalQuizzesTaken,
    required this.totalMindmapsCreated,
    required this.totalSummariesCreated,
    required this.averageQuizScore,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      streak: json['streak'] ?? 0,
      lastActiveDate: json['lastActiveDate'],
      totalQuizzesTaken: json['totalQuizzesTaken'] ?? 0,
      totalMindmapsCreated: json['totalMindmapsCreated'] ?? 0,
      totalSummariesCreated: json['totalSummariesCreated'] ?? 0,
      averageQuizScore: json['averageQuizScore'] != null
          ? (json['averageQuizScore'] as num).toDouble()
          : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'streak': streak,
      'lastActiveDate': lastActiveDate,
      'totalQuizzesTaken': totalQuizzesTaken,
      'totalMindmapsCreated': totalMindmapsCreated,
      'totalSummariesCreated': totalSummariesCreated,
      'averageQuizScore': averageQuizScore,
    };
  }

  @override
  List<Object?> get props => [
    streak,
    lastActiveDate,
    totalQuizzesTaken,
    totalMindmapsCreated,
    totalSummariesCreated,
    averageQuizScore,
  ];
}

class Analysismodel extends Equatable {
  final String userId;
  final List<ChapterModel>? recentChapters;
  final List<Foldermodel>? recentFolders;
  final List<Mindmapmodel>? lastMindmaps;
  final int? totalChapters;
  final SummaryModel? lastSummary;
  final double? avgScore;
  final int? lastRank;
  final ProfileModel? profile;
  const Analysismodel({
    required this.userId,
    this.recentChapters,
    this.recentFolders,
    this.lastMindmaps,
    this.totalChapters,
    this.lastSummary,
    this.avgScore,
    this.lastRank,
    this.profile,
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
      profile: json['profile'] != null
          ? ProfileModel.fromJson(json['profile'])
          : null,
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
    profile,
  ];
}
