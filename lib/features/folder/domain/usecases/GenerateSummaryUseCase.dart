import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/folder/data/models/SummaryModel.dart';
import 'package:tionova/features/folder/domain/repo/IChapterRepository.dart';

class GenerateSummaryUseCase {
  final IChapterRepository repository;

  GenerateSummaryUseCase(this.repository);

  Future<Either<Failure, SummaryResponse>> call({required String chapterId}) {
    return repository.GenerateSummary(chapterId: chapterId);
  }
}
