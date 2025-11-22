import 'activity_log_model.dart';
import 'overview_model.dart';
import 'study_insights_model.dart';

class Profile {
  // User Info
  final String id;
  final String userId;
  final String username;
  final String email;
  final String? profilePicture;
  final String? universityCollege;
  final String role;
  final bool verified;
  final DateTime memberSince;

  // Stats
  final int streak;
  final DateTime lastActiveDate;
  final int totalQuizzesTaken;
  final int totalSuccessfulQuizzes;
  final double averageQuizScore;
  final int totalMindmapsCreated;
  final int totalSummariesCreated;
  final int totalFoldersCreated;
  final int totalChallengesParticipated;
  final int totalChapters;

  // Nested Data
  final List<ActivityLog> activityLogs;
  final Overview overview;
  final StudyInsights studyInsights;

  Profile({
    required this.id,
    required this.userId,
    required this.username,
    required this.email,
    this.profilePicture,
    this.universityCollege,
    required this.role,
    required this.verified,
    required this.memberSince,
    required this.streak,
    required this.lastActiveDate,
    required this.totalQuizzesTaken,
    required this.totalSuccessfulQuizzes,
    required this.averageQuizScore,
    required this.totalMindmapsCreated,
    required this.totalSummariesCreated,
    required this.totalFoldersCreated,
    required this.totalChallengesParticipated,
    required this.totalChapters,
    required this.activityLogs,
    required this.overview,
    required this.studyInsights,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['_id'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      profilePicture: json['profilePicture'] as String?,
      universityCollege: json['universityCollege'] as String?,
      role: json['role'] as String,
      verified: json['verified'] as bool,
      memberSince: DateTime.parse(json['memberSince'] as String),
      streak: json['streak'] as int,
      lastActiveDate: DateTime.parse(json['lastActiveDate'] as String),
      totalQuizzesTaken: json['totalQuizzesTaken'] as int,
      totalSuccessfulQuizzes: json['totalSuccessfulQuizzes'] as int,
      averageQuizScore: (json['averageQuizScore'] as num).toDouble(),
      totalMindmapsCreated: json['totalMindmapsCreated'] as int,
      totalSummariesCreated: json['totalSummariesCreated'] as int,
      totalFoldersCreated: json['totalFoldersCreated'] as int,
      totalChallengesParticipated: json['totalChallengesParticipated'] as int,
      totalChapters: json['totalChapters'] as int,
      activityLogs: (json['activityLogs'] as List<dynamic>)
          .map((e) => ActivityLog.fromJson(e as Map<String, dynamic>))
          .toList(),
      overview: Overview.fromJson(json['overview'] as Map<String, dynamic>),
      studyInsights: StudyInsights.fromJson(
        json['studyInsights'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'username': username,
      'email': email,
      'profilePicture': profilePicture,
      'universityCollege': universityCollege,
      'role': role,
      'verified': verified,
      'memberSince': memberSince.toIso8601String(),
      'streak': streak,
      'lastActiveDate': lastActiveDate.toIso8601String(),
      'totalQuizzesTaken': totalQuizzesTaken,
      'totalSuccessfulQuizzes': totalSuccessfulQuizzes,
      'averageQuizScore': averageQuizScore,
      'totalMindmapsCreated': totalMindmapsCreated,
      'totalSummariesCreated': totalSummariesCreated,
      'totalFoldersCreated': totalFoldersCreated,
      'totalChallengesParticipated': totalChallengesParticipated,
      'totalChapters': totalChapters,
      'activityLogs': activityLogs.map((e) => e.toJson()).toList(),
      'overview': overview.toJson(),
      'studyInsights': studyInsights.toJson(),
    };
  }
}
