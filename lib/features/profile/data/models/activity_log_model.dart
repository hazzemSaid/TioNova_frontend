class ActivityLog {
  final DateTime date;
  final List<String> chaptersStudied;
  final int quizzesCompleted;
  final int timeSpentMinutes;
  final int challengesParticipated;

  ActivityLog({
    required this.date,
    required this.chaptersStudied,
    required this.quizzesCompleted,
    required this.timeSpentMinutes,
    required this.challengesParticipated,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      date: DateTime.parse(json['date'] as String),
      chaptersStudied: (json['chaptersStudied'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      quizzesCompleted: json['quizzesCompleted'] as int,
      timeSpentMinutes: json['timeSpentMinutes'] as int,
      challengesParticipated: json['challengesParticipated'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'chaptersStudied': chaptersStudied,
      'quizzesCompleted': quizzesCompleted,
      'timeSpentMinutes': timeSpentMinutes,
      'challengesParticipated': challengesParticipated,
    };
  }
}
