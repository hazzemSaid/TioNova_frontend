import 'package:equatable/equatable.dart';

class ChapterModel extends Equatable {
  final String id;
  final String? title;
  final String? description;
  final String? createdBy;
  final String? category;
  final String? createdAt;
  final String? quizStatus;
  final int? quizScore;
  final bool? quizCompleted;
  final String? summaryId;

  const ChapterModel({
    required this.id,
    this.summaryId,
    this.title,
    this.description,
    this.createdBy,
    this.category,
    this.createdAt,
    this.quizStatus,
    this.quizScore,
    this.quizCompleted,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      id: json['_id'],
      summaryId: json['summaryId'],
      title: json['title'],
      description: json['description'],
      createdBy: json['createdBy'],
      category: json['category'],
      createdAt: json['createdAt'],
      quizStatus: json['quizStatus'],
      quizScore: json['quizScore'],
      quizCompleted: json['quizCompleted'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'summaryId': summaryId,
      'title': title,
      'description': description,
      'createdBy': createdBy,
      'category': category,
      'createdAt': createdAt,
      'quizStatus': quizStatus,
      'quizScore': quizScore,
      'quizCompleted': quizCompleted,
    };
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    createdBy,
    category,
    createdAt,
    quizStatus,
    quizScore,
    summaryId,
    quizCompleted,
  ];

  @override
  bool get stringify => true;
}
