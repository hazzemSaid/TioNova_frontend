import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/folder/data/models/FileDataModel.dart';
import 'package:tionova/features/folder/domain/repo/IChapterRepository.dart';

class CreateChapterUseCase {
  final IChapterRepository repository;

  CreateChapterUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String title,
    required String description,
    required String folderId,
    required String token,
    required FileData file,
  }) {
    return repository.createChapter(
      title: title,
      description: description,
      folderId: folderId,
      token: token,
      file: file,
    );
  }
}
