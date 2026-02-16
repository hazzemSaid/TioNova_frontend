import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/chapter/data/models/FileDataModel.dart';
import 'package:tionova/features/chapter/domain/repos/IChapterRepository.dart';

class CreateChapterUseCase {
  final IChapterRepository repository;

  CreateChapterUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String title,
    required String description,
    required String folderId,
    required FileData file,
  }) {
    return repository.createChapter(
      title: title,
      description: description,
      folderId: folderId,
      file: file,
    );
  }
}
