/* "_id": "68ebb6a4aa1f279000bb42f8",
                "title": "Software Engineering",
                "icon": "🤖",
                "color": "#0084FF",
                "content": "An engineering discipline concerned with theories, methods, and tools for professional software development, aiming for reliable, trustworthy, economical, and quick systems.",
                "children": [
                    "68ebb6a4aa1f279000bb42fa",
                    "68ebb6a4aa1f279000bb42fc",
                    "68ebb6a4aa1f279000bb42fe",
                    "68ebb6a5aa1f279000bb4300"
                ],*/
import 'package:equatable/equatable.dart';

class NodeModel extends Equatable {
  final String? id;
  final String? title;
  final String? icon;
  final String? color;
  final String? content;
  final List<String>? children;
  final bool? isRoot;
  final String? createdAt;
  final String? updatedAt;

  const NodeModel({
    this.id,
    this.title,
    this.icon,
    this.color,
    this.content,
    this.children,
    this.isRoot,
    this.createdAt,
    this.updatedAt,
  });

  factory NodeModel.fromJson(Map<String, dynamic> json) {
    return NodeModel(
      id: json['_id'],
      title: json['title'],
      icon: json['icon'],
      color: json['color'],
      content: json['content'],
      children: List<String>.from(json['children'] ?? []),
      isRoot: json['isRoot'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    // Only include fields expected by the backend API for save operations
    // Exclude createdAt and updatedAt as they are managed by the backend
    final Map<String, dynamic> json = {
      '_id': id,
      'title': title ?? '',
      'icon': icon ?? '📘',
      'color': color ?? '#3B82F6',
      'content': content ?? '',
      'children': children ?? [],
      'isRoot': isRoot ?? false,
    };

    // Remove null _id if not set (for new nodes, but new nodes should use NewNodeModel)
    if (json['_id'] == null) {
      json.remove('_id');
    }

    return json;
  }

  @override
  List<Object?> get props => [
    id,
    title,
    icon,
    color,
    content,
    children,
    isRoot,
    createdAt,
    updatedAt,
  ];

  @override
  bool get stringify => true;

  @override
  NodeModel copyWith({
    String? id,
    String? title,
    String? icon,
    String? color,
    String? content,
    List<String>? children,
    bool? isRoot,
    String? createdAt,
    String? updatedAt,
  }) {
    return NodeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      content: content ?? this.content,
      children: children ?? this.children,
      isRoot: isRoot ?? this.isRoot,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'NodeModel(id: $id, title: $title, icon: $icon, color: $color, content: $content, children: $children, isRoot: $isRoot, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
