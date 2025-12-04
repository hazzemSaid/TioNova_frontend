import 'package:equatable/equatable.dart';

/// Model for AI-generated smart node content from /generateText endpoint
class SmartNodeResponse extends Equatable {
  final String generatedContent;
  final String userInput;
  final String chapterId;

  const SmartNodeResponse({
    required this.generatedContent,
    required this.userInput,
    required this.chapterId,
  });

  factory SmartNodeResponse.fromJson(Map<String, dynamic> json) {
    return SmartNodeResponse(
      generatedContent: json['generatedContent'] as String? ?? '',
      userInput: json['userInput'] as String? ?? '',
      chapterId: json['chapterId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'generatedContent': generatedContent,
      'userInput': userInput,
      'chapterId': chapterId,
    };
  }

  @override
  List<Object?> get props => [generatedContent, userInput, chapterId];

  @override
  String toString() {
    return 'SmartNodeResponse(generatedContent: $generatedContent, userInput: $userInput, chapterId: $chapterId)';
  }
}
