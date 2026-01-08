import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/chapter/domain/repos/IChapterRepository.dart';

class Deletenoteusecase {
  final IChapterRepository repository;
  Deletenoteusecase(this.repository);
  Future<Either<Failure, void>> call({required String noteId}) {
    return repository.deleteNote(noteId: noteId);
  }
}
