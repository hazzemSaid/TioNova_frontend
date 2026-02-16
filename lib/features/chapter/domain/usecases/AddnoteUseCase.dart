import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/chapter/data/models/NoteModel.dart';
import 'package:tionova/features/chapter/domain/repos/IChapterRepository.dart';

class Addnoteusecase {
  final IChapterRepository repository;
  Addnoteusecase(this.repository);
  Future<Either<Failure, Notemodel>> call({
    required String title,
    required String chapterId,
    required Map<String, dynamic> rawData,
  }) {
    return repository.addNote(
      title: title,
      chapterId: chapterId,
      rawData: rawData,
    );
  }
}
