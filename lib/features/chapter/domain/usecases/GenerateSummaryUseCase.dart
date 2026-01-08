import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/chapter/data/models/SummaryModel.dart';
import 'package:tionova/features/chapter/domain/repos/IChapterRepository.dart';

class GenerateSummaryUseCase {
  final IChapterRepository repository;

  GenerateSummaryUseCase(this.repository);

  Future<Either<Failure, SummaryResponse>> call({required String chapterId}) {
    return repository.GenerateSummary(chapterId: chapterId);
  }
}
