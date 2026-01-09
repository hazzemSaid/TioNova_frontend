import 'dart:typed_data';

import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/chapter/data/models/ChapterModel.dart';
import 'package:tionova/features/chapter/data/models/FileDataModel.dart';
import 'package:tionova/features/chapter/data/models/NoteModel.dart';
import 'package:tionova/features/chapter/data/models/SummaryModel.dart';
import 'package:tionova/features/chapter/data/models/mindmapmodel.dart';
import 'package:tionova/features/chapter/data/models/new_node_model.dart';
import 'package:tionova/features/chapter/data/models/nodeModel.dart';
import 'package:tionova/features/chapter/data/models/smart_node_response.dart';
import 'package:tionova/features/chapter/domain/repos/IChapterRepository.dart';

class ChapterRepoImpl extends IChapterRepository {
  final IChapterRepository remoteDataSource;
  ChapterRepoImpl({required this.remoteDataSource});
  @override
  Future<Either<Failure, List<ChapterModel>>> getChaptersByFolderId({
    required String folderId,
  }) async {
    return await remoteDataSource.getChaptersByFolderId(folderId: folderId);
  }

  @override
  Future<Either<Failure, void>> createChapter({
    required String title,
    required String description,
    required String folderId,
    required FileData file,
  }) {
    return remoteDataSource.createChapter(
      title: title,
      description: description,
      folderId: folderId,
      file: file,
    );
  }

  @override
  Future<Either<Failure, Uint8List>> getchapercontentpdf({
    required String chapterId,
  }) {
    return remoteDataSource.getchapercontentpdf(chapterId: chapterId);
  }

  @override
  Future<Either<Failure, SummaryResponse>> GenerateSummary({
    required String chapterId,
  }) {
    return remoteDataSource.GenerateSummary(chapterId: chapterId);
  }

  @override
  Future<Either<Failure, Mindmapmodel>> createMindmap({
    required String chapterId,
  }) {
    return remoteDataSource.createMindmap(chapterId: chapterId);
  }

  @override
  Future<Either<Failure, Mindmapmodel>> getMindmap({
    required String chapterId,
  }) {
    return remoteDataSource.createMindmap(chapterId: chapterId);
  }

  @override
  //getNotesByChapterId
  Future<Either<Failure, List<Notemodel>>> getNotesByChapterId({
    required String chapterId,
  }) async {
    return await remoteDataSource.getNotesByChapterId(chapterId: chapterId);
  }

  @override
  //addNote
  Future<Either<Failure, Notemodel>> addNote({
    required String title,
    required String chapterId,
    required Map<String, dynamic> rawData,
  }) {
    return remoteDataSource.addNote(
      title: title,
      chapterId: chapterId,
      rawData: rawData,
    );
  }

  @override
  Future<Either<Failure, void>> deleteNote({required String noteId}) {
    return remoteDataSource.deleteNote(noteId: noteId);
  }

  @override
  Future<Either<Failure, SummaryResponse>> getChapterSummary({
    required String chapterId,
  }) async {
    return await remoteDataSource.getChapterSummary(chapterId: chapterId);
  }

  @override
  Future<Either<Failure, void>> updateChapter({
    required String chapterId,
    required String title,
    required String description,
    required String folderId,
  }) async {
    return await remoteDataSource.updateChapter(
      chapterId: chapterId,
      title: title,
      description: description,
      folderId: folderId,
    );
  }

  @override
  Future<Either<Failure, void>> deleteChapter({required String chapterId}) {
    return remoteDataSource.deleteChapter(chapterId: chapterId);
  }

  @override
  Future<Either<Failure, SmartNodeResponse>> generateSmartNode({
    required String text,
    required String chapterId,
  }) {
    return remoteDataSource.generateSmartNode(text: text, chapterId: chapterId);
  }

  @override
  Future<Either<Failure, Mindmapmodel>> saveMindmap({
    required String mindmapId,
    required String chapterId,
    String? title,
    List<NodeModel>? nodes,
    List<NewNodeModel>? newNodes,
  }) {
    return remoteDataSource.saveMindmap(
      mindmapId: mindmapId,
      chapterId: chapterId,
      title: title,
      nodes: nodes,
      newNodes: newNodes,
    );
  }

  @override
  Future<Either<Failure, Notemodel>> updateNote({
    required String noteId,
    String? title,
    Map<String, dynamic>? rawData,
  }) {
    return remoteDataSource.updateNote(
      noteId: noteId,
      title: title,
      rawData: rawData,
    );
  }
}
