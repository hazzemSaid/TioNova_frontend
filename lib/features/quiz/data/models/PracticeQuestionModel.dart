import 'package:equatable/equatable.dart';

/// Model for practice mode questions that includes answer and explanation
/// Unlike regular QuestionModel, this contains the correct answer and explanation
/// for immediate feedback during practice sessions
class PracticeQuestionModel extends Equatable {
  final String id;
  final String question;
  final List<String> options;
  final String answer; // Correct answer letter (a, b, c, d)
  final String explanation; // Explanation for the correct answer

  const PracticeQuestionModel({
    required this.id,
    required this.question,
    required this.options,
    required this.answer,
    required this.explanation,
  });

  factory PracticeQuestionModel.fromJson(Map<String, dynamic> json) {
    return PracticeQuestionModel(
      id: json['_id'] as String,
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      answer: json['answer'] as String,
      explanation: json['explanation'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'question': question,
      'options': options,
      'answer': answer,
      'explanation': explanation,
    };
  }

  @override
  List<Object?> get props => [id, question, options, answer, explanation];

  @override
  String toString() {
    return 'PracticeQuestionModel(id: $id, question: $question, options: $options, answer: $answer, explanation: $explanation)';
  }
}
