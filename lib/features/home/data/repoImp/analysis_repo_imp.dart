import 'package:either_dart/src/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/home/data/datasource/analysis_remote_datasource.dart';
import 'package:tionova/features/home/data/models/analysisModel.dart';
import 'package:tionova/features/home/domain/repo/IanalysisRepository.dart';

class AnalysisRepositoryImpl implements AnalysisRepository {
  @override
  final AnalysisRemoteDataSource analysisRemoteDataSource;
  AnalysisRepositoryImpl({required this.analysisRemoteDataSource});

  @override
  Future<Either<Failure, Analysismodel>> fetchAnalysisData({
    required String token,
  }) {
    return analysisRemoteDataSource.fetchAnalysisData(token: token);
  }
}
