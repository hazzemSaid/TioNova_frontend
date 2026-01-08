import 'package:equatable/equatable.dart';
import 'package:tionova/features/chapter/data/models/nodeModel.dart';

class Mindmapmodel extends Equatable {
  final String? id;
  final String? chapterId;
  final String? title;
  final List<NodeModel>? nodes;
  final String? createdBy;
  final String? updatedBy;
  final String? createdAt;
  final String? updatedAt;

  const Mindmapmodel({
    this.id,
    this.chapterId,
    this.title,
    this.nodes,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory Mindmapmodel.fromJson(Map<String, dynamic> json) {
    return Mindmapmodel(
      id: json['_id'],
      chapterId: json['chapterId'],
      title: json['title'],
      nodes: (json['nodes'] as List<dynamic>?)
          ?.map((node) => NodeModel.fromJson(node))
          .toList(),
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'chapterId': chapterId,
      'title': title,
      'nodes': nodes?.map((node) => node.toJson()).toList(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    id,
    chapterId,
    title,
    nodes,
    createdBy,
    updatedBy,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'Mindmapmodel(id: $id, chapterId: $chapterId, title: $title, nodes: $nodes, createdBy: $createdBy, updatedBy: $updatedBy, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
