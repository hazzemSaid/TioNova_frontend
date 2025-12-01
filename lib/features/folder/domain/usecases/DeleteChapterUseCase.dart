import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/folder/domain/repo/IChapterRepository.dart';

class DeleteChapterUseCase {
  final IChapterRepository repository;

  DeleteChapterUseCase(this.repository);

  Future<Either<Failure, void>> call({required String chapterId}) {
    return repository.deleteChapter(chapterId: chapterId);
  }
}
