import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/chapter/data/models/SummaryModel.dart';
import 'package:tionova/features/chapter/domain/repos/IChapterRepository.dart';

class GetChapterSummaryUseCase {
  final IChapterRepository repository;

  GetChapterSummaryUseCase(this.repository);

  Future<Either<Failure, SummaryResponse>> call({
    required String chapterId,
  }) async {
    return await repository.getChapterSummary(chapterId: chapterId);
  }
}
