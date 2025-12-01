import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/folder/domain/repo/IChapterRepository.dart';

class UpdateChapterUseCase {
  final IChapterRepository repository;

  UpdateChapterUseCase({required this.repository});

  Future<Either<Failure, void>> call({
    required String chapterId,
    required String title,
    required String description,
    required String folderId,
  }) async {
    return await repository.updateChapter(
      chapterId: chapterId,
      title: title,
      description: description,
      folderId: folderId,
    );
  }
}
