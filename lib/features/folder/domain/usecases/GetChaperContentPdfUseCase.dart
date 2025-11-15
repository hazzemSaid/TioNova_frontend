import 'dart:typed_data';

import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/folder/domain/repo/IChapterRepository.dart';

class GetChapterContentPdfUseCase {
  final IChapterRepository repository;

  GetChapterContentPdfUseCase(this.repository);

  Future<Either<Failure, Uint8List>> call({required String chapterId}) {
    return repository.getchapercontentpdf(chapterId: chapterId);
  }
}
