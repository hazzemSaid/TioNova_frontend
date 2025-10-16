import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/folder/domain/repo/IChapterRepository.dart';

class Deletenoteusecase {
  final IChapterRepository repository;
  Deletenoteusecase(this.repository);
  Future<Either<Failure, void>> call({
    required String noteId,
    required String token,
  }) {
    return repository.deleteNote(noteId: noteId, token: token);
  }
}
