import 'dart:typed_data';

import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/folder/data/models/ChapterModel.dart';
import 'package:tionova/features/folder/data/models/FileDataModel.dart';
import 'package:tionova/features/folder/data/models/NoteModel.dart';
import 'package:tionova/features/folder/data/models/SummaryModel.dart';
import 'package:tionova/features/folder/data/models/mindmapmodel.dart';
import 'package:tionova/features/folder/domain/repo/IChapterRepository.dart';

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
  //deleteNote
  Future<Either<Failure, void>> deleteNote({required String noteId}) {
    return remoteDataSource.deleteNote(noteId: noteId);
  }
}
