import 'package:equatable/equatable.dart';

/// Model for creating new nodes in the mindmap
/// Used when adding nodes via the saveMindmap API
class NewNodeModel extends Equatable {
  final String? tempId; // Temporary client-side ID for reference
  final String parentId; // Required: ID of the parent node
  final String title; // Required: Node title
  final String? icon;
  final String? color;
  final String? content;

  const NewNodeModel({
    this.tempId,
    required this.parentId,
    required this.title,
    this.icon,
    this.color,
    this.content,
  });

  Map<String, dynamic> toJson() {
    // Build JSON for backend API - tempId is NOT sent to backend
    final Map<String, dynamic> json = {
      'parentId': parentId,
      'title': title,
      'icon': (icon?.isEmpty ?? true) ? '📘' : icon!,
      'color': (color?.isEmpty ?? true) ? '#3B82F6' : color!,
    };

    // Add content if provided
    if (content != null && content!.isNotEmpty) {
      json['content'] = content;
    }

    return json;
  }

  @override
  List<Object?> get props => [tempId, parentId, title, icon, color, content];

  @override
  String toString() {
    return 'NewNodeModel(tempId: $tempId, parentId: $parentId, title: $title, icon: $icon, color: $color, content: $content)';
  }
}
