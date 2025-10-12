import 'package:equatable/equatable.dart';
import 'package:tionova/features/folder/data/models/ShareWithmodel.dart';
import 'package:tionova/features/folder/domain/repo/IFolderRepository.dart';

class Foldermodel extends Equatable {
  final String id;
  final DateTime createdAt;
  final String ownerId;
  final List<ShareWithmodel>? sharedWith;
  final String? description;
  final String? icon;
  final String? color;
  final Status status;
  final String? category;
  final String title;
  final int? chapterCount;
  final int? attemptedCount;
  final int? passedCount;
  const Foldermodel({
    required this.passedCount,
    required this.attemptedCount,
    required this.id,
    required this.status,
    required this.createdAt,
    required this.ownerId,
    this.sharedWith,
    this.description,
    this.category,
    this.icon,
    this.color,
    required this.title,
    this.chapterCount,
  });

  factory Foldermodel.fromJson(Map<String, dynamic> json) {
    return Foldermodel(
      passedCount: json['passedCount'],
      attemptedCount: json['attemptedCount'],
      id: json['_id'] ?? json['id'],
      icon: json['icon'],
      color: json['color'],
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'])
          : json['createdAt'] as DateTime,
      ownerId: json['ownerId'],
      sharedWith: (json['sharedWith'] != null && json['status'] != "private")
          ? List<ShareWithmodel>.from(
              (json['sharedWith'] as List).map(
                (x) => ShareWithmodel.fromJson(x),
              ),
            )
          : [],
      description: json['description'],
      category: json['category'],
      title: json['title'],
      chapterCount: json['chapterCount'],
      status: Status.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'createdAt': createdAt.toIso8601String(),
      'ownerId': ownerId,
      'sharedWith': sharedWith,
      'description': description,
      'category': category,
      'title': title,
      'icon': icon,
      'color': color,
      'chapterCount': chapterCount,
      'status': status.toString().split('.').last,
    };
  }

  @override
  List<Object?> get props => [
    id,
    createdAt,
    ownerId,
    sharedWith,
    description,
    category,
    title,
    chapterCount,
    status,
    icon,
    color,
    attemptedCount,
    passedCount,
  ];
  @override
  String toString() {
    return 'Foldermodel(id: $id, createdAt: $createdAt, ownerId: $ownerId, sharedWith: $sharedWith, description: $description, category: $category, title: $title, chapterCount: $chapterCount, status: $status )';
  }

  copyWith({
    DateTime? createdAt,
    String? ownerId,
    List<ShareWithmodel>? sharedWith,
    String? description,
    String? icon,
    String? color,
    Status? status,
    String? category,
    String? title,
    int? chapterCount,
    int? passedCount,
    int? attemptedCount,
  }) {
    return Foldermodel(
      id: id,
      createdAt: createdAt ?? this.createdAt,
      ownerId: ownerId ?? this.ownerId,
      sharedWith: sharedWith ?? this.sharedWith,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      status: status ?? this.status,
      category: category ?? this.category,
      title: title ?? this.title,
      chapterCount: chapterCount ?? this.chapterCount,
      passedCount: passedCount ?? this.passedCount,
      attemptedCount: attemptedCount ?? this.attemptedCount,
    );
  }
}
