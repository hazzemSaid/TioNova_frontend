import 'package:equatable/equatable.dart';
import 'package:tionova/features/quiz/data/models/PracticeQuestionModel.dart';

/// Model for Practice Mode quiz containing 30 questions with answers and explanations
/// Response from POST /api/v1/practicemode endpoint
class PracticeModeQuizModel extends Equatable {
  final String id;
  final String title;
  final int totalQuestions;
  final List<PracticeQuestionModel> questions;

  const PracticeModeQuizModel({
    required this.id,
    required this.title,
    required this.totalQuestions,
    required this.questions,
  });

  factory PracticeModeQuizModel.fromJson(Map<String, dynamic> json) {
    final quizData = json['quiz'] as Map<String, dynamic>;

    return PracticeModeQuizModel(
      id: quizData['_id'] as String,
      title: quizData['title'] as String,
      totalQuestions: json['totalQuestions'] as int,
      questions: (quizData['questions'] as List)
          .map((q) => PracticeQuestionModel.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quiz': {
        '_id': id,
        'title': title,
        'questions': questions.map((q) => q.toJson()).toList(),
      },
      'totalQuestions': totalQuestions,
    };
  }

  @override
  List<Object?> get props => [id, title, totalQuestions, questions];

  @override
  String toString() {
    return 'PracticeModeQuizModel(id: $id, title: $title, totalQuestions: $totalQuestions, questions: ${questions.length})';
  }
}
