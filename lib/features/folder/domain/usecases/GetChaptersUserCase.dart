import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/folder/data/models/ChapterModel.dart';
import 'package:tionova/features/folder/domain/repo/IChapterRepository.dart';

class GetChaptersUseCase {
  final IChapterRepository repository;
  GetChaptersUseCase(this.repository);

  Future<Either<Failure, List<ChapterModel>>> call({
    required String folderId,
    required String token,
  }) async {
    return await repository.getChaptersByFolderId(
      folderId: folderId,
      token: token,
    );
  }
}
