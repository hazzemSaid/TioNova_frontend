import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/chapter/data/models/NoteModel.dart';
import 'package:tionova/features/chapter/domain/repos/IChapterRepository.dart';

class Getnotesbychapteridusecase {
  final IChapterRepository repository;
  Getnotesbychapteridusecase(this.repository);
  Future<Either<Failure, List<Notemodel>>> call({required String chapterId}) {
    return repository.getNotesByChapterId(chapterId: chapterId);
  }
}
