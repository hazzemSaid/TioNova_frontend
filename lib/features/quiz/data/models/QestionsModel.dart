import 'package:equatable/equatable.dart';

/*{
                "_id": "68d54371cde61c0e5385d994",
                "question": "What does software reuse involve?",
                "options": [
                    "a) Analyzing software to recover its design and specification",
                    "b) Using existing software artifacts and knowledge to build new software",
                    "c) Creating a representation of a higher level of abstraction",
                    "d) Breaking software down to see how it works"
                ],
                "createdAt": "2025-09-25T13:28:17.960Z",
                "updatedAt": "2025-09-25T13:28:17.960Z"
            },*/
class QuestionModel extends Equatable {
  final String id;
  final String question;
  final List<String> options;
  QuestionModel({
    required this.id,
    required this.question,
    required this.options,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['_id'],
      question: json['question'],
      options: List<String>.from(json['options']),
    );
  }

  @override
  List<Object?> get props => [id, question, options];

  @override
  String toString() {
    return 'QuestionModel(id: $id, question: $question, options: $options, , )';
  }

  QuestionModel copyWith({
    String? id,
    String? question,
    List<String>? options,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
    );
  }
}
