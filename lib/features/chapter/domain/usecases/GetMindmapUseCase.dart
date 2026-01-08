import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/chapter/data/models/mindmapmodel.dart';
import 'package:tionova/features/chapter/domain/repos/IChapterRepository.dart';

class GetMindmapUseCase {
  final IChapterRepository repository;

  GetMindmapUseCase(this.repository);

  Future<Either<Failure, Mindmapmodel>> call({
    required String chapterId,
  }) async {
    return await repository.getMindmap(chapterId: chapterId);
  }
}
