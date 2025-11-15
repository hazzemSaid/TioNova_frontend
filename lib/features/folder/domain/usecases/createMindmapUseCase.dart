import 'package:either_dart/either.dart';
import 'package:tionova/features/folder/data/models/mindmapmodel.dart';
import 'package:tionova/features/folder/domain/repo/IChapterRepository.dart';

import '../../../../core/errors/failure.dart';

class CreateMindmapUseCase {
  final IChapterRepository repository;

  CreateMindmapUseCase(this.repository);

  Future<Either<Failure, Mindmapmodel>> call({required String chapterId}) {
    return repository.createMindmap(chapterId: chapterId);
  }
}
