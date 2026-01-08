import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/chapter/data/models/smart_node_response.dart';
import 'package:tionova/features/chapter/domain/repos/IChapterRepository.dart';

/// Use case for generating AI-powered smart content for mindmap nodes
/// Uses the /generateText endpoint to get intelligent suggestions based on
/// user's query and chapter content
class GenerateSmartNodeUseCase {
  final IChapterRepository repository;

  GenerateSmartNodeUseCase(this.repository);

  /// Generates AI-powered content for a new mindmap node
  ///
  /// [text] - User's topic or question (minimum 10 characters)
  /// [chapterId] - The chapter ID to analyze for context
  ///
  /// Returns [SmartNodeResponse] with generated bullet-point content
  Future<Either<Failure, SmartNodeResponse>> call({
    required String text,
    required String chapterId,
  }) {
    print('🔵 [GenerateSmartNodeUseCase] call() invoked');
    print('📝 Text: "$text", ChapterId: $chapterId');
    return repository.generateSmartNode(text: text, chapterId: chapterId);
  }
}
