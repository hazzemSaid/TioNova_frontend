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
import 'package:tionova/features/folder/data/models/mindmapmodel.dart';

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
      streak: json['streak'] is int
          ? json['streak']
          : (int.tryParse(json['streak']?.toString() ?? '0') ?? 0),
      lastActiveDate: json['lastActiveDate']?.toString(),
      totalQuizzesTaken: json['totalQuizzesTaken'] is int
          ? json['totalQuizzesTaken']
          : (int.tryParse(json['totalQuizzesTaken']?.toString() ?? '0') ?? 0),
      totalMindmapsCreated: json['totalMindmapsCreated'] is int
          ? json['totalMindmapsCreated']
          : (int.tryParse(json['totalMindmapsCreated']?.toString() ?? '0') ??
                0),
      totalSummariesCreated: json['totalSummariesCreated'] is int
          ? json['totalSummariesCreated']
          : (int.tryParse(json['totalSummariesCreated']?.toString() ?? '0') ??
                0),
      averageQuizScore: json['averageQuizScore'] is num
          ? (json['averageQuizScore'] as num).toDouble()
          : (double.tryParse(json['averageQuizScore']?.toString() ?? '0.0') ??
                0.0),
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

class TodayProgressPreferences extends Equatable {
  final int studyPerDay;
  final String preferredStudyTimes;
  final int dailyTimeCommitmentMinutes;
  final int daysPerWeek;
  final List<String> goals;
  final bool reminderEnabled;
  final List<String> reminderTimes;
  final String contentDifficulty;

  const TodayProgressPreferences({
    required this.studyPerDay,
    required this.preferredStudyTimes,
    required this.dailyTimeCommitmentMinutes,
    required this.daysPerWeek,
    required this.goals,
    required this.reminderEnabled,
    required this.reminderTimes,
    required this.contentDifficulty,
  });

  factory TodayProgressPreferences.fromJson(Map<String, dynamic> json) {
    return TodayProgressPreferences(
      studyPerDay: json['studyPerDay'] ?? 0,
      preferredStudyTimes: json['preferredStudyTimes'] ?? '',
      dailyTimeCommitmentMinutes: json['dailyTimeCommitmentMinutes'] ?? 0,
      daysPerWeek: json['daysPerWeek'] ?? 0,
      goals: json['goals'] != null
          ? List<String>.from(json['goals'])
          : const [],
      reminderEnabled: json['reminderEnabled'] ?? false,
      reminderTimes: json['reminderTimes'] != null
          ? List<String>.from(json['reminderTimes'])
          : const [],
      contentDifficulty: json['contentDifficulty'] ?? 'medium',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studyPerDay': studyPerDay,
      'preferredStudyTimes': preferredStudyTimes,
      'dailyTimeCommitmentMinutes': dailyTimeCommitmentMinutes,
      'daysPerWeek': daysPerWeek,
      'goals': goals,
      'reminderEnabled': reminderEnabled,
      'reminderTimes': reminderTimes,
      'contentDifficulty': contentDifficulty,
    };
  }

  @override
  List<Object?> get props => [
    studyPerDay,
    preferredStudyTimes,
    dailyTimeCommitmentMinutes,
    daysPerWeek,
    goals,
    reminderEnabled,
    reminderTimes,
    contentDifficulty,
  ];
}

class TodayProgressActual extends Equatable {
  final int chapters;
  final int quizzes;

  const TodayProgressActual({required this.chapters, required this.quizzes});

  factory TodayProgressActual.fromJson(Map<String, dynamic> json) {
    return TodayProgressActual(
      chapters: json['chapters'] ?? 0,
      quizzes: json['quizzes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'chapters': chapters, 'quizzes': quizzes};
  }

  @override
  List<Object?> get props => [chapters, quizzes];
}

class TodayProgressModel extends Equatable {
  final int current;
  final int target;
  final int percentage;
  final TodayProgressPreferences preferences;
  final TodayProgressActual actual;

  const TodayProgressModel({
    required this.current,
    required this.target,
    required this.percentage,
    required this.preferences,
    required this.actual,
  });

  factory TodayProgressModel.fromJson(Map<String, dynamic> json) {
    return TodayProgressModel(
      current: json['current'] ?? 0,
      target: json['target'] ?? 0,
      percentage: json['percentage'] ?? 0,
      preferences: json['preferences'] != null
          ? TodayProgressPreferences.fromJson(json['preferences'])
          : const TodayProgressPreferences(
              studyPerDay: 0,
              preferredStudyTimes: '',
              dailyTimeCommitmentMinutes: 0,
              daysPerWeek: 0,
              goals: [],
              reminderEnabled: false,
              reminderTimes: [],
              contentDifficulty: 'medium',
            ),
      actual: json['actual'] != null
          ? TodayProgressActual.fromJson(json['actual'])
          : const TodayProgressActual(chapters: 0, quizzes: 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current': current,
      'target': target,
      'percentage': percentage,
      'preferences': preferences.toJson(),
      'actual': actual.toJson(),
    };
  }

  @override
  List<Object?> get props => [current, target, percentage, preferences, actual];
}

class Analysismodel extends Equatable {
  final String userId;
  final List<ChapterModel>? recentChapters;
  final List<Foldermodel>? recentFolders;
  final List<Mindmapmodel>? lastMindmaps;
  final int? totalChapters;
  final SummaryModelData?
  lastSummary; // Changed from SummaryModel to SummaryModelData
  final double? avgScore;
  final int? lastRank;
  final ProfileModel? profile;
  final TodayProgressModel? todayProgress;
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
    this.todayProgress,
  });
  //from json
  factory Analysismodel.fromJson(Map<String, dynamic> json) {
    return Analysismodel(
      userId: json['userId']?.toString() ?? '',
      recentChapters: json['recentChapters'] is List
          ? (json['recentChapters'] as List)
                .where((e) => e != null && e is Map<String, dynamic>)
                .map((e) => ChapterModel.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
      recentFolders: json['recentFolders'] is List
          ? (json['recentFolders'] as List)
                .where((e) => e != null && e is Map<String, dynamic>)
                .map((e) => Foldermodel.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
      lastMindmaps: json['lastMindmaps'] is List
          ? (json['lastMindmaps'] as List)
                .where((e) => e != null && e is Map<String, dynamic>)
                .map((e) => Mindmapmodel.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
      totalChapters: json['totalChapters'] is int
          ? json['totalChapters']
          : (int.tryParse(json['totalChapters']?.toString() ?? '0') ?? 0),
      lastSummary:
          json['lastSummary'] != null &&
              json['lastSummary'] is Map<String, dynamic>
          ? SummaryModelData.fromJson(
              json['lastSummary'] as Map<String, dynamic>,
            )
          : null,
      avgScore: json['avgScore'] is num
          ? (json['avgScore'] as num).toDouble()
          : (double.tryParse(json['avgScore']?.toString() ?? '0.0') ?? 0.0),
      lastRank: json['lastRank'] is int
          ? json['lastRank']
          : (int.tryParse(json['lastRank']?.toString() ?? '0') ?? 0),
      profile:
          json['profile'] != null && json['profile'] is Map<String, dynamic>
          ? ProfileModel.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
      todayProgress:
          json['todayProgress'] != null &&
              json['todayProgress'] is Map<String, dynamic>
          ? TodayProgressModel.fromJson(
              json['todayProgress'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
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
    todayProgress,
  ];
}
