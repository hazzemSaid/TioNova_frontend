import 'package:equatable/equatable.dart';

class Notemodel extends Equatable {
  final String id;
  final String title;
  final String chapterId;
  final String createdBy;
  final String? creatorName;
  final String? creatorEmail;
  final Map<String, dynamic> rawData;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Notemodel({
    required this.id,
    required this.title,
    required this.chapterId,
    required this.createdBy,
    this.creatorName,
    this.creatorEmail,
    required this.rawData,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Notemodel.fromJson(Map<String, dynamic> json) {
    // Handle createdBy - it can be either a string ID or an object with user details
    String createdById;
    String? creatorName;
    String? creatorEmail;

    if (json['createdBy'] is String) {
      createdById = json['createdBy'];
    } else if (json['createdBy'] is Map<String, dynamic>) {
      final creatorData = json['createdBy'] as Map<String, dynamic>;
      createdById = creatorData['_id'] ?? creatorData['id'] ?? '';
      creatorEmail = creatorData['email'];
      // Try to get name from profile or use email username
      if (creatorData['profile'] != null && creatorData['profile'] is Map) {
        creatorName =
            creatorData['profile']['name'] ??
            creatorData['profile']['username'];
      }
      // If no name found, use email username (part before @)
      if (creatorName == null && creatorEmail != null) {
        creatorName = creatorEmail.split('@').first;
      }
    } else {
      createdById = '';
    }

    return Notemodel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      chapterId: json['chapterId'] ?? '',
      createdBy: createdById,
      creatorName: creatorName,
      creatorEmail: creatorEmail,
      rawData: json['rawData'] ?? {},
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'chapterId': chapterId,
      'createdBy': createdBy,
      'creatorName': creatorName,
      'creatorEmail': creatorEmail,
      'rawData': rawData,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  // TODO: implement props
  List<Object?> get props => [
    id,
    title,
    chapterId,
    createdBy,
    creatorName,
    creatorEmail,
    rawData,
    createdAt,
    updatedAt,
  ];
}/*
const NoteSchema: Schema = new Schema(
  {
    title: { type: String, required: true },
    chapterId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Chapter',
      required: true,
    },
    createdBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    rawData: {
      type: {
        type: String,
        enum: ['image', 'text', 'voice'],
        required: true,
      },
      data: { type: String, required: true },
      meta: { type: Schema.Types.Mixed },
    },
  },
  { timestamps: true }
);*/