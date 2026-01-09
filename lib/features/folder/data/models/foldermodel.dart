import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:tionova/features/chapter/data/models/ShareWithmodel.dart';
import 'package:tionova/features/folder/domain/repo/IFolderRepository.dart';

class OwnerModel extends Equatable {
  final String id;
  final String username;
  final String email;
  final String? profilePicture;

  const OwnerModel({
    required this.id,
    required this.username,
    required this.email,
    this.profilePicture,
  });

  factory OwnerModel.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return OwnerModel(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        username: (json['username'] ?? '').toString(),
        email: (json['email'] ?? '').toString(),
        profilePicture: json['profilePicture']?.toString(),
      );
    }
    // Fallback if backend returns just an ID or incorrect type
    return OwnerModel(
      id: json?.toString() ?? '',
      username: '',
      email: '',
      profilePicture: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'email': email,
      'profilePicture': profilePicture,
    };
  }

  @override
  List<Object?> get props => [id, username, email, profilePicture];
}

class Foldermodel extends Equatable {
  final String id;
  final DateTime createdAt;
  final OwnerModel owner;
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
    required this.owner,
    this.sharedWith,
    this.description,
    this.category,
    this.icon,
    this.color,
    required this.title,
    this.chapterCount,
  });

  factory Foldermodel.fromJson(Map<String, dynamic> json) {
    // Parse sharedWith list safely
    List<ShareWithmodel> parsedSharedWith = [];
    if (json['sharedWith'] != null &&
        json['status'] != "private" &&
        json['sharedWith'] is List) {
      try {
        parsedSharedWith = (json['sharedWith'] as List)
            .where((x) => x != null)
            .map((x) {
              if (x is Map<String, dynamic>) {
                return ShareWithmodel.fromJson(x);
              } else {
                return ShareWithmodel.fromJson({'_id': x.toString()});
              }
            })
            .toList();
      } catch (e) {
        debugPrint('⚠️ [Foldermodel.fromJson] Error parsing sharedWith: $e');
        parsedSharedWith = [];
      }
    }

    DateTime parsedDate;
    try {
      if (json['createdAt'] is String) {
        parsedDate = DateTime.parse(json['createdAt'] as String);
      } else if (json['createdAt'] is DateTime) {
        parsedDate = json['createdAt'] as DateTime;
      } else {
        parsedDate = DateTime.now();
        debugPrint(
          '⚠️ [Foldermodel.fromJson] Invalid createdAt type: ${json['createdAt']?.runtimeType}',
        );
      }
    } catch (e) {
      parsedDate = DateTime.now();
      debugPrint('⚠️ [Foldermodel.fromJson] Error parsing createdAt: $e');
    }

    // Parse owner object with graceful fallback to ownerId
    OwnerModel parsedOwner;
    try {
      if (json['owner'] != null) {
        parsedOwner = OwnerModel.fromJson(json['owner']);
      } else if (json['ownerId'] != null) {
        parsedOwner = OwnerModel.fromJson({'_id': json['ownerId']});
      } else {
        parsedOwner = const OwnerModel(id: '', username: '', email: '');
      }
    } catch (e) {
      debugPrint('⚠️ [Foldermodel.fromJson] Error parsing owner: $e');
      parsedOwner = const OwnerModel(id: '', username: '', email: '');
    }

    return Foldermodel(
      passedCount: json['passedCount'] is int
          ? json['passedCount'] as int
          : (int.tryParse(json['passedCount']?.toString() ?? '0') ?? 0),
      attemptedCount: json['attemptedCount'] is int
          ? json['attemptedCount'] as int
          : (int.tryParse(json['attemptedCount']?.toString() ?? '0') ?? 0),
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      icon: json['icon']?.toString(),
      color: json['color']?.toString(),
      createdAt: parsedDate,
      owner: parsedOwner,
      sharedWith: parsedSharedWith,
      description: json['description']?.toString(),
      category: json['category']?.toString(),
      title: (json['title'] ?? '').toString(),
      chapterCount: json['chapterCount'] is int
          ? json['chapterCount'] as int
          : (int.tryParse(json['chapterCount']?.toString() ?? '0') ?? 0),
      status: Status.values.firstWhere(
        (e) => e.toString().split('.').last == (json['status']?.toString()),
        orElse: () => Status.private,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'createdAt': createdAt.toIso8601String(),
      'owner': owner.toJson(),
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

  // Backward-compatible getter for existing code that reads ownerId
  String get ownerId => owner.id;

  @override
  List<Object?> get props => [
    id,
    createdAt,
    owner,
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
    return 'Foldermodel(id: $id, createdAt: $createdAt, owner: ${owner.toJson()}, sharedWith: $sharedWith, description: $description, category: $category, title: $title, chapterCount: $chapterCount, status: $status )';
  }

  copyWith({
    DateTime? createdAt,
    OwnerModel? owner,
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
      owner: owner ?? this.owner,
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
