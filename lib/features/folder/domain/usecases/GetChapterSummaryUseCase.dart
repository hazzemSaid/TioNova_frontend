import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/folder/data/models/SummaryModel.dart';
import 'package:tionova/features/folder/domain/repo/IChapterRepository.dart';

class GetChapterSummaryUseCase {
  final IChapterRepository repository;

  GetChapterSummaryUseCase(this.repository);

  Future<Either<Failure, SummaryResponse>> call({
    required String chapterId,
  }) async {
    return await repository.getChapterSummary(chapterId: chapterId);
  }
}
