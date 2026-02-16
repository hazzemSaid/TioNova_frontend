import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/chapter/data/models/mindmapmodel.dart';
import 'package:tionova/features/chapter/data/models/new_node_model.dart';
import 'package:tionova/features/chapter/data/models/nodeModel.dart';
import 'package:tionova/features/chapter/domain/repos/IChapterRepository.dart';

/// Use case for saving/updating a mindmap with modified title and/or nodes
/// Uses PATCH /mindmap/saveMindmap endpoint
class SaveMindmapUseCase {
  final IChapterRepository repository;

  SaveMindmapUseCase(this.repository);

  /// Saves/Updates a mindmap with the provided data
  ///
  /// [mindmapId] - The MongoDB ObjectId of the mindmap
  /// [chapterId] - The chapter ID for validation
  /// [title] - Optional updated title for the mindmap
  /// [nodes] - Optional list of existing nodes to update (must have _id)
  /// [newNodes] - Optional list of new nodes to create (with parentId)
  ///
  /// Returns the updated [Mindmapmodel] with all nodes
  Future<Either<Failure, Mindmapmodel>> call({
    required String mindmapId,
    required String chapterId,
    String? title,
    List<NodeModel>? nodes,
    List<NewNodeModel>? newNodes,
  }) {
    return repository.saveMindmap(
      mindmapId: mindmapId,
      chapterId: chapterId,
      title: title,
      nodes: nodes,
      newNodes: newNodes,
    );
  }
}
