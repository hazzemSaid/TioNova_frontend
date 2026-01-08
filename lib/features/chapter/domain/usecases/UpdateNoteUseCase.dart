import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/chapter/data/models/NoteModel.dart';
import 'package:tionova/features/chapter/domain/repos/IChapterRepository.dart';

class UpdateNoteUseCase {
  final IChapterRepository repository;
  UpdateNoteUseCase(this.repository);

  Future<Either<Failure, Notemodel>> call({
    required String noteId,
    String? title,
    Map<String, dynamic>? rawData,
  }) {
    return repository.updateNote(
      noteId: noteId,
      title: title,
      rawData: rawData,
    );
  }
}
