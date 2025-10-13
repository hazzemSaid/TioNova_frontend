import 'dart:typed_data';

import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/folder/data/models/ChapterModel.dart';
import 'package:tionova/features/folder/data/models/FileDataModel.dart';
import 'package:tionova/features/folder/data/models/SummaryModel.dart';
import 'package:tionova/features/folder/data/models/mindmapmodel.dart';

abstract class IChapterRepository {
  Future<Either<Failure, List<ChapterModel>>> getChaptersByFolderId({
    required String folderId,
    required String token,
  });
  Future<Either<Failure, void>> createChapter({
    required String title,
    required String description,
    required String folderId,
    required String token,
    required FileData file,
  });
  Future<Either<Failure, Uint8List>> getchapercontentpdf({
    required String token,
    required String chapterId,
  });
  Future<Either<Failure, SummaryResponse>> GenerateSummary({
    required String token,
    required String chapterId,
  });
  Future<Either<Failure, Mindmapmodel>> createMindmap({
    required String token,
    required String chapterId,
  });
}
