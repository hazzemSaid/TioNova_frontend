import 'package:equatable/equatable.dart';

class UserQuizStatusModel extends Equatable {
  final List<Attempt> attempts;
  final String overallStatus;
  final int overallScore;
  final int totalAttempts;
  final int bestScore;
  final int averageScore;
  final int passRate;

  const UserQuizStatusModel({
    required this.attempts,
    required this.overallStatus,
    required this.overallScore,
    required this.totalAttempts,
    required this.bestScore,
    required this.averageScore,
    required this.passRate,
  });

  factory UserQuizStatusModel.fromJson(Map<String, dynamic> json) {
    final attemptsJson = (json['attempts'] as List?) ?? const [];
    final attemptsList = attemptsJson
        .where((e) => e != null)
        .map((e) => Attempt.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return UserQuizStatusModel(
      attempts: attemptsList,
      overallStatus: (json['overallStatus'] ?? '').toString(),
      overallScore: (json['overallScore'] ?? 0) as int,
      totalAttempts: (json['totalAttempts'] ?? 0) as int,
      bestScore: (json['bestScore'] ?? 0) as int,
      averageScore: (json['averageScore'] ?? 0) as int,
      passRate: (json['passRate'] ?? 0) as int,
    );
  }
  @override
  List<Object?> get props => [
    attempts,
    overallStatus,
    overallScore,
    totalAttempts,
    bestScore,
    averageScore,
    passRate,
  ];
  @override
  bool get stringify => true;
}

class Attempt extends Equatable {
  final DateTime startedAt;
  final DateTime completedAt;
  final int totalQuestions;
  final int correct;
  final int degree;
  final String state;
  final int? timeTaken;
  final List<Answer> answers;

  const Attempt({
    this.timeTaken,
    required this.startedAt,
    required this.completedAt,
    required this.totalQuestions,
    required this.correct,
    required this.degree,
    required this.state,
    required this.answers,
  });

  factory Attempt.fromJson(Map<String, dynamic> json) {
    final answersJson = (json['answers'] as List?) ?? const [];
    final answersList = answersJson
        .where((e) => e != null)
        .map((e) => Answer.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return Attempt(
      startedAt:
          DateTime.tryParse((json['startedAt'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      completedAt:
          DateTime.tryParse((json['completedAt'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      totalQuestions: (json['totalQuestions'] ?? 0) as int,
      correct: (json['correct'] ?? 0) as int,
      degree: (json['degree'] ?? 0) as int,
      state: (json['state'] ?? '').toString(),
      answers: answersList,
      timeTaken: (json['timeTaken'] as int?),
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [
    startedAt,
    completedAt,
    totalQuestions,
    correct,
    degree,
    state,
    timeTaken,
    answers,
  ];
  @override
  bool get stringify => true;
}

class Answer extends Equatable {
  final String? questionId;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String selectedOption;
  final bool isCorrect;
  final String? explanation;

  Answer({
    this.questionId,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.selectedOption,
    required this.isCorrect,
    this.explanation,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    final optionsFromJson = (json['options'] as List?) ?? const [];
    final optionsList = optionsFromJson
        .map((e) => e?.toString() ?? '')
        .toList()
        .cast<String>();

    return Answer(
      questionId: json['questionId']?.toString(),
      question: (json['question'] ?? '').toString(),
      options: optionsList,
      correctAnswer: (json['correctAnswer'] ?? '').toString(),
      selectedOption: (json['selectedOption'] ?? '').toString(),
      isCorrect: (json['isCorrect'] ?? false) as bool,
      explanation: (json['explanation'] ?? '').toString().isEmpty
          ? null
          : (json['explanation'] ?? '').toString(),
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [
    questionId,
    question,
    options,
    correctAnswer,
    selectedOption,
    isCorrect,
    explanation,
  ];
  @override
  bool get stringify => true;
}
