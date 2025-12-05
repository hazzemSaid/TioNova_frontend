import 'dart:typed_data';

import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/folder/data/models/ChapterModel.dart';
import 'package:tionova/features/folder/data/models/FileDataModel.dart';
import 'package:tionova/features/folder/data/models/NoteModel.dart';
import 'package:tionova/features/folder/data/models/SummaryModel.dart';
import 'package:tionova/features/folder/data/models/mindmapmodel.dart';
import 'package:tionova/features/folder/data/models/new_node_model.dart';
import 'package:tionova/features/folder/data/models/nodeModel.dart';
import 'package:tionova/features/folder/data/models/smart_node_response.dart';

abstract class IChapterRepository {
  Future<Either<Failure, List<ChapterModel>>> getChaptersByFolderId({
    required String folderId,
  });
  Future<Either<Failure, void>> createChapter({
    required String title,
    required String description,
    required String folderId,
    required FileData file,
  });
  Future<Either<Failure, Uint8List>> getchapercontentpdf({
    required String chapterId,
  });
  Future<Either<Failure, SummaryResponse>> GenerateSummary({
    required String chapterId,
  });
  Future<Either<Failure, Mindmapmodel>> createMindmap({
    required String chapterId,
  });
  Future<Either<Failure, List<Notemodel>>> getNotesByChapterId({
    required String chapterId,
  });
  Future<Either<Failure, Notemodel>> addNote({
    required String title,
    required String chapterId,
    required Map<String, dynamic> rawData,
  });
  Future<Either<Failure, void>> deleteNote({required String noteId});
  Future<Either<Failure, Notemodel>> updateNote({
    required String noteId,
    String? title,
    Map<String, dynamic>? rawData,
  });

  Future<Either<Failure, Mindmapmodel>> getMindmap({required String chapterId});
  Future<Either<Failure, SummaryResponse>> getChapterSummary({
    required String chapterId,
  });
  Future<Either<Failure, void>> updateChapter({
    required String chapterId,
    required String title,
    required String description,
    required String folderId,
  });
  Future<Either<Failure, void>> deleteChapter({required String chapterId});

  /// Generate AI-powered smart content for a new mindmap node
  /// Uses the /generateText endpoint to get intelligent suggestions
  Future<Either<Failure, SmartNodeResponse>> generateSmartNode({
    required String text,
    required String chapterId,
  });

  /// Save/Update an existing mindmap with modified title, nodes, and/or new nodes
  /// Uses PATCH /mindmap/saveMindmap endpoint
  ///
  /// [nodes] - Existing nodes to update (with _id)
  /// [newNodes] - New nodes to create and attach to parents
  Future<Either<Failure, Mindmapmodel>> saveMindmap({
    required String mindmapId,
    required String chapterId,
    String? title,
    List<NodeModel>? nodes,
    List<NewNodeModel>? newNodes,
  });
}
