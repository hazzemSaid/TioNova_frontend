import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/home/data/models/analysisModel.dart';

abstract class AnalysisRepository {
  Future<Either<Failure, Analysismodel>> fetchAnalysisData();
}
