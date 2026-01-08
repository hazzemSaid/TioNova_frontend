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
  final String? folderId;
  final String? mindmapId;

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
    this.folderId,
    this.mindmapId,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      summaryId: json['summaryId']?.toString(),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      createdBy: json['createdBy']?.toString(),
      category: json['category']?.toString(),
      createdAt: json['createdAt']?.toString(),
      quizStatus: json['quizStatus']?.toString(),
      quizScore: json['quizScore'] is int
          ? json['quizScore'] as int
          : (int.tryParse(json['quizScore']?.toString() ?? '0') ?? 0),
      quizCompleted: json['quizCompleted'] is bool
          ? json['quizCompleted'] as bool
          : (json['quizCompleted']?.toString().toLowerCase() == 'true'),
      folderId: json['folderId']?.toString(),
      mindmapId: json['mindmapId']?.toString(),
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
      'folderId': folderId,
      'mindmapId': mindmapId,
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
    folderId,
    mindmapId,
  ];

  @override
  bool get stringify => true;
}
