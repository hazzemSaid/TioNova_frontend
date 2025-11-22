class OverviewPeriod {
  final int chapters;
  final int quizzes;

  OverviewPeriod({required this.chapters, required this.quizzes});

  factory OverviewPeriod.fromJson(Map<String, dynamic> json) {
    return OverviewPeriod(
      chapters: json['chapters'] as int,
      quizzes: json['quizzes'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'chapters': chapters, 'quizzes': quizzes};
  }
}

class Overview {
  final OverviewPeriod today;
  final OverviewPeriod thisMonth;

  Overview({required this.today, required this.thisMonth});

  factory Overview.fromJson(Map<String, dynamic> json) {
    return Overview(
      today: OverviewPeriod.fromJson(json['today'] as Map<String, dynamic>),
      thisMonth: OverviewPeriod.fromJson(
        json['thisMonth'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'today': today.toJson(), 'thisMonth': thisMonth.toJson()};
  }
}
