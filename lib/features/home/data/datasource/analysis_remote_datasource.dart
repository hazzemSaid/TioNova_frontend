import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/home/data/models/analysisModel.dart';

abstract class AnalysisRemoteDataSource {
  /*recentChapters ids
recentFolders ids
lastMindmaps
lastRank
totalChapters
lastSummary
avgScore*/
  /*curl --location --request GET 'http://localhost:3000/api/v1/analysis' \
--header 'Authorization: b eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImhhYXplbXNhaWRkQGdtYWlsLmNvbSIsIl9pZCI6IjY5MGJhZDlmYjI0MzRjZWNmNWU3NTBkYSIsInJvbGUiOiJ1c2VyIiwidXNlcm5hbWUiOiJoYXplbSBzYWlkIiwiaWF0IjoxNzYyNDg4Mjk4LCJleHAiOjE3NjI0OTE4OTh9.JkWC0R_Jpwkp8Q1qhTIcIluGLGcxekX-rJMI2tlIqZY'*/

  Future<Either<Failure, Analysismodel>> fetchAnalysisData({
    required String token,
  });
}

class AnalysisRemoteDataSourceImpl implements AnalysisRemoteDataSource {
  final Dio _dio;

  AnalysisRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<Either<Failure, Analysismodel>> fetchAnalysisData({
    required String token,
  }) async {
    try {
      final response = await _dio.get(
        '/analysis',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final analysisData = Analysismodel.fromJson(response.data);
        return Right(analysisData);
      } else {
        return Left(
          ServerFailure(
            'Failed to fetch analysis data: ${response.statusCode}',
          ),
        );
      }
    } catch (e) {
      return Left(ServerFailure('Failed to fetch analysis data: $e'));
    }
  }
}
