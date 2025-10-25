import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/challenges/data/model/challenge_code.dart';
import 'package:tionova/features/challenges/domain/repo/LiveChallenge_repo.dart';

class RemoteLiveChallengeDataSource implements LiveChallengeRepo {
  final Dio _dio;
  RemoteLiveChallengeDataSource({required Dio dio}) : _dio = dio;

  @override
  Future<Either<Failure, ChallengeCode>> createLiveChallenge({
    required String token,
    required String title,
    required String chapterId,
  }) async {
    final response = await _dio.post(
      "/live/challenges",
      options: Options(headers: {'Authorization': 'Bearer $token'}),
      data: {'title': title, 'chapterId': chapterId},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final challengeCode = ChallengeCode.fromJson(response.data);
      return Right(challengeCode);
    } else {
      return Left(ServerFailure('Failed to create live challenge'));
    }
  }

  @override
  Future<Either<Failure, void>> disconnectFromLiveChallenge({
    required String token,
    required String challengeCode,
  }) async {
    final response = await _dio.post(
      "/live/challenges/disconnect",
      options: Options(headers: {'Authorization': 'Bearer $token'}),
      data: {'challengeCode': challengeCode},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Right(null);
    } else {
      return Left(ServerFailure('Failed to disconnect from live challenge'));
    }
  }

  @override
  Future<Either<Failure, void>> joinLiveChallenge({
    required String token,
    required String challengeCode,
    bool isReconnection = false,
  }) async {
    try {
      print('DataSource - Joining challenge with code: $challengeCode');
      print('DataSource - Token: ${token.substring(0, 20)}...');
      print('DataSource - Base URL: ${_dio.options.baseUrl}');
      print(
        'DataSource - Full URL: ${_dio.options.baseUrl}/live/challenges/join',
      );

      final response = await _dio.post(
        "/live/challenges/join",
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: {"challengeCode": challengeCode},
      );

      print('DataSource - Join response status: ${response.statusCode}');
      print('DataSource - Join response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(null);
      } else {
        final errorMsg =
            response.data?['message'] ?? 'Failed to join live challenge';
        print(
          'DataSource - Join failed with status ${response.statusCode}: $errorMsg',
        );
        return Left(ServerFailure(errorMsg, response.statusCode.toString()));
      }
    } on DioException catch (e) {
      print('DataSource - DioException during join: ${e.type}');
      print('DataSource - Error message: ${e.message}');
      print('DataSource - Response data: ${e.response?.data}');
      print('DataSource - Status code: ${e.response?.statusCode}');

      final errorMessage =
          e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Failed to join challenge';
      return Left(
        ServerFailure(errorMessage, e.response?.statusCode.toString()),
      );
    } on Exception catch (e) {
      print('DataSource - General exception during join: ${e.toString()}');
      return Left(ServerFailure('Network error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> startLiveChallenge({
    required String token,
    required String challengeCode,
  }) async {
    /*Start Challenge (Owner-only)

POST /api/v1/live/challenges/start

Body: { challengeCode: string }

Auth: required

Returns: { success, message, totalQuestions, currentIndex: 0 }

Behavior: sets meta.status = in-progress , current.index = 0 , saves startedAt , updates Mongo status. */
    final response = await _dio.post(
      "/live/challenges/start",
      options: Options(headers: {'Authorization': 'Bearer $token'}),
      data: {'challengeCode': challengeCode},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Right(null);
    } else {
      // "message": "Only owner can start"
      final message = (response.data is Map)
          ? (response.data as Map)['message']
          : null;
      return Left(ServerFailure(message ?? 'Failed to start live challenge'));
    }
  }

  @override
  Future<Either<Failure, void>> submitLiveAnswer({
    required String token,
    required String challengeCode,
    required String answer,
  }) async {
    /*API: POST /api/v1/live/challenges/answer

Body: { challengeCode: string, answer: string }

Auth: required

Returns: { success, message, isCorrect, currentIndex, rankings }

Behavior: writes to answers[currentIndex][userId] , increments score on correctness, recomputes rankings, mirrors answer in Mongo*/
    try {
      final response = await _dio.post(
        "/live/challenges/answer",
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: {'challengeCode': challengeCode, 'answer': answer},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(null);
      } else {
        final message = (response.data is Map)
            ? (response.data as Map)['message']
            : null;
        return Left(ServerFailure(message ?? 'Failed to submit answer'));
      }
    } catch (e) {
      return Left(ServerFailure('Failed to submit answer: ${e.toString()}'));
    }
  }
}
