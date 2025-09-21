import 'dart:typed_data';

import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/folder/data/models/ChapterModel.dart';
import 'package:tionova/features/folder/data/models/FileDataModel.dart';
import 'package:tionova/features/folder/data/models/SummaryModel.dart';
import 'package:tionova/features/folder/domain/repo/IChapterRepository.dart';

class ChapterRepoImpl extends IChapterRepository {
  final IChapterRepository remoteDataSource;
  ChapterRepoImpl({required this.remoteDataSource});
  @override
  Future<Either<Failure, List<ChapterModel>>> getChaptersByFolderId({
    required String folderId,
    required String token,
  }) async {
    return await remoteDataSource.getChaptersByFolderId(
      folderId: folderId,
      token: token,
    );
  }

  @override
  Future<Either<Failure, void>> createChapter({
    required String title,
    required String description,
    required String folderId,
    required String token,
    required FileData file,
  }) {
    return remoteDataSource.createChapter(
      title: title,
      description: description,
      folderId: folderId,
      token: token,
      file: file,
    );
  }

  @override
  Future<Either<Failure, Uint8List>> getchapercontentpdf({
    required String token,
    required String chapterId,
  }) {
    return remoteDataSource.getchapercontentpdf(
      token: token,
      chapterId: chapterId,
    );
  }

  @override
  Future<Either<Failure, SummaryResponse>> GenerateSummary({
    required String token,
    required String chapterId,
  }) {
    return remoteDataSource.GenerateSummary(token: token, chapterId: chapterId);
  }
}
