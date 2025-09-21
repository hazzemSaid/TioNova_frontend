import 'package:equatable/equatable.dart';
import 'package:tionova/features/folder/domain/repo/IFolderRepository.dart';

class Foldermodel extends Equatable {
  final String id;
  final DateTime createdAt;
  final String ownerId;
  final List<dynamic>? sharedWith;
  final String? description;
  final String? icon;
  final String? color;
  final Status status;
  final String? category;
  final String title;
  final int? chapterCount;
  const Foldermodel({
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
      id: json['_id'] ?? json['id'],
      icon: json['icon'],
      color: json['color'],
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'])
          : json['createdAt'] as DateTime,
      ownerId: json['ownerId'],
      sharedWith: json['sharedWith'],
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
  ];
  @override
  String toString() {
    return 'Foldermodel(id: $id, createdAt: $createdAt, ownerId: $ownerId, sharedWith: $sharedWith, description: $description, category: $category, title: $title, chapterCount: $chapterCount, status: $status )';
  }

  copyWith({
    DateTime? createdAt,
    String? ownerId,
    List<dynamic>? sharedWith,
    String? description,
    String? icon,
    String? color,
    Status? status,
    String? category,
    String? title,
    int? chapterCount,
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
    );
  }
}

/*  "_id": "68c7fc64cfbd31d609c6e006",
            "ownerId": "68c3d742811330274418c411",
            "sharedWith": [],
            "title": "first  file",
            "description": "fire file des",
            "status": "private",
            "createdAt": "2025-09-15T11:45:40.398Z",
            "updatedAt": "2025-09-15T11:45:40.398Z",
            "__v": 0,
            "chapterCount": 0*/
