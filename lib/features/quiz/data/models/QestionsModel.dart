/*_id
68d29211beabb53e331a39ee
quizId
68d29211beabb53e331a39ec
question
"In agile processes, is planning incremental, and is it easier to chang…"

options
Array (4)
answer
"a"
createdAt
2025-09-23T12:26:57.451+00:00
updatedAt
2025-09-23T12:26:57.451+00:00
__v
0*/
import 'package:equatable/equatable.dart';

class QuestionModel extends Equatable {
  final String id;
  final String question;
  final List<String> options;
  final String answer;

  QuestionModel({
    required this.id,
    required this.question,
    required this.options,
    required this.answer,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['_id'],
      question: json['question'],
      options: List<String>.from(json['options']),
      answer: json['answer'],
    );
  }

  @override
  List<Object?> get props => [id, question, options, answer];

  @override
  String toString() {
    return 'QuestionModel(id: $id, question: $question, options: $options, answer: $answer)';
  }

  QuestionModel copyWith({
    String? id,
    String? question,
    List<String>? options,
    String? answer,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
      answer: answer ?? this.answer,
    );
  }
}
