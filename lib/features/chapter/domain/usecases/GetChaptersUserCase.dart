import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/chapter/data/models/ChapterModel.dart';
import 'package:tionova/features/chapter/domain/repos/IChapterRepository.dart';

class GetChaptersUseCase {
  final IChapterRepository repository;
  GetChaptersUseCase(this.repository);

  Future<Either<Failure, List<ChapterModel>>> call({
    required String folderId,
  }) async {
    return await repository.getChaptersByFolderId(folderId: folderId);
  }
}
