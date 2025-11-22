import 'package:equatable/equatable.dart';

class PreferencesModel extends Equatable {
  final String id;
  final int studyPerDay;
  final String preferredStudyTimes;
  final int dailyTimeCommitmentMinutes;
  final int daysPerWeek;
  final List<String> goals;
  final bool reminderEnabled;
  final List<String> reminderTimes;
  final String contentDifficulty;
  final String userId;

  const PreferencesModel({
    required this.id,
    required this.studyPerDay,
    required this.preferredStudyTimes,
    required this.dailyTimeCommitmentMinutes,
    required this.daysPerWeek,
    required this.goals,
    required this.reminderEnabled,
    required this.reminderTimes,
    required this.contentDifficulty,
    required this.userId,
  });
  //from json with safe parsing and defaults
  factory PreferencesModel.fromJson(Map<String, dynamic> json) =>
      PreferencesModel(
        id: json["_id"] ?? "",
        studyPerDay: (json["studyPerDay"] is int)
            ? json["studyPerDay"]
            : int.tryParse(json["studyPerDay"]?.toString() ?? "2") ?? 2,
        preferredStudyTimes:
            json["preferredStudyTimes"]?.toString() ?? "evening",
        dailyTimeCommitmentMinutes: (json["dailyTimeCommitmentMinutes"] is int)
            ? json["dailyTimeCommitmentMinutes"]
            : int.tryParse(
                    json["dailyTimeCommitmentMinutes"]?.toString() ?? "30",
                  ) ??
                  30,
        daysPerWeek: (json["daysPerWeek"] is int)
            ? json["daysPerWeek"]
            : int.tryParse(json["daysPerWeek"]?.toString() ?? "5") ?? 5,
        goals: (json["goals"] is List)
            ? List<String>.from(json["goals"])
            : <String>[],
        reminderEnabled: json["reminderEnabled"] == true,
        reminderTimes: (json["reminderTimes"] is List)
            ? List<String>.from(json["reminderTimes"])
            : <String>["09:00", "19:00"],
        contentDifficulty: json["contentDifficulty"]?.toString() ?? "medium",
        userId: json["userId"]?.toString() ?? "",
      );

  // to json - uses instance fields
  Map<String, dynamic> toJson() => {
    "studyPerDay": studyPerDay,
    "preferredStudyTimes": preferredStudyTimes,
    "dailyTimeCommitmentMinutes": dailyTimeCommitmentMinutes,
    "daysPerWeek": daysPerWeek,
    "goals": goals,
    "reminderEnabled": reminderEnabled,
    "reminderTimes": reminderTimes,
    "contentDifficulty": contentDifficulty,
  };
  @override
  List<Object?> get props => [
    id,
    studyPerDay,
    preferredStudyTimes,
    dailyTimeCommitmentMinutes,
    daysPerWeek,
    goals,
    reminderEnabled,
    reminderTimes,
    contentDifficulty,
    userId,
  ];
}
