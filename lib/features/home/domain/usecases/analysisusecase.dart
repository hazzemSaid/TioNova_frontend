import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/home/data/models/analysisModel.dart';
import 'package:tionova/features/home/domain/repo/IanalysisRepository.dart';

class AnalysisUseCase {
  final AnalysisRepository repository;
  AnalysisUseCase({required this.repository});
  Future<Either<Failure, Analysismodel>> execute() {
    return repository.fetchAnalysisData();
  }
}
