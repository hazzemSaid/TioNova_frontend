class StudyInsights {
  final int totalFolders;
  final double quizSuccessRate;
  final int totalChallengesTaken;

  StudyInsights({
    required this.totalFolders,
    required this.quizSuccessRate,
    required this.totalChallengesTaken,
  });

  factory StudyInsights.fromJson(Map<String, dynamic> json) {
    return StudyInsights(
      totalFolders: json['totalFolders'] as int,
      quizSuccessRate: (json['quizSuccessRate'] as num).toDouble(),
      totalChallengesTaken: json['totalChallengesTaken'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalFolders': totalFolders,
      'quizSuccessRate': quizSuccessRate,
      'totalChallengesTaken': totalChallengesTaken,
    };
  }
}
