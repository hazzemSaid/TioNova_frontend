import 'package:equatable/equatable.dart';
import 'package:tionova/features/quiz/data/models/QestionsModel.dart';

class QuizModel extends Equatable {
  final String id;
  final String title;
  final int totalQuestions;
  final List<QuestionModel> questions;

  QuizModel({
    required this.id,
    required this.title,
    required this.totalQuestions,
    required this.questions,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['_id'],
      title: json['title'],
      totalQuestions: json['totalQuestions'],
      questions: List<QuestionModel>.from(
        json['questions'].map((x) => QuestionModel.fromJson(x)),
      ),
    );
  }

  @override
  List<Object?> get props => [id, title, totalQuestions, questions];

  @override
  String toString() {
    return 'QuizModel(id: $id, title: $title, totalQuestions: $totalQuestions, questions: $questions)';
  }

  QuizModel copyWith({
    String? id,
    String? title,
    int? totalQuestions,
    List<QuestionModel>? questions,
  }) {
    return QuizModel(
      id: id ?? this.id,
      title: title ?? this.title,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      questions: questions ?? this.questions,
    );
  }
}
